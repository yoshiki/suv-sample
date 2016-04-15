#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Suv
import S4
import HTTPParser

typealias RequestHandler = (() throws -> (Request, HTTPStream)) -> ()

struct HTTPServer {
    let server: TCPServer
    let userHandler: RequestHandler
    
    init(handler: RequestHandler) {
        self.server = TCPServer(loop: Loop.defaultLoop, ipcEnable: false)
        self.userHandler = handler
        signal(SIGPIPE, SIG_IGN)
    }
    
    func start() {
        do {
            try server.bind(Address(host: "0.0.0.0", port: 8080))
            try server.listen(2048) { result in
                if case .Success(let queue) = result {
                    self.handler(queue)
                } else if case .Error(let error) = result {
                    self.userHandler { throw error }
                }
            }
            Loop.defaultLoop.run()
        } catch {
            print("cannot bind")
        }
    }
    
    func handler(queue: Pipe?) {
        let client = HTTPStream(stream: TCP())
        
        do {
            try server.accept(client.stream, queue: queue)
        } catch {
            client.close()
        }
        
        let parser = RequestParser()

        client.receive { result in
            do {
                let data = try result()
                if let request = try parser.parse(data) {
                    self.userHandler { return (request, client) }
                }
            } catch {
                client.close()
                self.userHandler { throw error }
            }
        }
    }
}
