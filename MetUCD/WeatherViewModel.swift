//
//  WeatherViewModel.swift
//  MetUCD
//
//  Created by Instructor on 20/09/2023.
//

import SwiftUI
import CoreLocation
import MapKit

@Observable class WeatherViewModel: NSObject, CLLocationManagerDelegate {
    // Location Manager
    var authorizationStatus : CLAuthorizationStatus = .notDetermined
    private let locationManager = CLLocationManager()
    
    private var lastKnownLocation: CLLocationCoordinate2D?
    var coordinates : CLLocationCoordinate2D? {
        didSet { self.fetchData() }
    }
    
    var namedLocation: String = ""
    
    // MARK: Model
    
    private var dataModel = WeatherDataModel()

    // MARK: User intent
    
    func fetchData() {
        Task {
            if let location = coordinates {
                await dataModel.fetchCoordinates(lat: location.latitude, lon: location.longitude)
            }
        }
    }
    
    func fetchLocation() {
        Task {
            await dataModel.fetch(for: namedLocation)
            
            // Update namedLocation with the name of the first GeoLocation, if available
            if let firstGeoLocation = dataModel.geoLocationData?.first {
                DispatchQueue.main.async {
                    self.namedLocation = firstGeoLocation.name
                    self.coordinates = CLLocationCoordinate2D(latitude: firstGeoLocation.lat, longitude: firstGeoLocation.lon)
                }
            }
        }
    }
    
    // MARK: LocationManager
    override init() {
        /*self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 53.3498006, longitude: -6.2602964),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )*/
        super.init()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
   
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    // MARK: Location Manager Delegate Function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        self.lastKnownLocation = location.coordinate
        if self.coordinates == nil {
            self.coordinates = self.lastKnownLocation
        }
    }
    
    // MARK: Center Map on User Location
    func centerMapOnUserLocation() {
        if let currentLocation = self.lastKnownLocation {
            self.coordinates = currentLocation // Use the stored location
        }
    }
    
    
    
    // MARK: Computed properties to construct WidgetInfo
    var widgetInfo: WidgetInfo? {
        guard let weatherData = dataModel.weatherData else { return nil }
    
        let lowHighTempString = "(L: \(formatTemperature(weatherData.main.tempMin)) H: \(formatTemperature(weatherData.main.tempMax)))"
        
        return WidgetInfo(
            name: weatherData.name,
            currentTemp: String(format: "%.0f°", weatherData.main.tempMin),
            description: weatherData.description.capitalized,
            lowHighTemp: lowHighTempString
        )
    }
    
    // MARK: Public Properties
    var airQualityInfo: AirQualityData? { dataModel.airQualityData }
    var airPollutionForecastInfo: AirPollutionData? { dataModel.airPollutionForecastData }
      
    
    // MARK: Computed properties to construct GeoInfo
    var geoInfo: GeoInfo? {
        guard let coordinates = coordinates, let weatherData = dataModel.weatherData else { return nil }
    
        // Take coordinates from pin
        let latitudeString = convertCoordinate(coordinates.latitude, isLatitude: true) //convertCoordinate(geoLocationData.lat, isLatitude: true)
        let longitudeString =  convertCoordinate(coordinates.longitude, isLatitude: false)//convertCoordinate(geoLocationData.lon, isLatitude: false)
        
        let sunriseString = timeString(from: weatherData.sys.sunrise, timezoneOffset: weatherData.timezone)
        let sunsetString = timeString(from: weatherData.sys.sunset, timezoneOffset: weatherData.timezone)
        let timezoneOffsetString = formatTimezoneOffset(weatherData.timezone)
        
        return GeoInfo(
            latitude: latitudeString,
            longitude: longitudeString,
            sunrise: sunriseString,
            sunset: sunsetString,
            timezoneOffset: timezoneOffsetString
        )
    }
    
