// Unlock to turn on the LED.
// The password consits of 3 random tilt directions (left/right/forward/backward).
// Tilt your board and try to guess the password.
// The LED turns on for 1s as an indicator if a move matches.
// Any unmatched move will cause the game to restart.
// After time is up and you haven't unlock it, the password will be changed.

// Import SwiftIO to set the communication and MadBoard to use pin id. 
import SwiftIO
import MadBoard
// Import LIS3DH to read the accelerations from the sensor.
import LIS3DH

@main
public struct AccelerometerLock {
    public static func main() {
        // Initialize the I2C pins and the sensor.
        let i2c = I2C(Id.I2C0)
        let acc = LIS3DH(i2c)

        // Initialize LED and buzzer as indicators.
        let led = DigitalOut(Id.D18)
        let buzzer = PWMOut(Id.PWM5A)

        // Initialize the button to change the password.
        let resetButton = DigitalIn(Id.D1)

        // Initialize the timer with time limit of 30ms.
        let timer = Timer(period: 30_000)

        // Generate 3 random tilt directions as the password.
        var password = [Direction](repeating: .left, count: 3)
        updatePassword()

        // Keep track of the index of direction.
        var currentIndex = 0

        var reset = false
        var start = false

        // If time is up, reset the game.
        timer.setInterrupt(start: false) {
            reset = true
        }

        print("Tilt/move your board to start.")

        while true {
            if currentIndex < password.count {
                if let direction = getDirection(acc.readXYZ()) {
                    // After the first movement, start the timer.
                    if !start {
                        timer.start()
                        start = true
                    }

                    // If the movement matches the desired one, generate a beep as an indicator.
                    if direction == password[currentIndex] {
                        currentIndex += 1
                        print("Correct!")
                        beep(500)
                    } else {
                        // If not, restart from the first direction.
                        currentIndex = 0
                        print("Wrong! Restart from the first one...")
                    }
                }
            } else if currentIndex == password.count {
                // If all 3 directions are matched, turn on the LED.
                led.high()
                print("Unlocked!")
                timer.stop()
                // End the game.
                currentIndex += 1
            }

            // If reset button is pressed, it's time to reset the game.
            if resetButton.read() {
                reset = true
            }

            // Generate 3 random directions as a new password and reset the game.
            // The buzzer will beep as an indicator.
            if reset {
                updatePassword()
                timer.stop()

                currentIndex = 0
                start = false
                reset = false

                led.low()
                beep(1000)

                print("Timeout or reset button is pressed. Password is reset. Tilt/move your board to restart.")
            }

            sleep(ms: 20)
        }

        // Generate a short beep. 
        func beep(_ fre: Int) {
            buzzer.set(frequency: fre, dutycycle: 0.5)
            sleep(ms: 300)
            buzzer.suspend()
        }

        // Replace the previous password with a new one. 
        func updatePassword() {
            for i in 0..<password.count {
                password[i] = Direction(rawValue: Int.random(in: 0..<4))!
            }
        }

        // Decide the tilt direction depending on the xyz accelerations.
        func getDirection(_ values: (x: Float, y: Float, z: Float)) -> Direction? {
            if values.x > 0.5 {
                return .left
            } else if values.x < -0.5 {
                return .right
            }

            if values.y > 0.5 {
                return .backward
            } else if values.y < -0.5 {
                return .forward
            } 

            return nil
        }

        enum Direction: Int {
            case left
            case right
            case forward
            case backward
        }
    }
}
