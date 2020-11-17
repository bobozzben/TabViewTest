//
//  FirstViewController.swift
//  TabViewTest
//
//  Created by Ben_Mac on 2017/12/6.
//  Copyright © 2017年 Ben_Mac. All rights reserved.
//

import UIKit
import CoreData
import SafariServices
import Speech



protocol LoginparamDelegate {
    func mySetparam( param: ILoginParams)
}
protocol QueryDataDelegate {
    func mySetparam( param: ILoginParams)
}
// http://www.developerq.com/article/1501836848  在Swift中設置按鈕上的背景漸層
extension UIView {
    //將颜色和位置定義在數组陣列
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        //創建並實例化 CAGradientLayer
        let gradient: CAGradientLayer = CAGradientLayer()
        //設定 frame 和插入 view 的 layer
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }  // 填入顏色，可多組
        //(這裹的起始和终止位置是按照坐標,四個角分别是左上(0,0),左下(0,1),右上(1,0),右下(1,1))
        // gradientLayer.startPoint = CGPoint(x:0, y:0)
        // gradientLayer.endPoint = CGPoint(x:1, y:1)
        //渲染的起始位置
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
}

class FirstViewController: UIViewController ,UITabBarControllerDelegate , SFSafariViewControllerDelegate ,SFSpeechRecognizerDelegate  {

    @IBOutlet weak var myQueryButton: UIButton!
    @IBOutlet weak var myLoginButton: UIButton!
    @IBOutlet weak var myPage3Button: UIButton!
    @IBOutlet weak var myPage4Button: UIButton!
    @IBOutlet weak var myOtherButton: UIButton!
    @IBOutlet weak var myWebPageButton: UIButton!
    @IBOutlet weak var textView2: UITextView!
    
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh-TW"))  //1
    
    var loginParams : ILoginParams?
    var loginParamdelegate: LoginparamDelegate?
    var queryDatadelegate: QueryDataDelegate?
    // 這裹的 LoginView 名稱定義在 右邊 Identity Storyboard ID
    var LoginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
    let QueryView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QueryView") as! SecondViewController


    // myFunction --------------------------------------------
    func myLogin() {
        // 登入 要開的畫面在上方定義
        self.present(LoginView, animated: true, completion: nil)
        // 傳參數進另一個畫面，使用代理 Delegate 的方式傳入
        self.loginParamdelegate = LoginView
        // 代理的 讓另一個類幫我做事，要建立一組 protocol ， 另一個畫面用 extension 實作
        self.loginParamdelegate?.mySetparam(param: loginParams!)
    }
    
