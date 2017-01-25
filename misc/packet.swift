import Foundation
extension String {
    var length: Int {
        return self.characters.count
    }
}
func pack(method: String, data: String) -> [UInt8] {
  let methodLenByte:[UInt8] = [UInt8(method.length)]
  let body = method + data
  let bodyByte = [UInt8](body.utf8)
  let final = methodLenByte + bodyByte
  return final
}
func unpack(binary: [UInt8]) {
  let methodLen = binary[0]
  let methodByte = Array(binary[1...Int(methodLen)])
  let bodyByte = Array(binary[(1 + Int(methodLen))...(binary.count-1)])
  let method = String(bytes:methodByte, encoding:String.Encoding.utf8)!
  let data = String(bytes:bodyByte, encoding:String.Encoding.utf8)!
  print("\(method) \(data)")
}
print(unpack(binary:pack(method:"method", data:"abcdefg")))
