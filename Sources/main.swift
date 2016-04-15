import S4
import HTTP
import Data

let CRLF = "\r\n"
let server = HTTPServer { (res) in
    do {
        let (request, stream) = try res()
        let headers = Headers(dictionaryLiteral: ("Content-Type", Header(arrayLiteral: "text/html")))
        var response = Response(status: .ok, headers: headers, body: Data("<h1>this is sample</h1>"))
        stream.send(response.description.data, result: { (res) in })
        stream.send(Data(CRLF), result: { (res) in })
        stream.send(try response.body.becomeBuffer(), result: { (res) in })
        stream.close()
    } catch {
    }
}

server.start()