import SwiftIO
import MadBoard

@main
public struct ReadingFiles {
    public static func main() {
        let speaker = I2S(Id.I2S0, rate: 16_000)

        do {
            // let file = try FileDescriptor.open("/SD:/Resources/Document/hello.txt")
            let file = try FileDescriptor.open("/lfs/Resources/Document/hello.txt")

            // Repositions the offset to the end of the file.
            // Get the current offset to get file size.
            try file.seek(offset: 0, from: FileDescriptor.SeekOrigin.end)
            let size = try file.tell()

            // Reposition the offset to the beginning of the file and start reading.
            var buffer = [UInt8](repeating: 0, count: size)
            try file.read(fromAbsoluteOffest: 0, into: &buffer)
            
            print(String(decoding: buffer[0..<size], as: UTF8.self))

            try file.close()    
        } catch {
            print(error)
        }

        do {
            // let file = try FileDescriptor.open("/SD:/Resources/Music/twinkle-twinkle-little-star.wav")
            let file = try FileDescriptor.open("/lfs/Resources/Music/twinkle-twinkle-little-star.wav")

            try file.seek(offset: 0, from: FileDescriptor.SeekOrigin.end)

            // WAV file header size.
            let headerSize = 0x2C
            let size = try file.tell() - headerSize

            var buffer = [UInt8](repeating: 0, count: size)
            try file.read(fromAbsoluteOffest: headerSize, into: &buffer, count: size)

            try file.close()

            speaker.write(buffer)
        } catch {
            print(error)
        }

        while true {
        sleep(ms: 1000)
        }
    }
}