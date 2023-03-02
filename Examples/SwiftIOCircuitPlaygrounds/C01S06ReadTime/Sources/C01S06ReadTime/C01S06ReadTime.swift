// Read current time from the RTC and print it every second.

import SwiftIO
import MadBoard
import PCF8563

@main
public struct C01S06ReadTime {
    public static func main() {
        let i2c = I2C(Id.I2C0)
        let rtc = PCF8563(i2c)

        let daysOfWeek = [
            "Monday", "Tuesday", "Wednesday",
            "Thursday", "Friday", "Saturday",
            "Sunday"
        ]

        // Please use current time to adjust the RTC time if it has been lost power.
        // The day of week is from 0 to 6. In this case, 0 refers to Monday.
        let currentTime = PCF8563.Time(
            year: 2023, month: 3, day: 1, hour: 16,
            minute: 20, second: 0, dayOfWeek: 2
        )
        // If the RTC has lost power, its time will be updated.
        // If not, its time should be accurate and thus won't be changed.
        // If you indeed need to adjust it, set the parameter `update` to `true`.
        // rtc.setTime(currentTime, update: true)
        rtc.setTime(currentTime)

        while true {
            let time = rtc.readTime()
            print(formatDateTime(time))
            sleep(ms: 1000)
        }

        // Add leading zero if number is one-digit.
        // For example, number 1 will be 01.
        func format(_ number: UInt8) -> String {
            return number < 10 ? "0\(number)" : "\(number)"
        }

        // Format the date and time, i.e. 2023/03/01 Wednesday 16:20:00.
        func formatDateTime(_ time: PCF8563.Time) -> String {
            var string = ""
            string += "\(time.year)" + "/" + format(time.month) + "/" + format(time.day)
            string += " " + daysOfWeek[Int(time.dayOfWeek)] + " "
            string += format(time.hour) + ":" + format(time.minute) + ":" + format(time.second)
            return string
        }
    }
}
