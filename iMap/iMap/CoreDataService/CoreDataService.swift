import Foundation
import CoreData
import MapKit
import UIKit

final class CoreDataHelper {
    
    static let shared = CoreDataHelper()
    
    private init() {}
    
    private var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    func fetchFavoriteStatus(for place: PlaceAnnotation) -> Bool {
        guard let appDelegate = appDelegate else { return false }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "FavoritePlace")
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND address == %@",
                                             place.name,
                                             place.address)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.count > 0
        } catch {
            print("Failed to fetch favorite places: \(error)")
            return false
        }
    }
    
    func toggleFavoriteStatus(for place: PlaceAnnotation) {
        guard let appDelegate = appDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "FavoritePlace")
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND address == %@",
                                             place.name,
                                             place.address)
        
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            if results.isEmpty {
                let entity = NSEntityDescription.entity(forEntityName: "FavoritePlace", in: context)!
                let favoritePlace = NSManagedObject(entity: entity, insertInto: context)
                favoritePlace.setValue(place.name, forKey: "name")
                favoritePlace.setValue(place.address, forKey: "address")
                favoritePlace.setValue(place.location.coordinate.latitude, forKey: "latitude")
                favoritePlace.setValue(place.location.coordinate.longitude, forKey: "longitude")
                try context.save()
            } else {
                for object in results {
                    context.delete(object)
                }
                try context.save()
            }
        } catch {
            print("Failed to update favorite status: \(error)")
        }
    }
}
