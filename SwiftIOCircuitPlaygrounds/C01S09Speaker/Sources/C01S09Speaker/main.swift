// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import SwiftIOFeather

// default: 16k sample rate, 16bit sample bits
let speaker = I2SOut(Id.I2SOut0)

let frequency: [Float] = [
    523.251,
    587.330,
    659.255,
    698.456,
    783.991,
    880.000,
    987.767
]
let sampleRate = 16_000

var volume: Float = 0.5

var data = [UInt8](repeating: 0, count: sampleRate * 2)



sleep(ms: 2000)

while true {
    for f in frequency {
        let sample = getTriData(frequency: f, volume: 0.3)
        print(sample)

        data.withUnsafeMutableBytes { base in
            let ptr = base.bindMemory(to: Int16.self)
            for i in 0..<ptr.count {
                ptr[i] = sample[i % sample.count]
            }
        }
        speaker.write(data)
    }
    sleep(ms: 5000)
}

func getTriData(frequency: Float, volume: Float) -> [Int16] {
    let sampleCount = Int(Float(sampleRate) / frequency)
    let maxVolume = Int16(Float(Int16.max) * volume)
    let volumeStep = maxVolume / (Int16(sampleCount) / 4)

    var sample = [Int16](repeating: 0, count: sampleCount)
    var dirUp = true
    var value: Int16 = 0

    for i in 0..<sampleCount {
        sample[i] = value
        if dirUp {
            value += volumeStep
            if value > maxVolume {
                value -= 2 * volumeStep
                dirUp = false
            }
        } else {
            value -= volumeStep
            if value < -maxVolume {
                value += 2 * volumeStep
                dirUp = true
            }
        }
    }

    return sample
}