    // MARK: Computed properties to construct WeatherInfo
    var weatherInfo: WeatherInfo? {
        guard let weatherData = dataModel.weatherData else { return nil }
        
        //let currentTempString = formatTemperature(weatherData.main.temp)
        let lowHighTempString = "(L: \(formatTemperature(weatherData.main.tempMin)) H: \(formatTemperature(weatherData.main.tempMax)))"
        //let feelsLikeString = "Feels \(formatTemperature(weatherData.main.feelsLike))"
        let cloudString = "\(weatherData.clouds.all)% coverage"
        let windString = "\(weatherData.wind.speed*3.6) km/h, dir: \(weatherData.wind.deg) \(WeatherUtils.convertDegreesToCardinalDirection(weatherData.wind.deg))" // to convert m/s to km/h multiply by 3.6
        let humidityString = "\(weatherData.main.humidity)%"
        let pressureString = "\(weatherData.main.pressure) hPa"
        
        
        return WeatherInfo(
            description: weatherData.description,
            currentTemp: formatTemperature(weatherData.main.tempMin),
            lowHighTemp: lowHighTempString,
            feelsLike: formatTemperature(weatherData.main.feelsLike),
            clouds: cloudString,
            wind: windString,
            humidity: humidityString,
            pressure: pressureString
        )
    }
    
    // MARK: Computed properties to construct ForecastInfo
    // We take the first forecast for each day to represent the daily forecast.
    // We format the day and temperature strings and append them to the respective arrays.

    var forecastInfo: ForecastInfo? {
        guard let forecastData = dataModel.forecastData, let timezoneOffset = dataModel.weatherData?.timezone else { return nil }
        
        let calendar = Calendar.current

        var days = [String]()
        var lowHighTemps = [String]()

        // Group the remaining forecasts by day considering the timezone offset
        let groupedForecasts = Dictionary(grouping: forecastData.list) { forecastItem in
            // Adjust the forecast time for the timezone offset
            let adjustedDate = Date(timeIntervalSince1970: TimeInterval(forecastItem.dt) + Double(timezoneOffset))
            return calendar.startOfDay(for: adjustedDate)
        }


        // Sort the days and get the first entry for each day
        let sortedKeys = groupedForecasts.keys.sorted()
        for key in sortedKeys {
            if let forecastsForDay = groupedForecasts[key],
               let firstForecast = forecastsForDay.first {
                let adjustedDate = Date(timeIntervalSince1970: TimeInterval(firstForecast.dt) + Double(timezoneOffset))
                let day = adjustedDate.dayWord()
                days.append(day)

                let lowHighTemp = "(L: \(formatTemperature(firstForecast.main.tempMin)) H: \(formatTemperature(firstForecast.main.tempMax)))"
                lowHighTemps.append(lowHighTemp)
            }
        }
        
        // Replace the first day with "Today"
        if !days.isEmpty {
            days[0] = "Today"
        }

        // Ensure that we only take today and the next 5 entries
        let endIndex = min(days.count, 6)
        return ForecastInfo(
            day: Array(days[..<endIndex]),
            lowHighTemp: Array(lowHighTemps[..<endIndex])
        )
        
    }
    
    // MARK: Helper Methods
    
    // Convert timestamp to local and UTC time string
    private func timeString(from timestamp: Int, timezoneOffset: Int) -> Array<String> {
        let localTime = convertToTimeString(from: timestamp, timezoneOffset: timezoneOffset)
        let utcTime = convertToTimeString(from: timestamp, timezoneOffset: 0)
        return [localTime,utcTime]
    }

    private func convertToTimeString(from timestamp: Int, timezoneOffset: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func formatTimezoneOffset(_ offsetInSeconds: Int) -> String {
        let hours = offsetInSeconds / 3600
        return String(format: "%+.2dH", hours)
    }
    
    private func convertCoordinate(_ coordinate: Double, isLatitude: Bool) -> String {
        let cardinalDirection = isLatitude ? (coordinate >= 0 ? "N" : "S") : (coordinate >= 0 ? "E" : "W")
        let absCoordinate = abs(coordinate)
        let degrees = Int(absCoordinate)
        let minutes = Int((absCoordinate - Double(degrees)) * 60.0)
        let seconds = Int(((absCoordinate - Double(degrees)) * 60.0 - Double(minutes)) * 60.0)

        return String(format: "%d°%d'%d\" %@", degrees, minutes, seconds, cardinalDirection)
    }
    
    private func formatTemperature(_ temperature: Double) -> String {
            return String(format: "%.1f°C", temperature)
        }
}
