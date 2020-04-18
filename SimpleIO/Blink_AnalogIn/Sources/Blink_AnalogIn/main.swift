/// Read the analog input and use it to set the rate of LED blink.

/// Import the library to enable the relevant classes and functions.
import SwiftIO

/// Initialize an analog input and a digital output pin the components are connected to,
let sensor = AnalogIn(.A0)
let led = DigitalOut(.D0)

/// Enable the LED to blink over and over again.
while true {
    // Read the input voltage in percentage.
    let value = sensor.readRawValue()
    // Change the current LED state.
    led.toggle()
    // Keep the led on or off for a certain period determined by the value you get.
    sleep(ms: value)
}

