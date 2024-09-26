import SwiftIO
import MadBoard
import ST7789

@main
public struct Album {
    public static func main() {
        let bl = DigitalOut(Id.D2)
        let rst = DigitalOut(Id.D12)
        let dc = DigitalOut(Id.D13)
        let cs = DigitalOut(Id.D5)
        let spi = SPI(Id.SPI0, speed: 30_000_000)
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        // Read the image from the specified path and display it on the screen.
        do {
            // You can get the binary file of your photo here: https://lvgl.io/tools/imageconverter.
            // The output format should be Binary RGB565 Swap.
            let file = try FileDescriptor.open("/lfs/Resources/Photo/cat.bin")

            var buffer = [UInt16](repeating: 0, count: 240 * 240)

            buffer.withUnsafeMutableBytes() {
                _ = try? file.read(fromAbsoluteOffest: 0, into: $0)
            }

            screen.writeScreen(buffer)

            try file.close()
        } catch {
            print("File handle error: \(error)")
        }

        while true {
            sleep(ms: 1000)
        }
    }
}