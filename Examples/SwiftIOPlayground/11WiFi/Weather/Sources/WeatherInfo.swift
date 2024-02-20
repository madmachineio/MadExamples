// Structs used to decode the JSON data from the weather service.
struct Coordinate: Decodable {
    let longitude: Float
    let latitude: Float

    enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
}

struct WeatherConditions: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct MainInfo: Decodable {
    let temp: Float
    let feelsLikeTemp: Float
    let minTemp: Float
    let maxTemp: Float
    let pressure: Int
    let humidity: Int
    let seaLevel: Int
    let groundLevel: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLikeTemp = "feels_like"
        case minTemp = "temp_min"
        case maxTemp = "temp_max"
        case pressure
        case humidity
        case seaLevel = "sea_level"
        case groundLevel = "grnd_level"
    }
}

struct Wind: Decodable {
    let speed: Float
    let degree: Int
    let gust: Float

    enum CodingKeys: String, CodingKey {
        case speed
        case degree = "deg"
        case gust
    }
}

struct Clouds: Decodable {
    let cloudiness: Int

    enum CodingKeys: String, CodingKey {
        case cloudiness = "all"
    }
}

struct Rain: Decodable {
    let rain1h: Float?
    let rain3h: Float?

    enum CodingKeys: String, CodingKey {
        case rain1h = "1h"
        case rain3h = "3h"
    }
}

struct Snow: Decodable {
    let snow1h: Float?
    let snow3h: Float?

    enum CodingKeys: String, CodingKey {
        case snow1h = "1h"
        case snow3h = "3h"
    }
}

struct Sys: Decodable {
    let type: Int?
    let id: Int?
    let country: String
    let sunrise: Int
    let sunset: Int
}

struct WeatherInfo: Decodable {
    let coordinate: Coordinate
    let weatherConditions: [WeatherConditions]
    let base: String
    let mainInfo: MainInfo
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let rain: Rain?
    let snow: Snow?
    let dt: Int
    let sys: Sys
    let timezone: Float
    let cityId: Int
    let cityName: String
    let cod: Int


    enum CodingKeys: String, CodingKey {
        case coordinate = "coord"
        case weatherConditions = "weather"
        case base
        case mainInfo = "main"
        case visibility
        case wind
        case clouds
        case rain
        case snow
        case dt
        case sys
        case timezone
        case cityId = "id"
        case cityName = "name"
        case cod
    }
}