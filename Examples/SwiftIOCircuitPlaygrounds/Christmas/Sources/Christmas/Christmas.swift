// Play the christmas song and display snow falling effect on screen.

import SwiftIO
import MadBoard
// The driver for the screen.
import ST7789
// The driver for the acceleromete.
import LIS3DH
// Graphical library.
import MadGraphics

@main
public struct Christmas {
    public static func main() {
                // Initialize the SPI pin and the digital pins for the LCD.
        let spi = SPI(Id.SPI0, speed: 30_000_000)
        let cs = DigitalOut(Id.D9)
        let dc = DigitalOut(Id.D10)
        let rst = DigitalOut(Id.D14)
        let bl = DigitalOut(Id.D2)

        // Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
        let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

        // Initialize the accelerometer using I2C.
        let i2c = I2C(Id.I2C0)
        let accelerometer = LIS3DH(i2c)

        // A root tile is necessary to store all subtiles.
        let rootTile = Tile<UInt16>(width: screen.width, height: screen.height, primaryColor: 0, isRoot: true)

        // Get background image.
        let imageBuffer = readImage(from: "/SD:/Christmas.bin")
        let backgroundTile = Tile(width: screen.width, height: screen.height, bind: imageBuffer)
        rootTile.append(backgroundTile)

        // The count of snowflakes.
        let snowCount = 120
        // The size of snowflakes.
        let snowSize = 11

        // Store the snowflake tiles to update their position later.
        var snowTiles: [Tile<UInt16>] = []

        // The position range for snowflakes.
        let positionRange = Array(0..<(screen.width-snowSize))

        // Initialize snowflakes.
        for _ in 0..<snowCount {
            let snowTile = createSnowTile(at: getRandomPos())
            snowTiles.append(snowTile)
            rootTile.append(snowTile)
        }

        // Buffer used to store bitmap info.
        var screenBuffer = [UInt16](repeating: 0, count: screen.width * screen.height)
        var lineBuffer = [UInt16](repeating: 0, count: screen.width * screen.height)

        // Store the bottom height to bank up snowflakes.
        var bottomY = [Int](repeating: screen.height - 1 - snowSize, count: screen.width)

        // Initialize the speaker.
        let speaker = I2SOut(Id.I2SOut0, rate: 16_000, channel: .stereo)
        // Initialize a player to play the music using generated audio data.
        let player = Player(speaker, sampleRate: 16_000)

        // Set the music player according to the music score.
        player.bpm = MerryChristmas.bpm
        player.timeSignature = MerryChristmas.timeSignature

//        player.bpm = JingleBells.bpm
//        player.timeSignature = JingleBells.timeSignature

        // Store the current note in the track.
        var noteIndex = 0

        while true {
            updateDisplay()

            // The snowflakes fall consistently.
            snow()

//            // The snowflakes fall in accordance witht the accelerations.
//            // Shake the board to restart the falling movement.
//            snowUsingAccelerometer()

            playMusic(
                MerryChristmas.track,
                waveform: MerryChristmas.trackWaveform,
                amplitudeRatio: MerryChristmas.amplitudeRatio
            )

//            playMusic(
//                JingleBells.track,
//                waveform: JingleBells.trackWaveform,
//                amplitudeRatio: JingleBells.amplitudeRatio
//            )
        }

        // Play music using its score.
        func playMusic(
            _ track: [Player.NoteInfo],
            waveform: Waveform,
            amplitudeRatio: Float
        ) {
            player.playNote(track[noteIndex], waveform: waveform, amplitudeRatio: amplitudeRatio)

            noteIndex += 1
            if noteIndex == track.count {
                noteIndex = 0
            }
        }

        // Generate starting position for snowflakes.
        func getRandomPos() -> Point {
            let x = positionRange.shuffled()[Int.random(in: positionRange.indices)]
            let y = positionRange.shuffled()[Int.random(in: positionRange.indices)]
            return (x, y)
        }

        // The snowflakes fall at a random speed to look more natural.
        // After reaching the bottom, they will be repositioned and fall again.
        func snow() {
            for snowTile in snowTiles {
                // Make the flake move down a bit each time.
                // The horizontal movement simulates the influence of air movements.
                var x = snowTile.x + Int.random(in: -1...1)
                var y = snowTile.y + Int.random(in: 1...3)

                // Kepp the flake within the screen.
                if x < 0 {
                    x = 0
                } else if x > screen.width - snowTile.width - 1 {
                    x = screen.width - snowTile.width - 1
                }

                // Update the flake's position after it's on the bottom.
                if y > screen.height - snowTile.height - 1 {
                    let pos = getRandomPos()
                    x = pos.x
                    y = pos.y
                }
                snowTile.move(to: (x, y))
            }
        }

        // The snowflakes fall and bank up on the bottom.
        // The speed depends on the accelerations.
        // You can shake the board back and forth to reposition the snowflakes and
        // make them fall again.
        func snowUsingAccelerometer() {
            let values = accelerometer.readXYZ()

            if values.y < -1 {
                snowTiles.forEach { $0.move(to: getRandomPos()) }
                for i in bottomY.indices {
                    bottomY[i] = screen.height - 1 - snowSize
                }
            } else {
                for snowTile in snowTiles {
                    if snowTile.y < bottomY[snowTile.x] {
                        let dx = Int(Float(Int.random(in: 1...3)) * -values.x)
                        let dy = Int(Float(Int.random(in: 1...3)) * values.y)

                        var x = snowTile.x + dx
                        var y = snowTile.y + dy

                        if x < 0 {
                            x = 0
                        } else if x > screen.width - snowTile.width - 1 {
                            x = screen.width - snowTile.width - 1
                        }

                        if y < 0 {
                            y = 0
                        } else if y >= bottomY[snowTile.x] {
                            y = bottomY[snowTile.x]
                            for i in x..<x+snowTile.width {
                                bottomY[i] = y - snowTile.height
                            }
                        }
                        snowTile.move(to: (x, y))
                    }
                }
            }
        }

        // Draw snowflakes.
        func createSnowTile(at point: Point) -> Tile<UInt16> {
            let bitmap = Bitmap<UInt16>(width: snowSize, height: snowSize)
            let color = Color.getRGB565LE(Color.white)
            for x in 0..<snowSize {
                bitmap.setPixel(at: (x, snowSize/2), color)
            }
            for y in 0..<snowSize {
                bitmap.setPixel(at: (snowSize/2, y), color)
                bitmap.setPixel(at: (y, y), color)
                bitmap.setPixel(at: (y, snowSize - 1 - y), color)
            }

            return Tile<UInt16>(at: point, bitmap: bitmap, chromaKey: 0)
        }

        // Update the display after snowflakes change their position.
        func updateDisplay() {
            var dirtyRegions: [Region] = []
            // Get the area that has been changed on the rootTile.
            rootTile.getRefreshRegions(into: &dirtyRegions)

            for dirtyRegion in dirtyRegions {
                // Update the buffer with the new pixel info.
                rootTile.update(region: dirtyRegion, into: &screenBuffer)

                // Get the necessary pixel data from the screenBuffer which stores
                // data for the entire tile.
                var count = 0
                for y in dirtyRegion.y..<(dirtyRegion.y + dirtyRegion.height) {
                    for x in dirtyRegion.x..<(dirtyRegion.x + dirtyRegion.width) {
                        lineBuffer[count] = screenBuffer[y * screen.width + x]
                        count += 1
                    }
                }

                // Send the data to the screen using SPI to update the specified area.
                lineBuffer.withUnsafeMutableBytes {
                    screen.writeBitmap(
                        x: dirtyRegion.x, y: dirtyRegion.y,
                        width: dirtyRegion.width, height: dirtyRegion.height,
                        data: UnsafeRawBufferPointer($0)
                    )
                }
            }
            // Reset all status of rootTile for next change.
            rootTile.finishRefresh()
        }

        // Read image from SD card.
        func readImage(from path: String) -> UnsafeBufferPointer<UInt16> {
            let widthMask = UInt32(0x7FF) << 10
            let heightMask = UInt32(0x7FF) << 21

            var header = UInt32(0)
            let headerSize = 4

            let file = FileDescriptor.open(path)
            defer { file.close() }

            withUnsafeMutableBytes(of: &header) {
                _ = file.read(into: $0, count: headerSize)
            }

            let width = (header & widthMask) >> 10
            let height = (header & heightMask) >> 21
            let bufferCount = Int(width * height)

            let buffer = UnsafeMutableBufferPointer<UInt16>.allocate(capacity: bufferCount)
            buffer.initialize(repeating: 0x0000)

            let rawBuffer = UnsafeMutableRawBufferPointer(buffer)

            _ = file.read(fromAbsoluteOffest: headerSize, into: rawBuffer, count: bufferCount * 2)

            return UnsafeBufferPointer(buffer)
        }
    }
}
