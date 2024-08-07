import UIKit
import MapKit

final class ViewController: UIViewController {
    
    var locationManager: CLLocationManager?
    private var places: [PlaceAnnotation] = []
    private var currentRoute: MKRoute?
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.delegate = self
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        map.isZoomEnabled = true
        return map
    }()
    
    lazy var searchBar: UITextField = {
        let searchBar = UITextField()
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        searchBar.delegate = self
        searchBar.backgroundColor = UIColor.white
        searchBar.placeholder = "Search"
        searchBar.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        searchBar.leftViewMode = .always
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
        setupMap()
    }
    
    private func setupLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
    }
    
    private func setupMap() {
        view.addSubview(searchBar)
        view.addSubview(mapView)
        view.bringSubviewToFront(searchBar)
        
        searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchBar.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 1.2).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        searchBar.returnKeyType = .go
        
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        mapView.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
    }
    
    private func showPlacesSheet(places: [PlaceAnnotation]) {
        guard let locationManager = locationManager,
              let userLocation = locationManager.location else { return }
        let placesTableViewController = PlacesTableViewController(userLocation:
                                                                    userLocation, places: places)
        placesTableViewController.modalPresentationStyle = .pageSheet
        
        if let sheet = placesTableViewController.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            present(placesTableViewController, animated: true)
        }
    }
    
    private func findNearbyPlaces(by query: String) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response, error == nil else { return }
            self?.places = response.mapItems.map(PlaceAnnotation.init)
            self?.places.forEach { place in
                self?.mapView.addAnnotation(place)
            }
            
            if let places = self?.places {
                self?.showPlacesSheet(places: places)
            }
        }
    }

    
    private func calculateRoute(to destination: CLLocationCoordinate2D) {
        guard let userLocation = locationManager?.location?.coordinate else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self, let route = response?.routes.first, error == nil else { return }
            
            self.mapView.removeOverlays(self.mapView.overlays)
            self.currentRoute = route
            self.mapView.addOverlay(route.polyline)

            let edgePadding = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                           edgePadding: edgePadding,
                                           animated: true)

        }
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        if !text.isEmpty {
            textField.resignFirstResponder()
            findNearbyPlaces(by: text)
        }
        return true
    }
}

extension ViewController: MKMapViewDelegate {
    
    private func clearAllSelectedPlace() {
        self.places = self.places.map { place in
            place.selected = false
            return place
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        clearAllSelectedPlace()
        
        guard let selectedAnnotation = annotation as? PlaceAnnotation else { return }
        let placeAnnotation = self.places.first { $0.id == selectedAnnotation.id }
        placeAnnotation?.selected = true
        
        showPlacesSheet(places: self.places)
        
        if let coordinate = placeAnnotation?.coordinate {
            calculateRoute(to: coordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: routePolyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        LocationHelper.checkLocationAuthorization(locationManager: locationManager, mapView: mapView)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
