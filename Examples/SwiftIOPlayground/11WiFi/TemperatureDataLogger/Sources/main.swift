import SwiftIO
import MadBoard
import ESP32ATClient
import SHT3x

let rst = DigitalOut(Id.D24, value: true)
let uart = UART(Id.UART1, baudRate: 115200)
let esp = ESP32ATClient(uart: uart, rst: rst)

let i2c = I2C(Id.I2C0)
let humiture = SHT3x(i2c)

do {
    // If reset failed, you might need to adjust the baudrate.
    try esp.reset()
    print("ESP32 status: \(esp.esp32Status)")

    // Only in 'Station' or 'Station+SoftAP' mode can a connection to an AP be established.
    var wifiMode = ESP32ATClient.WiFiMode.station
    _ = try esp.setWiFiMode(wifiMode)

    wifiMode = try esp.getWiFiMode()
    print("ESP32 WiFi mode: \(wifiMode)")

    // Fill the SSID and password below.
    try esp.joinAP(ssid: "", password: "", timeout: 20000)
    print("ESP32 WiFi status: \(esp.wifiStatus)")

    let ipInfo = try esp.getStationIP()
    print(ipInfo)
} catch {
    print("Error: \(error)")
}

while true {
    sleep(ms: 30_000)
    if esp.wifiStatus == .ready {
        do {
            // Read temperature and humidity values from the sensor.
            let temp = humiture.readCelsius()
            let humidity = humiture.readHumidity()
            // Send the values to ThingSpeak using HTTP POST requests to visualize them.
            _ = try esp.httpPost(url: "https://api.thingspeak.com/update?api_key=WCGQWXCBJA2WS03F&field1=\(temp)&field2=\(humidity)", headers: ["Content-Type: application/x-www-form-urlencoded"], timeout: 20000)
        } catch {
            print("Http POST Error: \(error)")
        }
    } else {
        _ = try? esp.readLine(timeout: 1000)
        print("WiFi status: \(esp.wifiStatus)")
    }
}