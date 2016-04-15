import C7
import Suv
import CLibUv

struct HTTPStream: AsyncStream {
    var closed: Bool {
        return stream.isClosing()
    }
    
    let stream: TCP
    
    init(stream: TCP) {
        self.stream = stream
    }
    
    func send(data: Data, timingOut deadline: Double = 0, result: (Void throws -> Void) -> Void) {
        stream.write(Buffer(data.bytes)) { (res) in
            result {
                switch res {
                case .Error(let error):
                    throw error
                default:
                    break
                }
            }
        }
    }
    
    func receive(upTo byteCount: Int = 1024, timingOut deadline: Double = 0, result: (Void throws -> Data) -> Void) {
        stream.read { res in
            switch res {
            case .Data(let buf):
                result { Data(buf.bytes) }
            case .Error(let error):
                result { throw error }
            default:
                result { throw SuvError.UVError(code: UV_EOF.rawValue) }
            }
        }
    }
    
    func flush(timingOut deadline: Double, result: (Void throws -> Void) -> Void) {
        //
    }
    
    func close() -> Bool {
        stream.close()
        return stream.isClosing()
    }
}