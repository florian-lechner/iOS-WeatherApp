//
//  WeatherView.swift
//  MetUCD
//
//  Created by Florian Lechner on 20/09/2023.
//

import SwiftUI
import CoreLocation
import MapKit
import Charts


// MARK: - Main View

struct WeatherView: View {
    @Bindable var viewModel: WeatherViewModel
    @State private var isShowingSearchField = false
    @FocusState private var isSearchFieldFocused: Bool
    @State private var isShowingWheaterDetailSheet = false
    
    var body: some View {
        ZStack {
            // MARK: Permission Button
            if viewModel.authorizationStatus != .authorizedWhenInUse {
                VStack {
                    Button {
                        viewModel.requestLocationPermission()
                    } label: {
                        Text("Ask Location Permission")
                            .padding()
                    }
                }
                .onAppear{
                    viewModel.requestLocationPermission()
                }
            } else { // If permission is granted
                // MARK: Map
                if let coordinates = viewModel.coordinates {
                    MapView(coordinate: Binding(get: { coordinates }, set: { viewModel.coordinates = $0 }), viewModel: viewModel)
                        .ignoresSafeArea(edges: .all)
                } else {
                    // If current location hasn't been found yet
                    Text("Retrieving your location...")
                }
                
                // MARK: Location and Search Button
                VStack {
                    HStack {
                        if !isShowingSearchField {
                            Button(action: {
                                viewModel.centerMapOnUserLocation()
                            }) {
                                Image(systemName: "location.fill")
                                    .padding()
                                    .background(Color.white.opacity(0.75))
                                    .clipShape(Circle())
                            }
                            .padding(.leading, 20)
                            
                            Spacer()
                        
                            // Search Button
                            Button(action: {
                                withAnimation {
                                    isShowingSearchField = true
                                    isSearchFieldFocused = true
                                    viewModel.namedLocation = ""
                                }
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .padding()
                                    .background(Color.white.opacity(0.75))
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 20)
                        }
                        // Search Text Field
                        if isShowingSearchField {
                        TextField("Search", text: $viewModel.namedLocation)
                            .onSubmit { viewModel.fetchLocation() }
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            .background(Color.white.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .focused($isSearchFieldFocused)
                            .frame(width: UIScreen.main.bounds.width * 0.8)
                        }
                    }
                    Spacer()
                    
                    // Weather Info Widget
                    if let widgetInfo = viewModel.widgetInfo {
                        WeatherInfoWidget(widgetInfo: widgetInfo)
                            .onTapGesture {
                                isShowingWheaterDetailSheet = true
                            }
                    }
                }
                // Display the Weather Details
                .sheet(isPresented: $isShowingWheaterDetailSheet) {
                    WeatherDetail(geoInfo: viewModel.geoInfo, weatherInfo: viewModel.weatherInfo, forecastInfo: viewModel.forecastInfo, airQualityInfo: viewModel.airQualityInfo, airPollutionForecastInfo: viewModel.airPollutionForecastInfo)
                }
            }
            
            
            
        }
        // Hide Search Field when tapping outside
        .onTapGesture {
            if isShowingSearchField {
                withAnimation {
                    isShowingSearchField = false
                    isSearchFieldFocused = false
                }
            }
        }
        
    }
    
}


// MARK: - MapView
struct MapView: UIViewRepresentable {
    @Binding var coordinate: CLLocationCoordinate2D
    var viewModel: WeatherViewModel // To access currentTemp
    var currentTemp: String {
        return viewModel.widgetInfo?.currentTemp ?? ""
    }

    // Create a MKMapView
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        context.coordinator.addTapGesture(to: mapView)
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        mapView.setRegion(region, animated: false)
        return mapView
    }

    
    // Update the MKMapView with the new coordinate
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Only recenter to annotation if out of view
        let isCoordinateVisible = uiView.region.contains(coordinate: coordinate)
        
        if !isCoordinateVisible {
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            uiView.setRegion(region, animated: true)
        }

        // Remove all annotations and add the new one
        uiView.removeAnnotations(uiView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        uiView.addAnnotation(annotation)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ mapView: MapView) {
            self.parent = mapView
        }

        func addTapGesture(to mapView: MKMapView) {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            mapView.addGestureRecognizer(tapRecognizer)
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            if gesture.state == .ended {
                let location = gesture.location(in: gesture.view)
                parent.coordinate = (gesture.view as! MKMapView).convert(location, toCoordinateFrom: gesture.view)
            }
        }
        
        // Annotation with temperature as glyphText
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "TempAnnotation"

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.calloutOffset = CGPoint(x: -5, y: 5)
            } else {
                annotationView?.annotation = annotation
            }

            // Set glyphText to currentTemp
            annotationView?.glyphText = parent.currentTemp

            return annotationView
        }
        
    }
}

// Extend MKCoordinateRegion to add a utility method
extension MKCoordinateRegion {
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        let northEastCorner = CLLocationCoordinate2D(
            latitude: self.center.latitude + self.span.latitudeDelta / 2,
            longitude: self.center.longitude + self.span.longitudeDelta / 2)
        let southWestCorner = CLLocationCoordinate2D(
            latitude: self.center.latitude - self.span.latitudeDelta / 2,
            longitude: self.center.longitude - self.span.longitudeDelta / 2)

