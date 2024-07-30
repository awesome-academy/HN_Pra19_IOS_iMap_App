import Foundation
import UIKit
import MapKit

final class PlacesTableViewController: UITableViewController {
    
    var userLocation: CLLocation
    let places: [PlaceAnnotation]
    
    init(userLocation: CLLocation, places: [PlaceAnnotation]) {
        self.userLocation = userLocation
        self.places = places
        super.init(nibName: nil, bundle: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell",
                                                 for: indexPath)
        let place = places[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = place.name
        content.secondaryText = "Secondary Text"
        cell.contentConfiguration = content
        return cell
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
}
