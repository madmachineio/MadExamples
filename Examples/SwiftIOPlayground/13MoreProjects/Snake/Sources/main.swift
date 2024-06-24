// Import SwiftIO to set the communication and MadBoard to use pin id. 
import SwiftIO
import MadBoard
// Import the library to configure the LCD and write pixels on it.
import ST7789

// Initialize the SPI pin and the digital pins for the LCD.
let bl = DigitalOut(Id.D2)
let rst = DigitalOut(Id.D12)
let dc = DigitalOut(Id.D13)
let cs = DigitalOut(Id.D5)
let spi = SPI(Id.SPI0, speed: 30_000_000)

// Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

// Initialize the two buttons for changing the snake's direction.
let clockwiseButton = DigitalIn(Id.D1)
let anticlockwiseButton = DigitalIn(Id.D19)

var clockwisePressCount = 0
var anticlockwisePressCount = 0

var snake = Snake(screen: screen)

while true {
    if !snake.end {
        // If a button is pressed, the snake's direction will change accordingly,
        if clockwisePressCount > 25 && !clockwiseButton.read() {        
            snake.setSpeed(clockwise: true)
            clockwisePressCount = 0
        }

        if clockwiseButton.read() {
            clockwisePressCount += 1
        } else {
            clockwisePressCount = 0
        }

        if anticlockwisePressCount > 25 && !anticlockwiseButton.read() {        
            snake.setSpeed(clockwise: false)
            anticlockwisePressCount = 0
        }

        if anticlockwiseButton.read() {
            anticlockwisePressCount += 1
        } else {
            anticlockwisePressCount = 0
        }

        snake.play()
    }
    
    sleep(ms: 2)
}