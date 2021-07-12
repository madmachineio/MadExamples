// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import SwiftIOFeather

// default: 16k sample rate, 16bit sample bits
let speaker = I2SOut(Id.I2SOut0, bits: 16, channel: .stereo)
let mic = I2SIn(Id.I2SIn0, bits: 32, channel: .stereo)

let recordSample = 16_000 * 5
var speakerData = [Int16](repeating: 0, count: recordSample)
var micData = [UInt8](repeating: 0, count: 4 * recordSample)

let b = DigitalIn(Id.D1)
let r = DigitalOut(Id.D19)


while true {
//    let micData = mic.read(count: sampleRate * 3)

    if b.read() {
        r.high()
        mic.read(to: &micData)
        r.low()
        micData.withUnsafeBytes { bytePtr in
            let int32Ptr = bytePtr.bindMemory(to: Int32.self)
            for i in 0..<recordSample {
                speakerData[i] = Int16(int32Ptr[i] >> 16)
            }
        }
    } else {
        speakerData.withUnsafeBytes { ptr in
        let u8Data = ptr.bindMemory(to: UInt8.self)
        speaker.write(Array<UInt8>(u8Data))
        }
    }
}

