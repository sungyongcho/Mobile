import UIKit
import Flutter
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {
    private let CHANNEL = "com.example.app/gps"
    var locationManager: CLLocationManager?
    var locationResult: FlutterResult?
    var hasSentResult = false

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let gpsChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

        gpsChannel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "getLocation" {
                self?.getLocation(result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func getLocation(result: @escaping FlutterResult) {
        locationResult = result
        locationManager = CLLocationManager()
        locationManager?.delegate = self

        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager?.requestWhenInUseAuthorization()
        } else if status == .denied || status == .restricted {
            sendLocationError(code: "PERMISSION_DENIED", message: "Location permission denied.")
        } else {
            startUpdatingLocation()
        }
    }

	private func startUpdatingLocation() {
		guard CLLocationManager.locationServicesEnabled() else {
			sendLocationError(code: "LOCATION_SERVICES_DISABLED", message: "Location services are disabled.")
			return
		}

		if #available(iOS 14.0, *) {
			locationManager?.desiredAccuracy = kCLLocationAccuracyReduced
		} else {
			locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
		}

		locationManager?.startUpdatingLocation()
	}

    // MARK: - CLLocationManagerDelegate Methods

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            startUpdatingLocation()
        } else if status == .denied || status == .restricted {
            sendLocationError(code: "PERMISSION_DENIED", message: "Location permission denied.")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !hasSentResult else { return }  // Prevent multiple calls
        hasSentResult = true

        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            locationResult?(["latitude": latitude, "longitude": longitude])
        } else {
            sendLocationError(code: "LOCATION_ERROR", message: "Failed to get location.")
        }

        locationManager?.stopUpdatingLocation()
        resetLocationManager()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        sendLocationError(code: "LOCATION_ERROR", message: "Failed to get location.", details: error.localizedDescription)
        resetLocationManager()
    }

    // MARK: - Helper Methods

    private func sendLocationError(code: String, message: String, details: String? = nil) {
        guard !hasSentResult else { return }  // Prevent multiple calls
        hasSentResult = true

        locationResult?(FlutterError(code: code, message: message, details: details))
        resetLocationManager()
    }

    private func resetLocationManager() {
        locationManager?.delegate = nil
        locationManager = nil
        locationResult = nil
        hasSentResult = false
    }
}