        return (southWestCorner.latitude < coordinate.latitude &&
                coordinate.latitude < northEastCorner.latitude &&
                southWestCorner.longitude < coordinate.longitude &&
                coordinate.longitude < northEastCorner.longitude)
    }
}


// MARK: - Weather Info Widget View
struct WeatherInfoWidget: View {
    let widgetInfo: WidgetInfo
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                VStack(spacing: 8) {
                    Text(widgetInfo.name)
                        .font(.title2)
                        .fontWeight(.medium)
                    HStack(spacing: 20) {
                        Image(systemName: "thermometer")
                            .foregroundColor(.gray)
                            .imageScale(.large)
                            .font(Font.title.weight(.light))
                        Text(widgetInfo.currentTemp)
                            .font(.system(size: 50))
                            .fontWeight(.thin)
                            .foregroundColor(.gray)
                    }
                    Text(widgetInfo.description)
                        .font(.title3)
                    Text(widgetInfo.lowHighTemp)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.black)
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.8, height: 180)
                .background(VisualEffectBlur(blurStyle: .systemThinMaterial))
                .cornerRadius(20)
            }
            .padding(.bottom, 20)
        }
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - Weather Detail Sheet
struct WeatherDetail: View {
    let geoInfo: GeoInfo?
    let weatherInfo: WeatherInfo?
    let forecastInfo: ForecastInfo?
    let airQualityInfo: AirQualityData?
    let airPollutionForecastInfo: AirPollutionData?
    
    var body: some View {
        Form {
            // Geo Location
            if let geoInfo = geoInfo {
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
            if let weatherInfo = weatherInfo {
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
            
            // 5 Day Forecast
            if let forecastInfo = forecastInfo {
                Section {
                    ForEach(forecastInfo.days, id: \.date) { dayInfo in
                        ForecastRow(dayInfo: dayInfo)
                    }
                } header: { Text("5 Day Forecast").modifier(HeaderStyle())
                }
            }
            
            // Air Quality
            if let airQualityInfo = airQualityInfo {
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
                } header: { Text("Air Quality: \(airQualityInfo.description)").modifier(HeaderStyle())
                }
            }
            
            // Air Pollution Index Forecast
            if let airPollutionForecastInfo = airPollutionForecastInfo {
                Section {
                    aqiChart(airPollutionForecastInfo: airPollutionForecastInfo)                   
                } header: { Text("Air Pollution Index Forecast").modifier(HeaderStyle())
                }
            }

        }
        .font(.system(size: 14))
    }
    
    
}



// Header Style
struct HeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 12))
            .foregroundColor(.gray)
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

// View to display each forecast row
struct ForecastRow: View {
    let dayInfo: ForecastDayInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dayInfo.dateString) // Day
                    .bold()
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "thermometer")
                    .foregroundColor(.gray)
                Text(dayInfo.lowHighTemp)
                    .modifier(LowHighStyle())
            }
            HStack(spacing: 4) {
                if dayInfo.dateString == "Today" && dayInfo.hourlyForecasts.count < 8 {
                        Spacer()
                }
                ForEach(dayInfo.hourlyForecasts, id: \.time) { hourlyForecast in
                    VStack(spacing: 2) {
                        Text(hourlyForecast.time) // time
                            .fontWeight(.medium)
                        SafeImage(imageName: hourlyForecast.icon)
                            /*.frame(width: 35, height: 35)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 5))*/
                    }
                    .frame(width: 38, height: 60)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
        }
    }
}


// Shows referenced image as forecast icon unless the image does not exist in assets, then the cloud (04d) is used as default
struct SafeImage: View {
    var imageName: String
    let fallbackImageName = "04d"  // Cloud icon

    var body: some View {
        Image(uiImage: UIImage(named: imageName) ?? UIImage(named: fallbackImageName)!)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
    }
}

// View to display each air quality row
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

// AQI Chart
struct aqiChart: View {
    let airPollutionForecastInfo: AirPollutionData?
    
    let aqiLabels: [Int: String] = [
        1: "Good",
        2: "Fair",
        3: "Moderate",
        4: "Poor",
        5: "Very Poor"
    ]
    var body: some View {
        Chart {
            if let airPollutionForecastInfo = airPollutionForecastInfo?.list {
                ForEach(airPollutionForecastInfo, id: \.dt) { forecast in
                    LineMark(
                        x: .value("Date", Date(timeIntervalSince1970: TimeInterval(forecast.dt))),
                        y: .value("AQI", forecast.main.aqi)
                    )
                }
            }
        }
        .chartYScale(domain: [1, 5])
        .chartYAxis {
            AxisMarks(values: .stride(by: 1)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    Text(aqiLabels[value.as(Int.self) ?? 0, default: ""])
                }
            }
        }
        .frame(height: 200)
    }
}

// MARK: - Preview


#Preview {
    WeatherView(viewModel: WeatherViewModel())
}
