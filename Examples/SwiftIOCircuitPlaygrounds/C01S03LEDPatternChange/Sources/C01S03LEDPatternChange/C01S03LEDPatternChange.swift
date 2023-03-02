// Switch the LED pattern by pressing the button.
// The LED patterns are: constant off, constant on, blink, breathing.

import SwiftIO
import MadBoard

@main
public struct C01S03LEDPatternChange {
    public static func main() {
        let led = PWMOut(Id.PWM4A)
        let button = DigitalIn(Id.D1)

        // Store the maximum and minimum values of the duty cycle to two constants. 
        let maxDutycycle: Float = 1.0
        let minDutycycle: Float = 0.0

        var dutycycle: Float = 0.0
        var stepDutycycle: Float = 0.01

        // The duration in ms of each loop.
        let duration = 10
        // Make the LED on for 500ms and off for 500ms.
        let blinkPeriod = 1000
        var blinkTime = 0

        var patternIndex = 0
        var changePattern = false

        // Set the duty cycle depending on the pattern.
        resetDutycycle()

        var pressed = false

        // If the button is pressed and released, change to the next pattern.
        button.setInterrupt(.falling) {
            pressed = true
        }

        while true { 
            if changePattern {
                // Reset the duty cycle after changing the pattern.
                resetDutycycle()
                changePattern = false
            } else {
                // Update duty cycle depending on the current LED pattern.
                updateDutycycle()
            }
            
            // Set the PWM with the given duty cycle to change LED brightness.
            led.setDutycycle(dutycycle)
            sleep(ms: duration) 

            // Update pattern index after button is pressed and released.
            if pressed {
                changePattern = true
                patternIndex += 1
                if patternIndex == LEDPattern.allCases.count { 
                    patternIndex = 0
                }

                pressed = false
            }
        }

        // Reset the duty cycle for a new LED pattern.
        func resetDutycycle() {
            switch LEDPattern(rawValue: patternIndex)! {
            case .off: 
                dutycycle = minDutycycle
            case .on: 
                dutycycle = maxDutycycle
            case .blink:  
                dutycycle = maxDutycycle
                blinkTime = 0
            case .breathing: 
                dutycycle = minDutycycle
                stepDutycycle = abs(stepDutycycle)
            }  
        }
        
        // Update the duty cycle of the PWM signal according to the current LED pattern.
        func updateDutycycle() {
            switch LEDPattern(rawValue: patternIndex)! {
            case .blink: 
                // For the first half of blinkPeriod, turn on the LED.
                // For the second half of blinkPeriod, turn off the LED.
                // The duty cycle changes between 0.0 and 1.0 to turn on and off the LED in turn.
                blinkTime += duration
                dutycycle = blinkTime % blinkPeriod < (blinkPeriod / 2) ? maxDutycycle : minDutycycle
            case .breathing: 
                // The duty cycle gradually increases to the maximum, then decrease to the mininum.
                // Therefore, the LED brightens and dims in turn.
                dutycycle += stepDutycycle
            
                // Check if LED brightness is increaed to the max or decreased to min. 
                if stepDutycycle > 0 && dutycycle >= maxDutycycle {
                    stepDutycycle.negate()
                    dutycycle = maxDutycycle
                } else if stepDutycycle < 0 && dutycycle <= minDutycycle {
                    stepDutycycle.negate()
                    dutycycle = minDutycycle
                }
            default: break
            }
        }

        enum LEDPattern: Int, CaseIterable {
            case off
            case on
            case blink
            case breathing
        }
    }
}
