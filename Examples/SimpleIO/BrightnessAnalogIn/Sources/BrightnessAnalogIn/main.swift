// Read the analog input value and use it to set the PWM output in order to change the LED brightness.

// Import the library to enable the relevant classes and functions.
import SwiftIO
import MadBoard

// Initialize an analog input and a digital output pin the components are connected to.
let sensor = AnalogIn(Id.A0)
let led = PWMOut(Id.PWM0A)

// Allow the LED brightness control all the time.
while true {
    // Read the input voltage in percentage.
    let value = sensor.readPercent()
    // Light the LED by setting the duty cycle.
    led.setDutycycle(value)
    // Keep the current LED state for 200 millisecond.
    sleep(ms: 200)
}

