import Foundation
import Network

/// Tiny HTTP server bound to a fixed port. Exposes:
///   GET  /ping   → device info (used by the web app to confirm it's the right device)
///   GET  /state  → current localStorage state as JSON
///   POST /state  → replaces localStorage with the posted body, reloads the web view
///
/// The web app is expected to do a smart merge on its side before POSTing back.
@MainActor
final class SyncServer: ObservableObject {
    @Published var currentIP: String?
    let port: UInt16 = 8181

    private var listener: NWListener?

    func start() {
        currentIP = wifiAddress()
        stop()
        do {
            let params = NWParameters.tcp
            params.allowLocalEndpointReuse = true
            listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: port)!)
            listener?.newConnectionHandler = { [weak self] conn in
                Task { @MainActor in self?.accept(conn) }
            }
            listener?.stateUpdateHandler = { [weak self] state in
                if case .failed(let err) = state {
                    print("[SyncServer] listener failed: \(err)")
                    Task { @MainActor in self?.restart() }
                }
            }
            listener?.start(queue: .main)
            print("[SyncServer] listening on port \(port), ip=\(currentIP ?? "?")")
        } catch {
            print("[SyncServer] start failed: \(error)")
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func restart() {
        stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in self?.start() }
    }

    // MARK: - Connection handling

    private func accept(_ conn: NWConnection) {
        conn.start(queue: .main)
        receive(conn, buffer: Data())
    }

    private func receive(_ conn: NWConnection, buffer: Data) {
        conn.receive(minimumIncompleteLength: 1, maximumLength: 1 << 20) { [weak self] chunk, _, isComplete, err in
            Task { @MainActor in
                guard let self = self else { conn.cancel(); return }
                if let err = err { print("[SyncServer] recv err: \(err)"); conn.cancel(); return }
                var buf = buffer
                if let c = chunk { buf.append(c) }
                // Look for headers/body split.
                guard let sep = buf.range(of: Data("\r\n\r\n".utf8)) else {
                    if isComplete { conn.cancel(); return }
                    self.receive(conn, buffer: buf); return
                }
                let headerData = buf.subdata(in: 0..<sep.lowerBound)
                let bodyStart = sep.upperBound
                let headers = String(decoding: headerData, as: UTF8.self)

                let (method, path) = self.parseRequestLine(headers)
                let contentLength = self.header(headers, "Content-Length").flatMap(Int.init) ?? 0

                let haveBodyBytes = buf.count - bodyStart
                if method == "POST" && haveBodyBytes < contentLength {
                    if isComplete { conn.cancel(); return }
                    self.receive(conn, buffer: buf); return
                }
                let body = String(decoding: buf.subdata(in: bodyStart..<min(bodyStart+contentLength, buf.count)), as: UTF8.self)

                self.route(conn, method: method, path: path, body: body)
            }
        }
    }

    private func parseRequestLine(_ headers: String) -> (String, String) {
        guard let firstLine = headers.split(separator: "\r\n").first else { return ("", "") }
        let parts = firstLine.split(separator: " ")
        if parts.count >= 2 { return (String(parts[0]), String(parts[1])) }
        return ("", "")
    }

    private func header(_ headers: String, _ name: String) -> String? {
        for line in headers.split(separator: "\r\n") where line.lowercased().hasPrefix(name.lowercased() + ":") {
            if let colon = line.firstIndex(of: ":") {
                return line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }

    // MARK: - Routing

    private func route(_ conn: NWConnection, method: String, path: String, body: String) {
        let cleanPath = path.split(separator: "?").first.map(String.init) ?? path
        switch (method, cleanPath) {
        case ("OPTIONS", _):
            respond(conn, status: 204, body: "")
        case ("GET", "/ping"):
            respond(conn, status: 200, body: #"{"app":"KabirSpanish","port":\#(port),"version":2}"#)
        case ("GET", "/state"):
            WebViewStore.shared.getState { json in
                self.respond(conn, status: 200, body: json ?? "null")
            }
        case ("POST", "/state"):
            WebViewStore.shared.setState(body) { ok in
                let payload = ok ? #"{"ok":true}"# : #"{"ok":false,"error":"set failed"}"#
                self.respond(conn, status: ok ? 200 : 500, body: payload)
            }
        case ("POST", "/html"):
            // Over-the-air HTML update pushed from the Mac (the same file the browser runs).
            let data = Data(body.utf8)
            WebViewStore.shared.saveUpdatedHTML(data) { ok, size in
                let payload = ok ? #"{"ok":true,"bytes":\#(size)}"# : #"{"ok":false,"error":"write failed"}"#
                self.respond(conn, status: ok ? 200 : 500, body: payload)
            }
        case ("POST", "/html/reset"):
            // Discard the pushed HTML and go back to the version bundled in the app.
            WebViewStore.shared.resetToBundledHTML()
            respond(conn, status: 200, body: #"{"ok":true,"reverted":true}"#)
        default:
            respond(conn, status: 404, body: #"{"error":"not found"}"#)
        }
    }

    private func respond(_ conn: NWConnection, status: Int, body: String) {
        let statusText: String = {
            switch status {
            case 200: return "OK"; case 204: return "No Content"
            case 404: return "Not Found"; case 500: return "Internal Server Error"
            default: return "OK"
            }
        }()
        let head = """
        HTTP/1.1 \(status) \(statusText)\r
        Content-Type: application/json; charset=utf-8\r
        Access-Control-Allow-Origin: *\r
        Access-Control-Allow-Methods: GET, POST, OPTIONS\r
        Access-Control-Allow-Headers: Content-Type\r
        Content-Length: \(body.utf8.count)\r
        Connection: close\r
        \r

        """
        var data = Data(head.utf8)
        data.append(Data(body.utf8))
        conn.send(content: data, completion: .contentProcessed({ _ in conn.cancel() }))
    }

    // MARK: - Wi-Fi IP lookup (en0)

    private func wifiAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let first = ifaddr else { return nil }
        defer { freeifaddrs(ifaddr) }
        for ptr in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let iface = ptr.pointee
            guard iface.ifa_addr.pointee.sa_family == UInt8(AF_INET) else { continue }
            let name = String(cString: iface.ifa_name)
            guard name == "en0" else { continue }
            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(iface.ifa_addr, socklen_t(iface.ifa_addr.pointee.sa_len),
                        &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST)
            address = String(cString: host); break
        }
        return address
    }
}
