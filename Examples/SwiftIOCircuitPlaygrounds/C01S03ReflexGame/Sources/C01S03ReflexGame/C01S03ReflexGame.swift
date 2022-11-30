import SwiftIO
import MadBoard

@main
public struct C01S03ReflexGame {
    public static func main() {
        let startButton = DigitalIn(Id.D1)
        let player = DigitalIn(Id.D21)
        let buzzer = PWMOut(Id.PWM5A)
        let led = DigitalOut(Id.D19)

        while true {
            // Press the start button to begin the game.
            if startButton.read() {
                // A beep as a notification.
                buzzer.set(frequency: 500, dutycycle: 0.5)
                sleep(ms: 500)
                buzzer.suspend()

                // Wait for several seconds before the game starts.
                sleep(ms: 1000 * Int.random(in: 1...5))

                // Turn on the red LED as a sign of start.
                led.high()
                // Store the current clock cycle.
                let startTime = getClockCycle()

                // Wait until the button is pressed.
                while !player.read() {

                }

                // Calculate the time in ns.
                let finalTime = cyclesToNanoseconds(start: startTime, stop: getClockCycle())
                // Turn off the indicator.
                led.low()
                print("Reflex time: \(Float(finalTime) / 1000_000)ms")
            }

            sleep(ms: 10)
        }
    }
}
