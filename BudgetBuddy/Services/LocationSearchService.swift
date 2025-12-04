import Foundation
import CoreLocation

class LocationSearchService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var searchResults: [LocationResult] = []
    @Published var isSearching = false
    @Published var currentLocation: CLLocationCoordinate2D?
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    struct LocationResult {
        let city: String
        let state: String
        let zipCode: String
        let coordinate: CLLocationCoordinate2D?
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Search by text
    func searchLocations(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        geocoder.geocodeAddressString(query) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.isSearching = false
                guard let placemarks = placemarks else {
                    self?.searchResults = []
                    return
                }
                
                self?.searchResults = placemarks.compactMap { placemark in
                    let city = placemark.locality ?? ""
                    let state = placemark.administrativeArea ?? ""
                    let zipCode = placemark.postalCode ?? ""
                    
                    guard !city.isEmpty && !state.isEmpty else { return nil }
                    
                    return LocationResult(
                        city: city,
                        state: state,
                        zipCode: zipCode,
                        coordinate: placemark.location?.coordinate
                    )
                }
            }
        }
    }
    
    // MARK: - Get current device location
    func requestCurrentLocation() {
        let status = locationManager.authorizationStatus
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
        
        // Reverse geocode to get city, state, zip
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first else { return }
            
            let city = placemark.locality ?? ""
            let state = placemark.administrativeArea ?? ""
            let zipCode = placemark.postalCode ?? ""
            
            DispatchQueue.main.async {
                self?.searchResults = [LocationResult(
                    city: city,
                    state: state,
                    zipCode: zipCode,
                    coordinate: location.coordinate
                )]
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
}
