import Foundation
import UIKit
import MapKit

final class PlacesTableViewController: UITableViewController {
    
    var userLocation: CLLocation
    var places: [PlaceAnnotation]
    
    init(userLocation: CLLocation, places: [PlaceAnnotation]) {
        self.userLocation = userLocation
        self.places = places
        super.init(nibName: nil, bundle: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")
    }
    
    private func fetchFavoriteStatus(for place: PlaceAnnotation) -> Bool {
        return CoreDataHelper.shared.fetchFavoriteStatus(for: place)
    }
    
    private func toggleFavoriteStatus(for place: PlaceAnnotation) {
        CoreDataHelper.shared.toggleFavoriteStatus(for: place)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    private func calculateDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance {
        return from.distance(from: to)
    }
    
    private func formatDistance(_ distance: CLLocationDistance) -> String {
        let meters = Measurement(value: distance, unit: UnitLength.meters)
        return meters.converted(to: .kilometers).formatted()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        let placeDetail = PlaceDetailViewController(place: place)
        present(placeDetail, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let place = places[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = place.name
        content.secondaryText = formatDistance(calculateDistance(from: userLocation, to: place.location))
        cell.contentConfiguration = content
        cell.backgroundColor = place.selected ? UIColor.lightGray : UIColor.clear
        
        let favoriteButton = UIButton()
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.tintColor = fetchFavoriteStatus(for: place) ? .systemRed : .systemGray
        favoriteButton.isSelected = fetchFavoriteStatus(for: place)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        
        cell.contentView.subviews.filter { $0 is UIButton }.forEach { $0.removeFromSuperview() }
        
        cell.contentView.addSubview(favoriteButton)
        NSLayoutConstraint.activate([
            favoriteButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            favoriteButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return cell
    }

    @objc private func favoriteButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        
        let place = places[indexPath.row]
        toggleFavoriteStatus(for: place)
        sender.isSelected.toggle()
        sender.tintColor = sender.isSelected ? .systemRed : .systemGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