    func myLogout() {
        // 登出 翻轉旗標並存入
        var loginParams : ILoginParams?
        let appDeletegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDeletegate.persistentContainer.viewContext
        let myLoginParams = "ILoginParams"
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: myLoginParams)
        do {
            let requests = try context.fetch(request)
            if requests.count > 0 {
                // 有設定過了
                do {
                    let ologinParams = try context.fetch(request)
                    loginParams = ologinParams[0] as? ILoginParams
                    loginParams?.signed = false
                    try context.save()
                } catch {
                    fatalError("111.. \(error)")
                }
            }
        } catch {
            fatalError("222... \(error)")
        }
        DispatchQueue.main.async { // Correct
            // 打開按鈕
            self.myLoginButton.setTitle(" 登入 " , for: .normal )
        }
        
    }

    //--------------------------------------------------------
    // 設定固定為直式
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
    
    func tabBarControllerSupportedInterfaceOrientations(_ tabBarController: UITabBarController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //-------------------------------------------------------------------------
        // 用來操作 Core Data 的常數 ，記錄登入的資訊
        let appDeletegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDeletegate.persistentContainer.viewContext
        let myLoginParams = "ILoginParams"
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: myLoginParams)
        do {
            let requests = try context.fetch(request)
            if requests.count > 0 {
                // 有設定過了
                do {
                    let ologinParams = try context.fetch(request)
                    loginParams = ologinParams[0] as? ILoginParams
                    //print("111_string \(String(describing: loginParams?.serverIP!))")
                    //loginParams?.port = "8700"
                    try context.save()
                } catch {
                    fatalError("111.. \(error)")
                }
            } else {
                // 新增一組
                loginParams = NSEntityDescription.insertNewObject(forEntityName: myLoginParams, into: context)  as? ILoginParams
                loginParams?.serverIP = "192.168.0.61"
                loginParams?.port = "8700"
                loginParams?.userID = "SUPERVISOR"
                loginParams?.password = "0000"
                loginParams?.signed = false
                loginParams?.erp_xone = 1
                loginParams?.remember = true
                loginParams?.company = ""
                do {
                    try context.save()
                } catch {
                    fatalError("111.. \(error)")
                }
            }
        } catch {
            fatalError("222... \(error)")
        }
        
        //-畫面配置------------------------------------------------------------------------
        var viewBounds = CGRect()
        //取得螢幕大小（不包括狀態列高度）
        viewBounds = CGRect(x:0,y:20, width: UIScreen.main.bounds.width,height:   UIScreen.main.bounds.height-20)
        let xCenter = Int( viewBounds.width / 2 )  // 正中間點
        let xTop1_3 = Int( viewBounds.height / 4 )  // 高度的1/3
        //-------------------------------------------------------------------------
        // 畫面上按鈕的LAYOUT
        let xcc = 15   // 間格
        let xTop = xTop1_3  // 上邊界
        let xTop2 = xTop1_3 + 90 + xcc  // 第二列上邊界
        let xLeft1 = xCenter - 45 - 90 - xcc // 第一欄 左邊界
        let xLeft2 = xCenter - 45  // 第二欄 左邊界
        let xLeft3 = xCenter + 45 + xcc // 第三欄 左邊界
        let buttonWidth = 90   // 按鈕寬
        let buttonHeight = 90  // 按鈕高
        //---第一列按鈕左中右----------------------------------------------------------------------
        // 要自己加自動配置，必須先關掉系統的自動配置功能
        myQueryButton.translatesAutoresizingMaskIntoConstraints = false
        // 左邊
        let nvleading = NSLayoutConstraint(item: myQueryButton as Any, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: CGFloat(xLeft1))
        //上邊界
        let nvtop = NSLayoutConstraint(item: myQueryButton!,  attribute: .top, relatedBy: .equal,  toItem: self.view,            attribute: .top,  multiplier: 1.0, constant: CGFloat(xTop))
        // 寬度 參數二attribute:設.width(只是要設寬度而已)，參數四toItem: nil 沒有和別人關聯， 參數五attribute: .notAnAttribute
        let nvtrailing = NSLayoutConstraint(item: myQueryButton as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0,  constant: CGFloat(buttonWidth) )
        // 高度
        let nvheight = NSLayoutConstraint(item: myQueryButton as Any, attribute: .height, relatedBy: .equal, toItem:  nil, attribute: .notAnAttribute, multiplier: 1.0, constant:  CGFloat(buttonHeight))
        NSLayoutConstraint.activate([nvleading, nvtop ,nvheight ,nvtrailing ]) //
        //-------------------------------------------------------------------------
        myPage3Button.translatesAutoresizingMaskIntoConstraints = false
        // 左邊
        let nvleading3 = NSLayoutConstraint(item: myPage3Button as Any, attribute: .leading,relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: CGFloat(xLeft2))
        //上邊界
        let nvtop3 = NSLayoutConstraint(item: myPage3Button as Any,  attribute: .top, relatedBy: .equal, toItem: self.view,  attribute: .top,  multiplier: 1.0,  constant: CGFloat(xTop))
        // 寬度
        let nvtrailing3 = NSLayoutConstraint(item: myPage3Button as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(buttonWidth) )
        // 高度
        let nvheight3 = NSLayoutConstraint(item: myPage3Button as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant:  CGFloat(buttonHeight))
        NSLayoutConstraint.activate([nvleading3, nvtop3 ,nvheight3 ,nvtrailing3  ])
        //-------------------------------------------------------------------------
        myPage4Button.translatesAutoresizingMaskIntoConstraints = false
        // 左邊
        let nvleading4 = NSLayoutConstraint(item: myPage4Button as Any, attribute: .leading,relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: CGFloat(xLeft3))
        // 上邊界
        let nvtop4 = NSLayoutConstraint(item: myPage4Button as Any, attribute: .top, relatedBy: .equal, toItem: self.view,  attribute: .top,  multiplier: 1.0,  constant: CGFloat(xTop))
        // 寬度
        let nvtrailing4 = NSLayoutConstraint(item: myPage4Button as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(buttonWidth) )
        // 高度
        let nvheight4 = NSLayoutConstraint(item: myPage4Button as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(buttonHeight))
        NSLayoutConstraint.activate([nvleading4, nvtop4 ,nvheight4 ,nvtrailing4 ])
        //--第二列按鈕-----------------------------------------------------------------------
        myOtherButton.translatesAutoresizingMaskIntoConstraints = false
        // 左邊
        let nvleadingl2_1 = NSLayoutConstraint(item: myOtherButton as Any, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: CGFloat(xLeft1))
        //上邊界
        let nvtopl2_1 = NSLayoutConstraint(item: myOtherButton as Any,  attribute: .top, relatedBy: .equal,  toItem: self.view,            attribute: .top,  multiplier: 1.0, constant: CGFloat(xTop2))
        // 寬度 參數二attribute:設.width(只是要設寬度而已)，參數四toItem: nil 沒有和別人關聯， 參數五attribute: .notAnAttribute
        let nvtrailingl2_1 = NSLayoutConstraint(item: myOtherButton as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0,  constant: CGFloat(buttonWidth) )
        // 高度
        let nvheightl2_1 = NSLayoutConstraint(item: myOtherButton as Any, attribute: .height, relatedBy: .equal, toItem:  nil, attribute: .notAnAttribute, multiplier: 1.0, constant:  CGFloat(buttonHeight))
        NSLayoutConstraint.activate([nvleadingl2_1, nvtopl2_1 ,nvheightl2_1 ,nvtrailingl2_1 ]) //
        //-------------------------------------------------------------------------
        myWebPageButton.translatesAutoresizingMaskIntoConstraints = false
        // 左邊
        let nvleading2_2 = NSLayoutConstraint(item: myWebPageButton as Any, attribute: .leading,relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: CGFloat(xLeft2))
        //上邊界
        let nvtop2_2 = NSLayoutConstraint(item: myWebPageButton as Any,  attribute: .top, relatedBy: .equal, toItem: self.view,  attribute: .top,  multiplier: 1.0,  constant: CGFloat(xTop2))
        // 寬度
        let nvtrailing2_2 = NSLayoutConstraint(item: myWebPageButton as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(buttonWidth) )
        // 高度
        let nvheight2_2 = NSLayoutConstraint(item: myWebPageButton as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant:  CGFloat(buttonHeight))
        NSLayoutConstraint.activate([nvleading2_2, nvtop2_2 ,nvheight2_2 ,nvtrailing2_2  ])
        //-------------------------------------------------------------------------
        myLoginButton.translatesAutoresizingMaskIntoConstraints = false
        // 左邊
        let nvleading2_3 = NSLayoutConstraint(item: myLoginButton as Any, attribute: .leading,relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: CGFloat(xLeft3))
        // 上邊界
        let nvtop2_3 = NSLayoutConstraint(item: myLoginButton as Any, attribute: .top, relatedBy: .equal, toItem: self.view,  attribute: .top,  multiplier: 1.0,  constant: CGFloat(xTop2))
        // 寬度
        let nvtrailing2_3 = NSLayoutConstraint(item: myLoginButton as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(buttonWidth) )
        // 高度
        let nvheight2_3 = NSLayoutConstraint(item: myLoginButton as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(buttonHeight))
        NSLayoutConstraint.activate([nvleading2_3, nvtop2_3 ,nvheight2_3 ,nvtrailing2_3 ])
        //-------------------------------------------------------------------------

        
        // Do any additional setup after loading the view, typically from a nib.
        self.tabBarController?.delegate = self  // 代理
        self.navigationController?.title = "第一頁-首頁"
        //self.navigationController?.navigationBar.barTintColor = UIColor.white
        //self.view.backgroundColor = UIColor.white

        // View的背景漸層
        // 235 235 130  250 250 185
        let bgTopColor = UIColor(red: (235/255.0), green: (235/255.0), blue:(130/255.0), alpha: 1)
        let bgButtomColor = UIColor(red: (250/255.0), green: (250/255.0), blue:(185/255.0), alpha: 1)
        self.view.applyGradient(colours: [bgTopColor ,bgButtomColor], locations: [0.0,  1.0])
        // 按鈕的背景漸層
        // 200 235 250  150 215 250
        let btnTopColor = UIColor(red: (200/255.0), green: (235/255.0), blue:(250/255.0), alpha: 1)
        let btnButtomColor = UIColor(red: (150/255.0), green: (215/255.0), blue:(250/255.0), alpha: 1)
        self.myQueryButton.applyGradient(colours: [btnTopColor, btnButtomColor])
        self.myOtherButton.applyGradient(colours: [btnTopColor, btnButtomColor])
        self.myPage3Button.applyGradient(colours: [btnTopColor, btnButtomColor])
        self.myPage4Button.applyGradient(colours: [btnTopColor, btnButtomColor])
        self.myLoginButton.applyGradient(colours: [btnTopColor, btnButtomColor])
        self.myWebPageButton.applyGradient(colours: [btnTopColor, btnButtomColor])
        //myQueryButton.setTitle("查詢", for: .normal)
        //myPage3Button.setTitle("設定", for: .normal)
        //self.view.layer.insertSublayer(gradientLayer, at: 0)
        //myQueryButton.layer.insertSublayer(gradientLayer, at: 0)
        // 測試按鈕圖示  圖示和漸層只能2選1
        //myQueryButton.setImage( UIImage(named: "search_48x48"), for: .normal)
        //myQueryButton.setBackgroundImage(UIImage(named: "search_48x48"), for: .normal)
        //self.myOtherButton.applyGradient(colours: [btnTopColor, btnButtomColor])
        // 按鈕變圓形
        let cornerwidth = 20
        let cornerheight = 30
        let myLoginButtonmaskLayer = CAShapeLayer()
        let myQueryButtonmaskLayer = CAShapeLayer()
        let myOtherButtonmaskLayer = CAShapeLayer()
        let myPage3ButtonmaskLayer = CAShapeLayer()
        let myPage4ButtonmaskLayer = CAShapeLayer()
        let myWebPageButtonmaskLayer = CAShapeLayer()
        let myLoginButtonbesizer = UIBezierPath(roundedRect: myLoginButton.bounds, // 要變圓的按鈕
            byRoundingCorners: [.allCorners], // 要變圓的角
            cornerRadii: CGSize(width: cornerwidth, height: cornerheight)) // 圓周半徑
        let myQueryButtonbesizer = UIBezierPath(roundedRect: myQueryButton.bounds, // 要變圓的按鈕
            byRoundingCorners: [.allCorners], // 要變圓的角
            cornerRadii: CGSize(width: cornerwidth, height: cornerheight)) // 圓周半徑
        let myOtherButtonbesizer = UIBezierPath(roundedRect: myOtherButton.bounds, // 要變圓的按鈕
            byRoundingCorners: [.allCorners], // 要變圓的角
            cornerRadii: CGSize(width: cornerwidth, height: cornerheight)) // 圓周半徑
        let myPage3Buttonbesizer = UIBezierPath(roundedRect: myPage3Button.bounds, // 要變圓的按鈕
            byRoundingCorners: [.allCorners], // 要變圓的角
            cornerRadii: CGSize(width: cornerwidth, height: cornerheight)) // 圓周半徑
        let myPage4Buttonbesizer = UIBezierPath(roundedRect: myPage4Button.bounds, // 要變圓的按鈕
            byRoundingCorners: [.allCorners], // 要變圓的角
            cornerRadii: CGSize(width: cornerwidth, height: cornerheight)) // 圓周半徑
        let myWebPageButtonbesizer = UIBezierPath(roundedRect: myPage4Button.bounds, // 要變圓的按鈕
            byRoundingCorners: [.allCorners], // 要變圓的角
            cornerRadii: CGSize(width: cornerwidth, height: cornerheight)) // 圓周半徑
        myLoginButtonmaskLayer.path = myLoginButtonbesizer.cgPath
        myQueryButtonmaskLayer.path = myQueryButtonbesizer.cgPath
        myOtherButtonmaskLayer.path = myOtherButtonbesizer.cgPath
        myPage3ButtonmaskLayer.path = myPage3Buttonbesizer.cgPath
        myPage4ButtonmaskLayer.path = myPage4Buttonbesizer.cgPath
        myWebPageButtonmaskLayer.path = myWebPageButtonbesizer.cgPath
        self.myLoginButton.layer.mask = myLoginButtonmaskLayer;
        self.myQueryButton.layer.mask = myQueryButtonmaskLayer;
        self.myOtherButton.layer.mask = myOtherButtonmaskLayer;
        self.myPage3Button.layer.mask = myPage3ButtonmaskLayer;
        self.myPage4Button.layer.mask = myPage4ButtonmaskLayer;
        self.myWebPageButton.layer.mask = myWebPageButtonmaskLayer;
        //self.myPage3Button.layer.masksToBounds = true //.cornerRadius = radius
        //self.myPage3Button.currentTitle = ""
        
        // 設定 tabbar 的底色
        self.tabBarController?.tabBar.isTranslucent = false
        let barTopColor = UIColor(red: (200/255.0), green: (235/255.0), blue:(250/255.0), alpha: 1)
        let barButtomColor = UIColor(red: (150/255.0), green: (215/255.0), blue:(250/255.0), alpha: 1)
        self.tabBarController?.tabBar.applyGradient(colours: [barTopColor,barButtomColor] )

    }

    override func viewDidAppear(_ animated: Bool) {
        //取得螢幕大小（不包括狀態列高度）
        let viewBounds:CGRect = CGRect(x:0,y:20, width: UIScreen.main.bounds.width,height:   UIScreen.main.bounds.height-20)
        //let viewBounds:CGRect = CGRect(x:0,y:0, width: UIScreen.main.bounds.width,height:   UIScreen.main.bounds.height)
        print("viewDidAppear Page1 \(viewBounds) " ) //iPhone6输出：（0.0,20.0,375.0,647.0） iPhone5 (0.0, 20.0, 320.0, 548.0) (0.0, 0.0, 320.0, 568.0)
        if loginParams!.signed == true {
            myLoginButton.setTitle("登出", for: .normal)
            //myLoginButton.setImage( UIImage(named: "logout"), for: .normal)
            print(" Page1 before selected ")
        } else {
            myLoginButton.setTitle("登入", for: .normal)
            //myLoginButton.setImage( UIImage(named: "user"), for: .normal)
            print(" Page1 after selected ")
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITabBarControllerDelegate --------------------------------------------------------
    // 要得知現在停在第幾頁，必須代理 UITabBarControllerDelegate 並覆寫 tabBarController
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print(" selected \(tabBarController.selectedIndex)")
        if tabBarController.selectedIndex > 0 {
            if loginParams!.signed == true {
               //有登入成功
            } else {
               // 未登入，導向登入畫面
                myLogin()
            }
            if viewController == tabBarController.selectedViewController {
                // print(" true \(String(describing: viewController.tabBarItem.title)) ")
            } else {
                // print(" Else  \(String(describing: viewController.tabBarItem.title)) ")
            }
        }
        
    }

    // Button Action --------------------------------------------------------

    @IBAction func myLoginButtonOnClick(sender : AnyObject){
        if loginParams!.signed == true {
           myLogout() // 執行登出
        } else {
           myLogin()  // 未登入，導到登入畫面
        }
    }
    
    @IBAction func myQueryButtonOnClick(sender : AnyObject){
        // 查詢畫面的
        if loginParams!.signed == true {
           self.tabBarController?.selectedIndex = 1
        } else {
            myLogin() //
        }
        print("QueryButtion_OnClick")
    }
   
    
    @IBAction func myPage3ButtonOnClick(_ sender: AnyObject) {
        // Page3 Button
        if loginParams!.signed == true {
            self.tabBarController?.selectedIndex = 2
        } else {
            myLogin()
        }
        print("Page3Buttion_OnClick")
    }
    
    @IBAction func myPage4ButtonOnClick(_ sender: AnyObject) {
        // Page4 Button
        //if loginParams!.signed == true {
            self.tabBarController?.selectedIndex = 3
        //} else {
           //　 myLogin()
        //}
        print("Page4Buttion_OnClick")
        
    }
   
    @IBAction func myButton2OnClick(sender : AnyObject){
        
       // let ObjectiveCView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ObjectiveCView") as! ObjectiveCViewController

        // ObjectiveCView
       // self.present(ObjectiveCView, animated: true, completion: nil)
        
        /*
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            myOtherButton.isEnabled = false
            myOtherButton.setTitle("開始", for: .normal)
        } else {
            startRecording()
            myOtherButton.setTitle("結束", for: .normal)
        } */
        
        // Page2 Button
        //if loginParams!.signed == true {
        //    self.tabBarController?.selectedIndex = 2
        //} else {
        //    myLogin()
        //}
        print("Page2Buttion_OnClick")
        
    }
    
    @IBAction func myWebPageButtonOnClick(_ sender: AnyObject) {
        // WebPage Button
        let url = URL(string: "http://www.hi-square.com.tw/")!
        if #available(iOS 9.0, *) { //確保是在 iOS9 之後的版本執行
            let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            safariVC.delegate = self
            self.present(safariVC, animated: true, completion: nil)
        } else { // iOS 8 以下的話跳出 App 使用 Safari 開啟
            UIApplication.shared.openURL(url)
        }
        print("WebPageButtion_OnClick")
        
    }

    //---連SQLite未測試----------------------------------------------------------------
    var db :SQLiteConnect?
    func mySQLDBTest() {
        // 資料庫檔案的路徑
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let sqlitePath = urls[urls.count-1].absoluteString + "loginParams.db"
        // 印出儲存檔案的位置
        print(sqlitePath)
        // SQLite 資料庫
        db = SQLiteConnect(path: sqlitePath)
        if let mydb = db {
            // create table
            let _ = mydb.createTable("loginParams", columnsInfo: [
                "id integer primary key autoincrement"
                ,"serverip text"
                ,"userid text"
                ,"password text"
                ,"erp_xone integer"
                ,"remember integer"
                ,"signed integer"
                ])
            // insert
            let _ = mydb.insert("loginParams", rowInfo: [
                "serverip":"'192.168.0.61'"
                ,"userid":"'SUPERVISOR'"
                ,"password":"'masterkey'"
                ,"erp_xone":"1"
                ,"remember":"1"
                ,"signed":"1"
                ])
            // select
            let statement = mydb.fetch("loginParams", cond: "1 == 1", order: nil)
            while sqlite3_step(statement) == SQLITE_ROW{
                let id = sqlite3_column_int(statement, 0)
                let serverip = String(cString:sqlite3_column_text(statement, 1))
                let userid = String(cString: sqlite3_column_text(statement, 2))
                let password = String(cString:sqlite3_column_text(statement, 3))
                let erp_xone = sqlite3_column_int(statement, 4)
                let remember = sqlite3_column_int(statement, 5)
                let signed   = sqlite3_column_int(statement, 6)
                print("\(id). IP \(serverip) ID： \(userid) pass:\(password) erpxone: \(erp_xone) remember: \(remember) signed: \(signed) ")
            }
            sqlite3_finalize(statement)
            // update
            let _ = mydb.update("loginParams", cond: "id = 1", rowInfo: ["remember":"0","signed":"0"])
            // delete
            let _ = mydb.delete("loginParams", cond: "1 = 1")
        }

    }

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            myOtherButton.isEnabled = true
        } else {
            myOtherButton.isEnabled = false
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.textView2.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.myOtherButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        textView2.text = "說點什麼..."
        
    }
    
}

