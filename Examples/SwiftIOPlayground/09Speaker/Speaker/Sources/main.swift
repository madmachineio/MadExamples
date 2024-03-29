// Import the SwiftIO library to control input and output.
import SwiftIO
// Import the MadBoard to use the id of the pins.
import MadBoard


// Initialize the speaker using I2S communication. 
// The default setting is 16k sample rate, 16bit sample bits.
let speaker = I2S(Id.I2S0)

// The frequencies of note C to B in octave 4.
let frequency: [Float] = [
    261.626,
    293.665,
    329.628,
    349.228,
    391.995,
    440.000,
    493.883
]

// Set the samples of the waveforms.
let sampleRate = 16_000
let rawSampleLength = 1000
var rawSamples = [Int16](repeating: 0, count: rawSampleLength)
var amplitude: Int16 = 10_000

while true {

    let duration: Float = 1.0

    // Iterate through the frequencies from C to B to play a scale. 
    // The sound waveform is a square wave, so you will hear a buzzing sound.
    generateSquare(amplitude: amplitude, &rawSamples)
    for f in frequency {
        playWave(samples: rawSamples, frequency: f, duration: duration)
    } 
    sleep(ms: 1000)

    // Iterate through the frequencies from C to B to play a scale.
    // The sound waveform is a triangle wave, and the sound is much softer.
    generateTriangle(amplitude: amplitude, &rawSamples)
    for f in frequency {
        playWave(samples: rawSamples, frequency: f, duration: duration)
    } 
    sleep(ms: 1000)

    // Decrease the amplitude to lower the sound.
    // If it's smaller than zero, it restarts from 20000.
    amplitude -= 1000
    if amplitude <= 0 {
        amplitude = 10_000
    }
}

// Generate samples for a square wave with a specified amplitude and store them in an array.
func generateSquare(amplitude: Int16, _ samples: inout [Int16]) {
    let count = samples.count
    for i in 0..<count / 2 {
        samples[i] = -amplitude
    }
    for i in count / 2..<count {
        samples[i] = amplitude
    }
}

// Generate samples for a triangle wave with a specified amplitude and store the them in an array.
func generateTriangle(amplitude: Int16, _ samples: inout [Int16]) {
    let count = samples.count

    let step = Float(amplitude) / Float(count / 2)
    for i in 0..<count / 4 {
        samples[i] = Int16(step * Float(i))
    }
    for i in count / 4..<count / 4 * 3 {
        samples[i] = amplitude - Int16(step * Float(i))
    }
    for i in count / 4 * 3..<count {
        samples[i] = -amplitude + Int16(step * Float(i))
    }
}

// Send the samples over I2s bus and play the note with a specified frequency and duration.
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
