// A simple prank idea: play a high-volume sound effect to scare people.
// Hang the kit on a door, place it under a chair, or put it on any object your friend might move.

import SwiftIO
import MadBoard
import LIS3DH

let i2c = I2C(Id.I2C0)
let accelerometer = LIS3DH(i2c)

let speaker = I2S(Id.I2S0, rate: 44_100)

// The sound files are stored on Resources folder.
// Press Copy Resources button on MadMachine extension for VS code to copy them to SD card/flash.
let screamSound = readSoundData(from: "/lfs/Resources/Sounds/Scream.wav")
let laughSound = readSoundData(from: "/lfs/Resources/Sounds/Laugh.wav")
let pigsSound = readSoundData(from: "/lfs/Resources/Sounds/Pigs.wav")

var sounds = [screamSound, laughSound, pigsSound]
var index = 0

while true {
    let acceleration = accelerometer.readXYZ()
    // Once the acceleration exceeds the threshold, the speaker will play a sound effect.
    // Adjust the threshold to suit your situation.
    if acceleration.z > 0.25 {
        let zString = getFloatString(acceleration.z)
        print(zString)
        speaker.write(sounds[index])
        index = (index + 1) % sounds.count
    }
    sleep(ms: 2)
}

func readSoundData(from path: String) -> [UInt8] {
    let headerSize = 0x2C

    guard let file = try? FileDescriptor.open(path) else {
        print("Read sound data \(path) failed!")
        return []
    }

    var buffer = [UInt8]()

    do throws(Errno) {
        try file.seek(offset: 0, from: FileDescriptor.SeekOrigin.end)
        let size = try file.tell() - headerSize

        buffer = [UInt8](repeating: 0, count: size)
        try? buffer.withUnsafeMutableBytes { rawBuffer in 
            _ = try? file.read(fromAbsoluteOffest: headerSize, into: rawBuffer, count: size)
        }
        try file.close()
    } catch {
        print("File \(path) handle error: \(error)")
        return []
    }

    return buffer
}


func getFloatString(_ num: Float) -> String {
    let int = Int(num)
    let frac = Int((num - Float(int)) * 100)
    return "\(int).\(frac)"
}