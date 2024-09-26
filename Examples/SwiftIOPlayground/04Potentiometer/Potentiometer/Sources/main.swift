// Import SwiftIO library to control input and output, and MadBoard to use the pin name.
import SwiftIO
import MadBoard


// Initialize the analog pin A0 for the potentiometer.
let pot = AnalogIn(Id.A0)

// Read the voltage value and print it out every second.
while true {
    let potVoltage = getFloatString(pot.readVoltage())
    print(potVoltage)
    sleep(ms: 1000)
}


func getFloatString(_ num: Float) -> String {
    let int = Int(num)
    let frac = Int((num - Float(int)) * 100)
    return "\(int).\(frac)"
}