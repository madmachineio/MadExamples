import SwiftIO
import MadBoard
import ESP32ATClient

let rst = DigitalOut(Id.D24, value: true)
let uart = UART(Id.UART1, baudRate: 115200)
let esp = ESP32ATClient(uart: uart, rst: rst)

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
    try esp.joinAP(ssid: "TP-LINK_CD1C", password: "q1w2e3r4", timeout: 20000)
    print("ESP32 WiFi status: \(esp.wifiStatus)")

    let ipInfo = try esp.getStationIP()
    print(ipInfo)
} catch {
    print("Error: \(error)")
}

while true {
    sleep(ms: 1000)
}