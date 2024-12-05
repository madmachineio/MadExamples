import SwiftIO
import MadBoard

func soundThread(_ a: UnsafeMutableRawPointer?, _ b: UnsafeMutableRawPointer?, _ c: UnsafeMutableRawPointer?) -> () {
    let speaker = I2S(Id.I2S0, rate: 44_100)

    // Read sound data from file.
    let sound = readSoundData(from: "/lfs/Resources/Sounds/boom.wav")
    var startPlay = false

    while true {
        sleep(ms: 100)

        // Check the global variable to see if the speaker need to play sound.
        i2sLock.lock()
        if playSound {
            startPlay = true
        }
        i2sLock.unlock()

        if startPlay {
            speaker.write(sound)
            startPlay = false

            // Update the global variable.
            i2sLock.lock()
            playSound = false
            i2sLock.unlock()
        }
    }

    func readSoundData(from path: String) -> [UInt8] {
        let headerSize = 0x2C
        var buffer = [UInt8]()

        do {
            let file = try FileDescriptor.open(path)
            try file.seek(offset: 0, from: FileDescriptor.SeekOrigin.end)
            let size = try file.tell() - headerSize

            buffer = [UInt8](repeating: 0, count: size)
            try file.read(fromAbsoluteOffest: headerSize, into: &buffer, count: size)
            try file.close()
        } catch {
            print("File \(path) handle error: \(error)")
            return []
        }

        return buffer
    }
}