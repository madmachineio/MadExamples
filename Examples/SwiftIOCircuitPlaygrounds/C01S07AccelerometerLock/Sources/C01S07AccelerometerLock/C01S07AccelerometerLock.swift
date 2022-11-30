// Unlock to turn on the LED.
// The password consits of 3 tilt directions (left/right/forward/back).
// Any wrong direction will restart the game.

// Import SwiftIO to set the communication and MadBoard to use pin id. 
import SwiftIO
import MadBoard
// Import LIS3DH to read the accelerations from the sensor.
import LIS3DH

@main
public struct C01S07AccelerometerLock {
    public static func main() {
        // Initialize the I2C pins and the sensor.
        let i2c = I2C(Id.I2C0)
        let acc = LIS3DH(i2c)

        let led = DigitalOut(Id.D19)
        let buzzer = PWMOut(Id.PWM5A)


        let timer = Timer(period: 60_000)

        var directions = [Direction](repeating: .left, count: 3)

        updateDirections()

        var currentIndex = 0

        var reset = false

        timer.setInterrupt() {
            reset = true
        }

        while true {
            if currentIndex < directions.count {
                if let direction = getDirection(acc.readXYZ()) {
                    if direction == directions[currentIndex] {
                        currentIndex += 1
                        print("Correct! Next direction...")
                        
                        led.high()
                        sleep(ms: 1000)
                        led.low()
                    } else {
                        currentIndex = 0
                        print("Wrong direction. Restart...")
                    }
                }
            } else if currentIndex == directions.count {
                led.high()
                print("Unlocked!")
                
                buzzer.set(frequency: 500, dutycycle: 0.5)
                sleep(ms: 300)
                buzzer.suspend()

                currentIndex = directions.count + 1
            }

            if reset {
                currentIndex = 0
                reset = false
                updateDirections()
                print("Timeout. Directions are reset.")
            }

            sleep(ms: 20)
        }

        func updateDirections() {
            for i in 0..<3 {
                let rawValue = Int.random(in: 0..<4)
                print(rawValue)

                directions[i] = Direction(rawValue: rawValue)!
            }
        }


        func getDirection(_ values: (x: Float, y: Float, z: Float)) -> Direction? {
            if values.x > 0.5 {
                return .left
            } else if values.x < -0.5 {
                return .right
            }

            if values.y > 0.5 {
                return .back
            } else if values.y < -0.5 {
                return .forward
            } 

            return nil
        }

        enum Direction: Int {
            case left
            case right
            case forward
            case back
        }
    }
}
