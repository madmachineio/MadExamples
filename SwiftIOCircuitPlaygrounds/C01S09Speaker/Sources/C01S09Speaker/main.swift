// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the SwiftIOFeather to use the id of the pins.
import MadBoard

// default: 16k sample rate, 16bit sample bits
let speaker = I2SOut(Id.I2SOut0)

let frequency: [Float] = [
    261.626,
    293.665,
    329.628,
    349.228,
    391.995,
    440.000,
    493.883
]

let sampleRate = 16_000

let rawSampleLength = 1000
var rawSamples = [Int16](repeating: 0, count: rawSampleLength)


var amplitude: Int16 = 20_000

while true {

    let duration: Float = 1.0

    generateSquare(amplitude: amplitude, &rawSamples)
    for f in frequency {
        playWave(samples: rawSamples, frequency: f, duration: duration)
    } 
    sleep(ms: 1000)

    generateTriangle(amplitude: amplitude, &rawSamples)
    for f in frequency {
        playWave(samples: rawSamples, frequency: f, duration: duration)
    } 
    sleep(ms: 1000)

    amplitude -= 2000
    if amplitude <= 0 {
        amplitude = 20_000
    }
}



func generateSquare(amplitude: Int16, _ samples: inout [Int16]) {
    let count = samples.count
    for i in 0..<count / 2 {
        samples[i] = -(amplitude / 2)
    }
    for i in count / 2..<count {
        samples[i] = amplitude / 2
    }
}


func generateTriangle(amplitude: Int16, _ samples: inout [Int16]) {
    let count = samples.count

    let step = Float(amplitude) / Float(count)
    for i in 0..<count / 4{
        samples[i] = Int16(step * Float(i))
    }
    for i in count / 4..<count / 4 * 3 {
        samples[i] = (amplitude / 2) - Int16(step * Float(i))
    }
    for i in count / 4 * 3..<count {
        samples[i] = -(amplitude / 2) + Int16(step * Float(i))
    }
}

func playWave(samples: [Int16], frequency: Float, duration: Float) {
    let playCount = Int(duration * Float(sampleRate))
    var data = [Int16](repeating: 0, count: playCount)

    let step: Float = frequency * Float(samples.count) / Float(sampleRate)

    var volume: Float = 1.0
    let volumeStep = 1.0 / Float(playCount)

    for i in 0..<playCount {
        let pos = Int(Float(i) * step) % samples.count 
        data[i] = Int16(Float(samples[pos]) * volume)
        volume -= volumeStep
    }
    data.withUnsafeBytes { ptr in
        let u8Array = ptr.bindMemory(to: UInt8.self)
        speaker.write(Array(u8Array))
    }
}