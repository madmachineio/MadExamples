// Set an alarm. It will go off at the specified time.
// You can press the button to stop the sound.

import SwiftIO
import MadBoard
import PCF8563


let i2c = I2C(Id.I2C0)
let rtc = PCF8563(i2c)

let led = DigitalOut(Id.D18)
let buzzer = PWMOut(Id.PWM5A)

// Stop the alarm after it goes off.
let stopButton = DigitalIn(Id.D1)

let daysOfWeek = [
    "Monday", "Tuesday", "Wednesday",
    "Thursday", "Friday", "Saturday",
    "Sunday"
]

// Set the alarm time.
let alarm = AlarmTime(hour: 10, minute: 40)
// Calculate the time when the alarm will stop sounding.
let stopAlarm = getStopAlarm(alarm, after: 1)
var isAlarmed = false


while true {
    let time = rtc.readTime()

    if isAlarmed {
        // After the alarm clock goes off, 
        // if it's time to stop sounding or you press the stop button,
        // stop the sound and turn off the LED.
        if stopAlarm.isTimeUp(time) || stopButton.read() {
            print("Current time: " + formatDateTime(time))
            led.low()
            buzzer.suspend()
            isAlarmed = false
        }
    } else {
        // If the time comes, start the sound and turn on the LED.
        if alarm.isTimeUp(time) {
            print("Current time: " + formatDateTime(time))
            led.high()
            buzzer.set(frequency: 500, dutycycle: 0.5)
            isAlarmed = true
        }
    }

    sleep(ms: 10)
}

// Add leading zero if number is one-digit.
// For example, number 1 will be 01.
func formatNum(_ number: UInt8) -> String {
    return number < 10 ? "0\(number)" : "\(number)"
}

// Format the date and time, i.e. 2023/03/01 Wednesday 16:20:00.
func formatDateTime(_ time: PCF8563.Time) -> String {
    var string = ""
    string += "\(time.year)" + "/" + formatNum(time.month) + "/" + formatNum(time.day)
    string += " " + daysOfWeek[Int(time.dayOfWeek)] + " "
    string += formatNum(time.hour) + ":" + formatNum(time.minute) + ":" + formatNum(time.second)
    return string
}

// Calculate the time for alarm to stop sounding after specified minutes.
func getStopAlarm(_ alarm: AlarmTime, after min: Int) -> AlarmTime {
    var stopMinute = alarm.minute + min
    var stopHour = alarm.hour

    if stopMinute >= 60 {
        stopMinute -= 60
        stopHour = stopHour == 23 ? 0 : stopHour + 1
    }

    return AlarmTime(hour: stopHour, minute: stopMinute)
}

struct AlarmTime {
    let hour: Int
    let minute: Int

    // Check if the set time comes.
    func isTimeUp(_ time: PCF8563.Time) -> Bool {
        return time.hour == hour && time.minute == minute && time.second == 0
    }
}