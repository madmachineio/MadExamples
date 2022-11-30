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
        var blinkCount = 0

        var patternIndex = 0
        var changePattern = false

        // Set the duty cycle depending on the pattern.
        resetDutycycle()

        // Button states for debounce.
        var detected = false
        var releaseDuration = 0
        let debounceDuration = 40

        // If the button is pressed and released, change to the next pattern.
        button.setInterrupt(.falling) {
            detected = true
        }

        while true { 
            if changePattern {
                // Reset the duty cycle after changing the pattern.
                resetDutycycle()
            } else {
                // Update duty cycle depending on the current LED pattern.
                updateDutycycle()
            }
            
            // Set the PWM with the given duty cycle to change LED brightness.
            led.setDutycycle(dutycycle)
            sleep(ms: duration) 

            // Debounce.
            if detected {
                releaseDuration += duration
            }

            if releaseDuration == debounceDuration {
                releaseDuration = 0
                detected = false

                // Update pattern index.
                changePattern = true
                patternIndex += 1
                if patternIndex == 4 { 
                    patternIndex = 0
                }
            }
        }

        func resetDutycycle() {
            switch patternIndex {
            case 0: 
                dutycycle = minDutycycle
            case 1: 
                dutycycle = maxDutycycle
            case 2:  
                dutycycle = maxDutycycle
                blinkCount = 0
            case 3: 
                dutycycle = minDutycycle
                stepDutycycle = abs(stepDutycycle)
            default: break
            }

            changePattern = false
        }

        
        func updateDutycycle() {
            switch patternIndex {
            case 2: 
                // Blink LED.
                // The duty cycle changes between 0.0 and 1.0 to turn off and on the LED in turn.
                blinkCount += 1
                dutycycle = blinkCount % 100 < (blinkPeriod / 2 / duration) ? maxDutycycle : minDutycycle
            case 3: 
                // Fade LED.
                // The duty cycle gradually increases to the maximum, then decrease to the mininum.
                // Therefore, the LED brightens and dims in turn.
                dutycycle += stepDutycycle
            
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
    }
}
