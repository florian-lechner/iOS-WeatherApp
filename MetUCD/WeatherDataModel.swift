//
//  WeatherDataModel.swift
//  MetUCD
//
//  Created by Instructor on 20/09/2023.
//

import Foundation

// MARK: - WeatherDataModel

struct WeatherDataModel {
    private(set) var geoLocationData: GeoLocationData?
    private(set) var weatherData: WeatherData?
    private(set) var airQualityData: AirQualityData?
    private(set) var forecastData: FiveDayForecastData?
    
    private mutating func clear() {
        geoLocationData = nil
        weatherData = nil
        airQualityData = nil
    }
    
    mutating func fetch(for location: String) async {
        clear()
        geoLocationData = await OpenWeatherMapAPI.geoLocation(for: location, countLimit: 1)
        if let geoLocations = geoLocationData, let location = geoLocations.first {
            weatherData = await OpenWeatherMapAPI.weatherData(lat: location.lat, lon: location.lon)
            airQualityData = await OpenWeatherMapAPI.airQualityData(lat: location.lat, lon: location.lon)
            forecastData = await OpenWeatherMapAPI.fiveDayForecastData(lat: location.lat, lon: location.lon)
        }
    }
}


// MARK: - Partial support for OpenWeatherMap API 2.5 (free api access)

struct OpenWeatherMapAPI {
    private static let apiKey = "9da9f82859403020726cf6504305fa97"
    private static let baseURL = "https://api.openweathermap.org/"

    // Async fetch from OpenWeatherMap
    private static func fetch<T: Decodable>(from apiString: String, asType type: T.Type) async throws -> T {
        guard let url = URL(string: "\(Self.baseURL)\(apiString)&appid=\(Self.apiKey)") else { throw NSError(domain: "Bad URL", code: 0, userInfo: nil) }
        let (data, _) =  try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data)
    }

    // MARK: - Public API
    
    static func geoLocation(for location: String, countLimit count: Int) async -> GeoLocationData? {
        let apiString = "geo/1.0/direct?q=\(location)&limit=\(count)"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: GeoLocationData.self)
    }
    
    static func weatherData(lat: Double, lon: Double) async -> WeatherData? {
        let apiString = "data/2.5/weather?lat=\(lat)&lon=\(lon)&units=metric"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: WeatherData.self)
        
    }
    
    static func fiveDayForecastData(lat: Double, lon: Double) async -> FiveDayForecastData? {
        let apiString = "data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=metric"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: FiveDayForecastData.self)
        
    }
    
    static func airQualityData(lat: Double, lon: Double) async -> AirQualityData? {
        let apiString = "data/2.5/air_pollution/forecast?lat=\(lat)&lon=\(lon)"
        do {
            let response: AirPollutionResponse = try await fetch(from: apiString, asType: AirPollutionResponse.self)
            return response.list.first
        } catch {
            print("Error fetching air quality data: \(error)")
            return nil
        }
    }
    
}


// MARK: - GeoLocationData

typealias GeoLocationData = [GeoLocation]


// MARK: - GeoLocation

struct GeoLocation: Codable, CustomStringConvertible {
    let name: String // Name of the found location
    let localNames: [String: String]? // Name of the found location in different languages. The list of names can be different for different locations
    let lat, lon: Double // Geographical coordinates of the found location (latitude, longitude)
    let country: String // Country of the found location
    let state: String? // (where available) State of the found location
    
    var description: String {
        ["location: \(name), \(country)", "lat: \(lat)", "lon: \(lon)"].joined(separator: "\n")
    }
}


// MARK: - WeatherData Components

struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct Clouds: Codable {
    let all: Int
}

struct Sys: Codable {
    let sunrise: Int
    let sunset: Int
    
}

// MARK: - Weather Data

struct WeatherData: Codable, CustomStringConvertible {
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let clouds: Clouds
    let sys: Sys
    let timezone: Int
        
    var description: String {
        return weather.first?.description ?? "N/A"
    }
}

// MARK: - Five Day Forecast Data

struct FiveDayForecastData: Codable {
    let list: [ForecastItem]

    struct ForecastItem: Codable {
        let dt: Int
        let main: Main
        let weather: [Weather]
        let clouds: Clouds
        let wind: Wind
        let dtTxt: String
    }
}

struct WeatherUtils {
    static func convertDegreesToCardinalDirection(_ degrees: Int) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"]
        let index = Int((Double(degrees) + 22.5) / 45.0) & 7
        return directions[index]
    }
}



// MARK: - Air Quality

struct AirPollutionResponse: Codable {
    let list: [AirQualityData]
}

struct AirQualityData: Codable, CustomStringConvertible {
    let main: Main
    let components: Components

    struct Main: Codable {
        let aqi: Int
    }

    struct Components: Codable {
        let co: Double
        let no: Double
        let no2: Double
        let o3: Double
        let so2: Double
        let pm25: Double
        let pm10: Double
        let nh3: Double
    }
    
    var description: String {
        return aqiDescription(main.aqi)
    }
    
    // Convert index to string description
    private func aqiDescription(_ index: Int) -> String {
            switch index {
            case 1:
                return "Good"
            case 2:
                return "Fair"
            case 3:
                return "Moderate"
            case 4:
                return "Poor"
            case 5:
                return "Very Poor"
            default:
                return "Unknown"
            }
        }
}

// MARK: Structure for Date in View

struct GeoInfo {
    var latitude: String
    var longitude: String
    var sunrise: Array<String>
    var sunset: Array<String>
    var timezoneOffset: String
}


struct WeatherInfo {
    var description: String
    var currentTemp: String
    var lowHighTemp: String
    var feelsLike: String
    var clouds: String
    var wind: String
    var humidity: String
    var pressure: String
}

struct ForecastInfo {
    var day: [String]
    var lowHighTemp: [String]
}

extension Date {
    func dayWord() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E" // Day of the week
        return dateFormatter.string(from: self)
    }
}
