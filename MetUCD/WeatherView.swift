//
//  WeatherView.swift
//  MetUCD
//
//  Created by Instructor on 20/09/2023.
//

import SwiftUI


// MARK: - Main View

struct WeatherView: View {
    @Bindable var viewModel: WeatherViewModel
    @FocusState private var isInputActive: Bool
    
    var body: some View {
        Form {
            Section {
                VStack {
                    TextField(text: $viewModel.namedLocation) {
                        Text("Enter location e.g. Dublin, IE")
                    }
                    .onSubmit { viewModel.fetchData() }
                    .padding([.leading, .trailing])
                    .focused($isInputActive)
                    
                }
            } header: { Text("Search").modifier(HeaderStyle()) }
            
            // Geo Location
            if let geoInfo = viewModel.geoInfo {
                Section {
                    HStack {
                        Image(systemName: "location.north.fill")
                            .foregroundColor(.blue)
                        Text("\(geoInfo.latitude), \(geoInfo.longitude)")
                    }
                    
                    HStack {
                        Image(systemName: "sunrise.fill")
                            .foregroundColor(.yellow)
                        Text(geoInfo.sunrise[0])
                        Text("(\(geoInfo.sunrise[1]))").modifier(LowHighStyle())
                        
                        Image(systemName: "sunset.fill")
                            .foregroundColor(.orange)
                        Text(geoInfo.sunset[0])
                        Text("(\(geoInfo.sunset[1]))").modifier(LowHighStyle())
                    }
                    
                    HStack {
                        Image(systemName: "clock.arrow.2.circlepath")
                            .foregroundColor(.blue)
                        Text(geoInfo.timezoneOffset)
                    }
                } header: { Text("Geo Location").modifier(HeaderStyle())
                }
            }
            
            // Current Weather
            if let weatherInfo = viewModel.weatherInfo {
                Section {
                    HStack {
                        Image(systemName: "thermometer")
                            .foregroundColor(.blue)
                        Text(weatherInfo.currentTemp)
                        Text(weatherInfo.lowHighTemp).modifier(LowHighStyle())
                        
                        Image(systemName: "thermometer.variable.and.figure")
                            .foregroundColor(.orange)
                        Text("Feels \(weatherInfo.feelsLike)")
                    }
                    
                    HStack {
                        Image(systemName: "cloud.fill")
                            .foregroundColor(.gray)
                        Text(weatherInfo.clouds)
                    }
                    
                    HStack {
                        Image(systemName: "wind")
                            .foregroundColor(.blue)
                        Text(weatherInfo.wind)
                    }
                    HStack {
                        Image(systemName: "humidity.fill")
                            .foregroundColor(.blue)
                        Text(weatherInfo.humidity)
                        Image(systemName: "gauge")
                            .foregroundColor(.green)
                        Text(weatherInfo.pressure)
                    }
                } header: { Text("Weather: \(weatherInfo.description)").modifier(HeaderStyle())
                }
            }
            
            // Air Quality
            if let airQualityInfo = viewModel.airQualityInfo {
                Section {
                    // Grid for the air quality components
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 30), GridItem(.flexible())], spacing: 10) {
                        AirQualityRow(component: "NO", value: airQualityInfo.components.no)
                        AirQualityRow(component: "PM10", value: airQualityInfo.components.pm10)
                        AirQualityRow(component: "O3", value: airQualityInfo.components.o3)
                        AirQualityRow(component: "NH3", value: airQualityInfo.components.nh3)
                        AirQualityRow(component: "NO2", value: airQualityInfo.components.no2)
                        AirQualityRow(component: "PM2.5", value: airQualityInfo.components.pm25)
                        AirQualityRow(component: "CO", value: airQualityInfo.components.co)
                        AirQualityRow(component: "SO2", value: airQualityInfo.components.so2)
                    }
                    // HStack to align the text to the right
                    HStack {
                        Spacer()
                        Text("units: μg/m3")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                } header: { Text("Air Quality: \(airQualityInfo.description)").modifier(HeaderStyle()) }
            }
            
            // 5 Day Forecast
            if let forecastInfo = viewModel.forecastInfo {
                Section {
                    ForEach(forecastInfo.day.indices, id: \.self) { index in
                        ForecastRow(day: forecastInfo.day[index], lowHighTemp: forecastInfo.lowHighTemp[index])
                    }
                } header: { Text("5 Day Forecast").modifier(HeaderStyle()) }
            }
            
            // Air Pollution Index Forecast
            
            
            
        } // modifier for Form
            .font(.system(size: 14))
            .onTapGesture {
                // Dismiss the keyboard by changing the focus state
                isInputActive = false
            }
    }
    
}

// Header Style
struct HeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 12)) // Set your desired font style here
            .foregroundColor(.gray) // Set your desired text color
            // Add any other styling as needed
            .foregroundStyle(.tint)
    }
}

// lowHigh Style
struct LowHighStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline) //slightly smaller
            .foregroundColor(.gray)
    }
}

// Helper view to display each forecast row
struct ForecastRow: View {
    let day: String
    let lowHighTemp: String
    
    var body: some View {
        HStack {
            Text(day)
                .bold()
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "thermometer")
                .foregroundColor(.gray)
            Text(lowHighTemp).modifier(LowHighStyle())
        }
    }
}

// Helper view to display each air quality row
struct AirQualityRow: View {
    let component: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(component)
                .bold()
                .foregroundColor(.primary)
            Spacer()
            Text(String(format: "%.1f", value))
        }
    }
}



// MARK: - Preview


#Preview {
    WeatherView(viewModel: WeatherViewModel())
}
