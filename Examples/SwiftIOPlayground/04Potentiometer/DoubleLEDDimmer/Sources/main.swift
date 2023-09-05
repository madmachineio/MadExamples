// In this project, two potentiometers control the LED brightness.
// One controls the maximum intensity and the other adjusts the brightness between the minimum and the maximum.

// Import SwiftIO to control input and output.
import SwiftIO
// Import MadBoard to use the pin ids.
import MadBoard


// Initialize the analog pin used to adjust LED brightness from min and max.
let brightnessPot = AnalogIn(Id.A0)
// Initialize the analog pin used to set max brightness. 
let intensityPot = AnalogIn(Id.A11)
// Initialize the PWM pin for the LED.
let led = PWMOut(Id.PWM4A)

// Define the available range of max duty cycle adjusted by A11. 
let minIntensity: Float = 0.2
let maxIntensity: Float = 1

while true {
    // Map the analog value from the range 0-1 to the range minIntensity-maxIntensity. 
    // It decides the max duty cycle for the PWM signal.
    // That's to say, it changes the maximum intensity of the LED.
    let maxDutycycle = intensityPot.readPercent() * (maxIntensity - minIntensity) + minIntensity

    // Read the analog value (0-1) from the pin A0 which serves as ratio for final duty cycle.
    let dutycycleRatio = brightnessPot.readPercent()

    // Calculate the final duty cycle value (0-maxDutycycle).
    // Set the PWM output using the result.
    led.setDutycycle(dutycycleRatio * maxDutycycle)
    sleep(ms: 20)
}
