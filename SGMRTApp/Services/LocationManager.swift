import CoreLocation
import Foundation

/// Wraps CoreLocation and resolves the rider's nearest MRT station from GPS.
@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published private(set) var authorization: CLAuthorizationStatus
    @Published private(set) var nearestStationID: String?
    @Published private(set) var nearestDistanceMeters: Double?
    @Published private(set) var isTracking = false

    private let manager = CLLocationManager()

    override init() {
        authorization = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 25
    }

    /// Request permission and begin updates. Safe to call repeatedly.
    func start() {
        switch authorization {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            beginUpdates()
        default:
            break
        }
    }

    func stop() {
        manager.stopUpdatingLocation()
        isTracking = false
    }

    private func beginUpdates() {
        guard !isTracking else { return }
        isTracking = true
        manager.startUpdatingLocation()
    }

    private func updateNearest(from location: CLLocation) {
        var bestID: String?
        var bestDistance = Double.greatestFiniteMagnitude
        for (id, coord) in MRTStationCoordinates.byID {
            let distance = location.distance(from: CLLocation(latitude: coord.latitude, longitude: coord.longitude))
            if distance < bestDistance {
                bestDistance = distance
                bestID = id
            }
        }
        nearestStationID = bestID
        nearestDistanceMeters = bestID == nil ? nil : bestDistance
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            authorization = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                beginUpdates()
            } else {
                stop()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in updateNearest(from: location) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
