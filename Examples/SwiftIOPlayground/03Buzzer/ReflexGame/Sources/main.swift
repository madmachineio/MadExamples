// Press the button D1 to start the game.
// Once you see the red LED turns on, press the button D19 immediately.
// Then the LED turns off and you can see your reflex time in serial monitor.
// To restart the game, press button D1 again.

import SwiftIO
import MadBoard


let startButton = DigitalIn(Id.D1)
let player = DigitalIn(Id.D19)
let buzzer = PWMOut(Id.PWM5A)
let led = DigitalOut(Id.D18)

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
        let startClockCycle = getClockCycle()

        // Wait until the button is pressed.
        while !player.read() {
            sleep(ms: 1)
        }

        // Calculate the time in ns.
        let ns = cyclesToNanoseconds(start: startClockCycle, stop: getClockCycle())
        let duration = ns / 1000_000

        // Turn off the indicator.
        led.low()
        print("Reflex time: \(duration)ms")
    }

    sleep(ms: 10)
}