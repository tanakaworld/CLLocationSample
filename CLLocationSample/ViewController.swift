//
//  ViewController.swift
//  CLLocationSample
//
//  Created by Yutaro Tanaka on 2014/11/04.
//  Copyright (c) 2014年 Yutaro Tanaka. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?
    var longitude: CLLocationDegrees!
    var latitude: CLLocationDegrees!
    
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.startStandardUpdates()
        self.startSignificantChangeUpdates()
        
        self.longitude = 0.0
        self.latitude = 0.0

        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if(status != CLAuthorizationStatus.Authorized) {
            println("認証ステータス:\(status.rawValue)");
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            // 初回しか出ない
            self.locationManager?.requestAlwaysAuthorization()
        }
    }
    
    // 大幅変更位置情報サービス
    func startSignificantChangeUpdates() {
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        
        // ユーザが移動せず同じ位置にとどまっていると判断した場合など
        // 必要に応じてCore Locationが位置情報の更新を一時停止する
        // （したがって位置情報ハードウェアへの電力供給を止める）
        // さらに、確定した位置情報を取得できない場合にも一時停止する
        self.locationManager?.pausesLocationUpdatesAutomatically = true
        self.locationManager?.startMonitoringSignificantLocationChanges()
    }
    
    // 標準
    func startStandardUpdates () {
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters // 精度
        self.locationManager?.distanceFilter = 100 // 頻度
        
        self.locationManager?.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func getLocation(sender: UIButton) {
        println("GET")
        self.locationManager?.startUpdatingLocation()
    }
    
    
    // 位置情報許可設定変更時
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        
        println("===位置情報ステータス===");
        // 認証のステータスをログで表示.
        var statusStr = "";
        switch (status) {
        case .NotDetermined:
            statusStr = "NotDetermined"
            if (self.locationManager?.respondsToSelector("requestWhenInUseAuthorization") != nil) {
                self.locationManager?.requestAlwaysAuthorization()
            }
        case .Restricted, .Denied:
            statusStr = "Restricted or Denied"
            self.alertLocationServicesDisabled()
        case .AuthorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
            self.alertLocationServicesDisabled()
        case .Authorized:
            statusStr = "Authorized"
            self.locationManager?.startUpdatingLocation()
        default:
            self.locationManager?.requestAlwaysAuthorization()

            break
        }
    }
    
    //
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location = locations.last as CLLocation
        var eventDate = location.timestamp
        var howRecent = eventDate.timeIntervalSinceNow
        
        if abs(howRecent) < 15.0 {
            println("EventDate:\(eventDate)|(lati,long):(\(location.coordinate.latitude),\(location.coordinate.longitude))")
        } else {
            
        }
    }
    
    // 位置情報取得に成功時のデリゲート
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!){
        
        self.longitude = newLocation.coordinate.longitude
        self.latitude = newLocation.coordinate.latitude
        
        // 緯度・経度の表示.
        self.latitudeLabel.text = "緯度：\(manager.location.coordinate.latitude)"
        self.longitudeLabel.text = "経度：\(manager.location.coordinate.longitude)"
    }
    
    // 位置情報取得に失敗時のデリゲート
    func locationManager(manager: CLLocationManager!,didFailWithError error: NSError!){
        println("error")
    }
    
    // 位置情報設定要求アラート
    func alertLocationServicesDisabled() {
        let title = "Location Services Disabled"
        let message = "You must enable Location Services to track your run."
        
        if (NSClassFromString("UIAlertController") != nil) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { action in
                let url = NSURL(string: UIApplicationOpenSettingsURLString)
                UIApplication.sharedApplication().openURL(url!)
            }))
            alert.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        } else {
            UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Close").show()
        }
    }


}

