//
//  FourViewController.swift
//  TabViewTest
//
//  Created by Ben_Mac on 2018/10/4.
//  Copyright © 2018 Ben_Mac. All rights reserved.
//

import UIKit
import MapKit

// 在現有的型態擴充屬性和方法，自訂型別也可以，此例為在MAPView加入縮放級別，設定 zoomLevel 可設定地圖的遠近距離
extension MKMapView { //
    //缩放级别
    var zoomLevel: Int {
        //获取缩放级别
        get {
            return Int(log2(360 * (Double(self.frame.size.width/256) / self.region.span.longitudeDelta)) + 1)
        }
        //设置缩放级别
        set (newZoomLevel){setCenterCoordinate(coordinate: self.centerCoordinate, zoomLevel: newZoomLevel,animated: false)
        }
    }
    //设置缩放级别时调用
    private func setCenterCoordinate(coordinate: CLLocationCoordinate2D, zoomLevel: Int,animated: Bool){
        let span = MKCoordinateSpan.init(latitudeDelta: 0, longitudeDelta: 360 / pow(2, Double(zoomLevel)) * Double(self.frame.size.width) / 256)
        setRegion(MKCoordinateRegion.init(center: centerCoordinate, span: span), animated: animated)
    }
}

class FourViewController: UIViewController ,MKMapViewDelegate ,CLLocationManagerDelegate{

    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var myZoomIn: UIBarButtonItem!
    @IBOutlet weak var myType: UIBarButtonItem!
    @IBOutlet weak var myToolbar: UIToolbar!
    
