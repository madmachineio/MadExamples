// Measure the temperature and get an average reading after a button press.

// Import SwiftIO to use I2C communication and MadBoard to use pin id. 
import SwiftIO
import MadBoard
// Import SHT3x to use its functionalities to read values. 
import SHT3x


// Initialize the I2C interface and use it to initialize the sensor.
let i2c = I2C(Id.I2C0)
let humiture = SHT3x(i2c)

// Initialize the LED indicator pin.
let led = DigitalOut(Id.D18)
// Initialize the button pin.
let button = DigitalIn(Id.D1)

// Decide if it's time to read temperature.
var startMeasurement = false

while true {
    // If button is pressed, update the state.
    if button.read() {
        startMeasurement = true
    }

    // If the button has been pressed and is released, time to measure the temperature.
    if startMeasurement && !button.read() {
        // Turn on the LED as an indicator.
        led.high()
        // Read the value 20 times to calculate the average.
        var sum: Float = 0
        for _ in 0..<20 {
            sum += humiture.readCelsius()
            sleep(ms: 3)
        }
        let temperature = sum / 20.0
        let string = getFloatString(temperature)

        // Print the average temperature in celsius.
        print("Temperature: " + string + "C")
        startMeasurement = false
        // Turn off the indicator.
        led.low()
    }

    sleep(ms: 20)
}


func getFloatString(_ num: Float) -> String {
    let int = Int(num)
    let frac = Int((num - Float(int)) * 100)
    return "\(int).\(frac)"
}