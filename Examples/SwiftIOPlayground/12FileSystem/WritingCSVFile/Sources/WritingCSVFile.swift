import SwiftIO
import MadBoard
import SHT3x
import PCF8563

@main
public struct WritingCSVFile {
    public static func main() {
        let i2c = I2C(Id.I2C0)
        let humiture = SHT3x(i2c)
        let rtc = PCF8563(i2c)

        // Update the RTC time if it is not current.
        let currentTime = PCF8563.Time(
            year: 2024, month: 6, day: 3, hour: 15,
            minute: 0, second: 0, dayOfWeek: 0
        )
        rtc.setTime(currentTime)

        var written = false

        do {
            // Create a csv file on SD card.
            let file = try FileDescriptor.open("/SD:/temperature.csv", options: .create)
            // Create a table header.
            try file.write("Time, Temperature\n")   
            try file.close() 
        } catch {
            print(error)
        }

        while true {
            let time = rtc.readTime()

            // Read and store the temperature at the start of every minute.
            if time.second == 0 && !written {
                do {
                    let file = try FileDescriptor.open("/SD:/temperature.csv")
                    // Move file offset to the end in order to store new values.
                    try file.seek(offset: 0, from: FileDescriptor.SeekOrigin.end)

                    // Write time and temperature to the csv file.
                    // CSV uses commas to separate values and newlines to separate records. 
                    let temp = getFloatString(humiture.readCelsius())
                    let string = formatDateTime(time) + ", " + temp + "\n"
                    try file.write(string)

                    // Read the file content and print it out.
                    let size = try file.tell()
                    var buffer = [UInt8](repeating: 0, count: size)
                    try file.read(fromAbsoluteOffest: 0, into: &buffer)
                    print(String(decoding: buffer, as: UTF8.self))

                    try file.close() 
                } catch {
                    print(error)
                }
                written = true
            } else if time.second == 59 && written {
                written = false
            }
            
            sleep(ms: 10)
        }

        func formatNum(_ number: UInt8) -> String {
            return number < 10 ? "0\(number)" : "\(number)"
        }

        func formatDateTime(_ time: PCF8563.Time) -> String {
            var string = ""
            string += "\(time.year)" + "/" + formatNum(time.month) + "/" + formatNum(time.day) + " "
            string += formatNum(time.hour) + ":" + formatNum(time.minute) + ":" + formatNum(time.second)
            return string
        }

        func getFloatString(_ num: Float) -> String {
            let int = Int(num)
            let frac = Int((num - Float(int)) * 100)
            return "\(int).\(frac)"
        }
    }
}