    var locationManager: CLLocationManager?  //地圖使用
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 印出目前所在位置座標
        let currentLocation :CLLocation =  locations[0] as CLLocation
        print("\(currentLocation.coordinate.latitude)")
        print(", \(currentLocation.coordinate.longitude)")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 教學 https://itisjoe.gitbooks.io/swiftgo/content/apps/taipeitravel/map.html
        myMapView.showsUserLocation = true //顯示使用者位置
        myMapView.delegate = self
        myMapView.zoomLevel = 20
        // 地圖使用  取得用戶目前所在位置的請求
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.delegate = self
        // 距離篩選器 用來設置移動多遠距離才觸發委任方法更新位置
        locationManager?.distanceFilter = kCLLocationAccuracyNearestTenMeters
        // 取得自身定位位置的精確度
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        // 设置地图的控制项(默认是ture)
        // myMapView.isScrollEnabled = false  // 滚动
        // myMapView.isRotateEnabled = false  // 旋转
        // myMapView.isZoomEnabled = false    // 缩放
        // Do any additional setup after loading the view.
        //-畫面配置------------------------------------------------------------------------
        var viewBounds = CGRect()
        //取得螢幕大小（不包括狀態列高度）
        viewBounds = CGRect(x:0,y:20, width: UIScreen.main.bounds.width,height:   UIScreen.main.bounds.height-20)
        let xLeft = 0
        let xTop = 20
        let xWidth = viewBounds.width
        let xHeight = viewBounds.height - 80 // CGFloat(myToolbar.frame.height)
        //---第一列MAPView----------------------------------------------------------------------
        // 要自己加自動配置，必須先關掉系統的自動配置功能
        myMapView.translatesAutoresizingMaskIntoConstraints = false
        // 左邊
        let nvleading = NSLayoutConstraint(item: myMapView as Any, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: CGFloat(xLeft))
        //上邊界
        let nvtop = NSLayoutConstraint(item: myMapView as Any,  attribute: .top, relatedBy: .equal,  toItem: self.view,            attribute: .top,  multiplier: 1.0, constant: CGFloat(xTop))
        // 寬度 參數二attribute:設.width(只是要設寬度而已)，參數四toItem: nil 沒有和別人關聯， 參數五attribute: .notAnAttribute
        let nvtrailing = NSLayoutConstraint(item: myMapView as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0,  constant: CGFloat(xWidth) )
        // 高度
        let nvheight = NSLayoutConstraint(item: myMapView as Any, attribute: .height, relatedBy: .equal, toItem:  nil, attribute: .notAnAttribute, multiplier: 1.0, constant:  CGFloat(xHeight))
        NSLayoutConstraint.activate([nvleading, nvtop ,nvheight ,nvtrailing ]) //
        //---第二列Toolbar----------------------------------------------------------------------
        // 要自己加自動配置，必須先關掉系統的自動配置功能
        //print(xHeight ) //647
        //print(myToolbar.frame.height ) //44
        myToolbar.translatesAutoresizingMaskIntoConstraints = false
        let barTop = CGFloat(xTop) + CGFloat(myMapView.frame.height)+80;
        let barHeight = CGFloat(myToolbar.frame.height) //44
        //print(barTop) //489
        //print(barHeight) //44
        // 左邊
        let baleading = NSLayoutConstraint(item: myToolbar as Any, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: CGFloat(xLeft))
        //上邊界
        let batop = NSLayoutConstraint(item: myToolbar as Any,  attribute: .top, relatedBy: .equal,  toItem: myMapView, attribute: .top,  multiplier: 1.0, constant: CGFloat(barTop))
        // 寬度 參數二attribute:設.width(只是要設寬度而已)，參數四toItem: nil 沒有和別人關聯， 參數五attribute: .notAnAttribute Constant 是指定的數字
        let batrailing = NSLayoutConstraint(item: myToolbar as Any, attribute: .width, relatedBy: .equal, toItem: myMapView, attribute: .width, multiplier: 1.0,  constant: CGFloat(xWidth) )
        // 高度
        let baheight = NSLayoutConstraint(item: myToolbar as Any, attribute: .height, relatedBy: .equal, toItem:  nil, attribute: .notAnAttribute, multiplier: 1.0, constant:  CGFloat(barHeight))
       // print(barHeight) //44
        NSLayoutConstraint.activate([baleading, batop ,baheight ,batrailing ]) //
        
    }

    func mapView(_ myMapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        myMapView.centerCoordinate = userLocation.location!.coordinate
        // 设置地图显示区域
        let xcenter = (userLocation.location?.coordinate)! // 使用者當前位置
        print("緯度： \(xcenter.latitude) : 經度： \(xcenter.longitude) ")
        // 区域跨度 (前面经度 后面纬度) 經度是直線y，緯度是橫線x
        let coordinate = CLLocationCoordinate2DMake(25.03331 , 121.475631);
        let zoomLevel = 0.02
        //创建一个 MKCoordinateSpan 对象，设置地图的范围（越小越精确）
        let span = MKCoordinateSpan.init(latitudeDelta: zoomLevel, longitudeDelta: zoomLevel)
        let region  = MKCoordinateRegion.init(center: coordinate, span: span);
        myMapView.setRegion(region, animated: true)
        
        let title = "奇勝資訊"
        let regionRadius = 300.0
        // 3. 設置 region 的相關屬性
        //let region2 = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,                                                                     longitude: coordinate.longitude), radius: regionRadius, identifier: title)
        //locationManager?.startMonitoring(for: region2) //開始監控
        // 4. 創建大頭釘(annotation)
        let restaurantAnnotation = MKPointAnnotation()
        restaurantAnnotation.coordinate = coordinate;
        restaurantAnnotation.title = "\(title)";
        myMapView.addAnnotation(restaurantAnnotation)
        // 5. 繪製一個圓圈圖形（用於表示 region 的範圍）
        let circle = MKCircle(center: coordinate, radius: regionRadius)
        myMapView.addOverlay(circle)
        
        
    }

    @IBAction func myZoomInButtonItemOnClick(_ sender: UIBarButtonItem) {
        //缩放级别范围是：2 - 20（其中 2 为世界地图）
        myMapView.zoomLevel =  myMapView.zoomLevel - 2

//        if let userLocation =  myMapView.userLocation.location?.coordinate {
//            //创建一个MKCoordinateSpan对象，设置地图的范围（越小越精确）
//            let latDelta = 0.05
//            let longDelta = 0.05
//            let span : MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
//            let center : CLLocationCoordinate2D = CLLocationCoordinate2DMake(25.03331 , 121.475631);
//            let region = MKCoordinateRegionMake( center, span )
//            myMapView.setRegion(region, animated: true)
//        }
    }
    
    @IBAction func myTypeButtonItemOnClick(_ sender: UIBarButtonItem) {
        if myMapView.mapType == MKMapType.standard {
            myMapView.mapType = MKMapType.satellite
        } else {
            myMapView.mapType = MKMapType.standard
        }
    }
  
    override func viewDidAppear(_ animated: Bool) {
        // https://www.appcoda.com.tw/geo-targeting-ios/
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
           // 首先要檢查用戶設備當前是否支持 region 範圍監控。如果用戶禁止了位置服務，關閉了後台App 刷新，或者設備處於飛行模式，isMonitoringAvailableForClass 方法將返回 false。
        }
        // 首次使用 向使用者詢問定位自身位置權限
        if CLLocationManager.authorizationStatus()  == .notDetermined {  // 首次詢問使用者
            // 取得定位服務授權
            locationManager?.requestWhenInUseAuthorization()
            // 開始定位自身位置
            locationManager?.startUpdatingLocation()
            
        }  else if CLLocationManager.authorizationStatus() == .denied { // 使用者拒絕了
            // 使用者已經拒絕定位自身位置權限
            // 提示可至[設定]中開啟權限
            let alertController = UIAlertController(
                title: "定位權限已關閉",
                message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
                preferredStyle: .alert)
            let okAction = UIAlertAction( title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present( alertController, animated: true, completion: nil)
            
        }  else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // 使用者已經同意定位自身位置權限
            // 開始定位自身位置
            locationManager?.startUpdatingLocation()
        }
    }
    
    func setupData() {
        // 1. 檢查系統是否能夠監視 region
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            // 2.準備 region 會用到的相關屬性
            let title = "Lorrenzillo's"
            let coordinate = CLLocationCoordinate2DMake(37.703026, -121.759735)
            let regionRadius = 300.0
            
            // 3. 設置 region 的相關屬性
            let region = CLCircularRegion(center:
                CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                , radius: regionRadius, identifier: title)
            locationManager?.startMonitoring(for: region)
            
            // 4. 創建大頭釘(annotation)
            let restaurantAnnotation = MKPointAnnotation()
            restaurantAnnotation.coordinate = coordinate;
            restaurantAnnotation.title = "\(title)";
            myMapView.addAnnotation(restaurantAnnotation)
            
            // 5. 繪製一個圓圈圖形（用於表示 region 的範圍）
            let circle = MKCircle(center: coordinate, radius: regionRadius)
            myMapView.addOverlay(circle)
        }
        else {
            print("System can't track regions")
        }
    }

    
}
