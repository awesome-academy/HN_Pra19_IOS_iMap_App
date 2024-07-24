//
//  ViewController.swift
//  map
//
//  Created by Tung on 21/07/2024.
//

import UIKit
import MapKit

final class ViewController: UIViewController {
    
    var locationManager : CLLocationManager?
    
    lazy var mapView : MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    lazy var searchBar : UITextField = {
        let searchBar = UITextField()
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        searchBar.backgroundColor = UIColor.white
        searchBar.placeholder = "Search"
        searchBar.leftView = UIView(frame: CGRect(x : 0, y : 0, width : 10, height : 0))
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
    
    private func setupMap(){
        view.addSubview(searchBar)
        view.addSubview(mapView)
        view.bringSubviewToFront(searchBar)
        
        searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchBar.widthAnchor.constraint(equalToConstant: view.bounds.size.width/1.2).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        searchBar.returnKeyType = .go
        
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}