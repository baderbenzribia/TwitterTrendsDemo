//
//  TrendsViewController.swift
//  TwitterTrendsDemo
//
//  Created by Bader BEN ZRIBIA on 22.01.18.
//  Copyright © 2018 Bader Ben Zribia. All rights reserved.
//

import UIKit
import CoreLocation

class TrendsViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    private var dataSource : [Trend] = []
    
    private var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkLocationAuthorizationStatus()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func checkLocationAuthorizationStatus() {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse
        {
            locationManager.startUpdatingLocation()
        }
        else
        {
            locationManager.requestWhenInUseAuthorization()
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    private func lookUpCurrentLocation(completion: @escaping (CLPlacemark?) -> Void ) {
        
        // get the last reported location.
        if let lastLocation = self.locationManager.location {
            
            // look up the location
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(lastLocation, completionHandler: {
                (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completion(firstLocation)
                }
                else {
                    // An error occurred during geocoding.
                    completion(nil)
                }
            })
        }
        else {
            // No location was available.
            completion(nil)
        }
    }
    
    // show an alert with a text message depending to a specific error type
    private func buildApiErrorAlert(error : APIError) -> UIAlertController
    {
        let alert = UIAlertController(title: "API Error", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        alert.addAction(okAction)
        
        switch (error)
        {
        case .buildingRequestError :
            alert.message = APIError.buildingRequestError.rawValue
            break
        case .connectingServerError :
            alert.message = APIError.connectingServerError.rawValue
            break
        case .parsingResponseError :
            alert.message = APIError.parsingResponseError.rawValue
            break
        }
        return alert
    }
}

extension TrendsViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let aTrend = dataSource[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = aTrend.name
        cell.detailTextLabel?.text = aTrend.url
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
}

extension TrendsViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        navigationItem.title = nil
        
        let selectedTrend = dataSource[indexPath.row]
        
        let webVC = self.storyboard?.instantiateViewController(withIdentifier: "webVC") as! WebViewController
        webVC.urlString = selectedTrend.url
    
        self.navigationController?.pushViewController(webVC, animated: true)
    }
}

extension TrendsViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        self.lookUpCurrentLocation() {
            [unowned self] placemark in
            
            if let placemark = placemark, let locality = placemark.locality {
                
                self.title = locality + " Twitter Trends"
            }
        }
        
        if let location = locations.first {
            
            let latitudeString = String(location.coordinate.latitude)
            let longitudeString = String(location.coordinate.longitude)
            
            let twitterTrendsHttpClient = TwitterTrendsHttpClient()
            twitterTrendsHttpClient.getWoeid(with: latitudeString, longitude: longitudeString) {
                [unowned self] (woeid, error) in
                
                // if failed show an alert depending on the error type
                if let error = error
                {
                    let alert = self.buildApiErrorAlert(error: error)
                    
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
                // if succeed call the twitter trends
                if let woeid = woeid
                {
                    twitterTrendsHttpClient.getTrends(woeid: woeid) {
                        [unowned self] (trends, error) in
                        
                        
                        // if failed show an alert depending on the error type
                        if let error = error
                        {
                            let alert = self.buildApiErrorAlert(error: error)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        
                        // if succeed reload the tableView
                        if let trends = trends {
                            self.dataSource = trends
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
                
            }
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        let alert = UIAlertController(title: "Location Error", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        alert.addAction(okAction)
        
        alert.message = "Unable to get your location."
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            manager.startUpdatingLocation()
            break
        case .restricted:
            break
        case .denied:
            break
        }
    }
    
}
