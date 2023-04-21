// Send message from computer to USB-Serial converter using serial monitor. 
// Then send the message back using UART.
import SwiftIO
import MadBoard

@main
public struct C02S01SerialEcho {
    public static func main() {
        let uart = UART(Id.UART0)

        var buffer = [UInt8](repeating: 0, count: 100)

        while true {
            // Check if there is available data in the UART buffer.
            let count = uart.checkBufferReceived()

            if count > 0 {
                for i in buffer.indices {
                    buffer[i] = 0
                }
                // Read data from the buffer.
                uart.read(into: &buffer, count: count)
                // Send the message back. 
                uart.write(Array(buffer[0..<count]))
            }
            
            sleep(ms: 10)
        }
    }
}
