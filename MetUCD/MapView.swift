//
//  MapView.swift
//  MetUCD
//
//  Created by Flo Lechner on 24.11.2023.
//

import Foundation
import MapKit

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
        
        // Pin jumps automatically to center of view
        /*func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let center = mapView.centerCoordinate
            parent.coordinate = center  // Update the binding coordinate
        }*/
        
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
