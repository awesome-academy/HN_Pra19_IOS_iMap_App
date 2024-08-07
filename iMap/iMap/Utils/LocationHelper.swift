import Foundation
import MapKit

class LocationHelper {
    
    static func checkLocationAuthorization(locationManager: CLLocationManager?, mapView: MKMapView) {
        guard let locationManager = locationManager,
              let location = locationManager.location else { return }
        print(location)

        switch locationManager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
            case .denied:
                print("Location access denied")
            case .notDetermined, .restricted:
                print("Location access not determined or restricted")
            @unknown default:
                print("Unknown authorization status")
        }
    }
}
