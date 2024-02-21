import SwiftIO
import MadBoard
import ESP32ATClient
import ExtrasJSON

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

    // Print current Wi-Fi mode.
    wifiMode = try esp.getWiFiMode()
    print("ESP32 WiFi mode: \(wifiMode)")

    // Fill the SSID and password below.
    try esp.joinAP(ssid: "", password: "", timeout: 20000)
    print("ESP32 WiFi status: \(esp.wifiStatus)")

    // Print the assigned IP address.
    let ipInfo = try esp.getStationIP()
    print(ipInfo)
} catch {
    print("Error: \(error)")
}

sleep(ms: 1000)

if esp.wifiStatus == .ready {
    do {
        // Send request to the weather service to obtain current weather.
        // Update the URL with your API key and your city name.
        let response = try esp.httpGet(url: "https://api.openweathermap.org/data/2.5/weather?q=metric&q=YourCity&appid=YourAPIKey", timeout: 30000)

        // Decode the JSON data and print the weather info.
        let weatherInfo = try XJSONDecoder().decode(WeatherInfo.self, from: Array(response.utf8))
        print("City: \(weatherInfo.cityName)")
        print("Weather: \(weatherInfo.weatherConditions[0].main)")
        print("Temp: \(weatherInfo.mainInfo.temp)C")
        print("Humidity: \(weatherInfo.mainInfo.humidity)")
    } catch let error as DecodingError {
        print("JSON Decoding Error: \(error)")
    } catch {
        print("Http GET Error: \(error)")
    }
} else {
    _ = try? esp.readLine(timeout: 1000)
    print("WiFi status: \(esp.wifiStatus)")
}

while true {
    sleep(ms: 1000)
}