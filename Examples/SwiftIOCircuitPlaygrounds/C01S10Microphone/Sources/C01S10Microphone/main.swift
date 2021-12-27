// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import MadBoard

// default: 16k sample rate, 16bit sample bits
let speaker = I2SOut(Id.I2SOut0, bits: 16, channel: .stereo)
let mic = I2SIn(Id.I2SIn0, bits: 32, channel: .stereo)


// 800 samples(50ms), 3200 bytes every time
let recordSample = 800
var micData = [UInt8](repeating: 0, count: 4 * 2 * recordSample)

var speakerData: [Int16] = []

let recordButton = DigitalIn(Id.D1)
let playButton = DigitalIn(Id.D21)
let r = DigitalOut(Id.RED, value: true)
let g = DigitalOut(Id.GREEN, value: true)

var firstSample = true

while true {
//    let micData = mic.read(count: sampleRate * 3)
    if recordButton.read() {
        if firstSample {
            r.low()
            speakerData = []
            firstSample = false
        }
        mic.read(to: &micData)
        micData.withUnsafeBytes { bytePtr in
            let int32Ptr = bytePtr.bindMemory(to: Int32.self)
            for i in 0..<recordSample {

                speakerData.append(Int16(truncatingIfNeeded: (int32Ptr[i * 2] >> 13) ))
            }
        }
    } else {
        firstSample = true
        r.high()
    }
    
    if playButton.read() && speakerData.count >= 160 * 50 {
        g.low()
        speakerData.withUnsafeBytes { ptr in
        let u8Data = ptr.bindMemory(to: UInt8.self)
            speaker.write(Array<UInt8>(u8Data))
        }
        g.high()
    }
}

