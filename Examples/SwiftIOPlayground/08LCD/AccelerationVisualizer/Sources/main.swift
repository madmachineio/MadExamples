// Visualize the x, y , z accelerations in the range by moving the corresponding sliders.

import SwiftIO
import MadBoard
import LIS3DH
import ST7789


// Initialize the SPI pin and the digital pins for the LCD.
let spi = SPI(Id.SPI0, speed: 30_000_000)
let cs = DigitalOut(Id.D5)
let dc = DigitalOut(Id.D4)
let rst = DigitalOut(Id.D3)
let bl = DigitalOut(Id.D2)
// Initialize the LCD using the pins above. Rotate the screen to keep the original at the upper left.
let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

// Initialize the accelerometer using I2C communication.
let i2c = I2C (Id.I2C0)
let accelerometer = LIS3DH(i2c)

// 16-bit colors for acceleration bars.
let red: UInt16 = 0x07E0
let green: UInt16 = 0x001F
let blue: UInt16 = 0xF800

// Get the acceleration range of the sensor.
let gRange: Int
switch accelerometer.getRange() {
case .g2: gRange = 4
case .g4: gRange = 8
case .g8: gRange = 16
case .g16: gRange = 32
}

// Draw the bars of accelerations on x, y, z-axis.
let barWidth = 200
let barHeight = 40
let spacer = 20
let startY = (screen.height - barHeight * 3 - spacer * 2) / 2

var xBar = Bar(y: startY, width: barWidth, height: barHeight, color: red, screen: screen)
var yBar = Bar(y: startY + barHeight + spacer, width: barWidth, height: barHeight, color: green, screen: screen)
var zBar = Bar(y: startY + (barHeight + spacer) * 2, width: barWidth, height: barHeight, color: blue, screen: screen)

while true {
    // Update the indicators' position in each bar according to the current accelerations.
    let values = accelerometer.readXYZ()
    xBar.update(values.x, gRange: gRange)
    yBar.update(values.y, gRange: gRange)
    zBar.update(values.z, gRange: gRange)
    sleep(ms: 10)
}