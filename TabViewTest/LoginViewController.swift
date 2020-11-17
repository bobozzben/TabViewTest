//
//  SubViewController.swift
//  TabViewTest
//
//  Created by Ben_Mac on 2017/12/7.
//  Copyright © 2017年 Ben_Mac. All rights reserved.
//

import UIKit
import CoreData

extension LoginViewController : LoginparamDelegate{
    func mySetparam(param: ILoginParams) {
        ServerIPTextView.text = param.serverIP
        PortTextView.text = param.port
        CompanyTextView.text = param.company
        UserTextView.text = param.userID
        PasswordTextView.text = param.password
        if  param.erp_xone == 1 {
            ErpxOneSegment.selectedSegmentIndex = 0
        } else {
            ErpxOneSegment.selectedSegmentIndex = 1
        }
    }
    
}

class LoginViewController: UIViewController ,UITextFieldDelegate{

    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var ServerIPTextView: UITextField!
    @IBOutlet weak var UserTextView: UITextField!
    @IBOutlet weak var PasswordTextView: UITextField!
    @IBOutlet weak var ErpxOneSegment: UISegmentedControl!
    @IBOutlet weak var CompanyTextView: UITextField!
    @IBOutlet weak var PortTextView: UITextField!
    @IBOutlet weak var LoginUILabel: UILabel!  // 登入中的LABEL
    
    @IBOutlet weak var goBack: UIButton!
    @IBOutlet weak var mGoLogin: UIButton!
    
    var timer = Timer()
    let connectionTimeOut_Seconds = 45
    var counter = 45
    var isTimerRunning = false
    var oSoapConnect = mySoapConnect()
    
    // 螢幕設定固定直式，不要自動轉向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 最先被執行，時間點在 View 被載入時，不論切換退出這個頁面幾次，一個頁面只會執行一次viewDidLoad()
        // 畫面載入後，類似 FormOnLoad

        LoginUILabel.isHidden = true

        //实现背景渐变
        // 220 235 255  135 175 230
        let btnTopColor = UIColor(red: (220/255.0), green: (235/255.0), blue:(255/255.0), alpha: 1)
        let btnButtomColor = UIColor(red: (135/255.0), green: (175/255.0), blue:(230/255.0), alpha: 1)
        // 235 235 130  250 250 185
        let bgTopColor = UIColor(red: (235/255.0), green: (235/255.0), blue:(130/255.0), alpha: 1)
        let bgButtomColor = UIColor(red: (250/255.0), green: (250/255.0), blue:(185/255.0), alpha: 1)
        
        //self.view.layer.insertSublayer(gradientLayer, at: 0)
        //myQueryButton.layer.insertSublayer(gradientLayer, at: 0)
        
        self.mGoLogin.applyGradient(colours: [btnTopColor, btnButtomColor])
        self.view.applyGradient(colours: [bgTopColor ,bgButtomColor], locations: [0.0,  1.0])

        // 按鈕變圓形
        let myLoginButtonmaskLayer = CAShapeLayer()
        let myLoginButtonbesizer = UIBezierPath(roundedRect: mGoLogin.bounds, // 要變圓的按鈕
            byRoundingCorners: [.allCorners], // 要變圓的角
            cornerRadii: CGSize(width: 10, height: 10)) // 圓周半徑
        myLoginButtonmaskLayer.path = myLoginButtonbesizer.cgPath
        self.mGoLogin.layer.mask = myLoginButtonmaskLayer;
        
        // -----------------------------------------------------
        // 要自己加自動配置，必須先關掉系統的自動配置功能
        NavigationBar.translatesAutoresizingMaskIntoConstraints = false
        // 左邊
        let nvleading = NSLayoutConstraint(item: NavigationBar as Any,
                                           attribute: .leading,
                                           relatedBy: .equal,
                                           toItem: self.view,
                                           attribute: .leading,
                                           multiplier: 1.0,
                                           constant: 1)
        // 寬度
        let nvtrailing = NSLayoutConstraint(item: NavigationBar as Any,
                                            attribute: .trailing,
                                            relatedBy: .equal,
                                            toItem: self.view,
                                            attribute: .trailing,
                                            multiplier: 1.0,
                                            constant: 1 )
        //上邊界
        let nvtop = NSLayoutConstraint(item: NavigationBar as Any,     // NavigationBar 的
            attribute: .top,     // 頂端
            relatedBy: .equal,   // 相等
            toItem: self.view,   // 與 畫面
            attribute: .top,     // 的頂端對齊
            multiplier: 1.0,     // 中間間隔的乘積為 1.0
            constant: 30)        // 中間的間隔為 30點 ，20點貼太近了
        //高度
        let nvheight = NSLayoutConstraint(item: NavigationBar as Any,
                                          attribute: .height,
                                          relatedBy: .equal,
                                          toItem: nil,
                                          attribute: .notAnAttribute,
                                          multiplier: 1.0,
                                          constant: 40.0)
        NSLayoutConstraint.activate([nvleading, nvtrailing, nvtop, nvheight])
        
        
        //let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        //backgroundImage.image = UIImage(named: "loginimg")
        //backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        //self.view.insertSubview(backgroundImage, at: 0)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 在viewDidLoad()之後被執行，時間點在 View 要被呈現前，每次切換到這個頁面時都會執行。
        // 畫面顯示前，類似 Form Activate
    }
    override func viewDidAppear(_ animated: Bool) {
        // 在viewWillAppear()之後被執行，時間點在 View 呈現後，每次切換到這個頁面時都會執行。
    }
    override func viewWillDisappear(_ animated: Bool) {
        // 執行的時間點在 View 要結束前，每次要切換到別頁或是退出這個頁面時都會執行。
        // 畫面顯示關閉前，類似 Form OnCloseQuery
    }
    override func viewDidDisappear(_ animated: Bool) {
        // 執行的時間點在 View 完全結束後，每次要切換到別頁或是退出這個頁面時都會執行。
        // 畫面顯示關閉前，類似 Form OnClose
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func viewDidLayoutSubviews() {
       // 執行點在畫面上的元件產生好後，不能在 viewDidLoad 調整位置，因為元件還沒產生
        
    }
    
    @objc func updateStatus() {
        self.counter -= 1
        self.LoginUILabel.text = "登入中請稍候... \(self.counter)"
        if self.oSoapConnect.returnvalue == "OK" {
            print("Login OK Operation 2  \(self.counter )")
            mysaveloginparams(succes: true)
            self.LoginUILabel.text = "登入成功"
            self.timer.invalidate()
            self.dismiss(animated: true , completion: nil)
        } else {
            print("Login fail Operation 2 \(self.counter ) ")
            if self.oSoapConnect.returnvalue == "連線錯誤" {
                self.timer.invalidate()
                let uiObject = UIObject()
                uiObject.showMessage(parent: self, msg: "連線錯誤，請檢查網路連線或IP是否正常。", boxTitle: "登入失敗")
                self.counter = 0
                self.LoginUILabel.text = "連線錯誤(失敗) \(self.counter)"
                mGoLogin.endEditing(true)
            } else if self.counter <= 0  {
                self.timer.invalidate()
                let uiObject = UIObject()
                uiObject.showMessage(parent: self, msg: "帳號或密碼錯誤。", boxTitle: "登入失敗")
                self.LoginUILabel.text = "帳號或密碼錯誤(失敗) \(self.counter)"
                mGoLogin.endEditing(true)
            }
        }
    }
    
    @IBAction func goBackOnClick(_ sender: UIButton) {
        // 取消
        print("Cancel")
        self.dismiss(animated: true , completion: nil)
    }
    
    @IBAction func goLoginOnClick(_ sender: UIButton) {
        self.counter = self.connectionTimeOut_Seconds
        mysaveloginparams(succes: false)  // 儲存登入參數
        // Operation Queue https://www.appcoda.com.tw/ios-concurrency/
        // 使用 BlockOperation – 這個類用一個或多個塊創建。它可以包含不止一個塊，只有當全部塊的代碼都執行完才視作該任務完成。
        let queue = OperationQueue()
        let operation1 = BlockOperation(block: {
            OperationQueue.main.addOperation({
            self.oSoapConnect.ServerIP = self.ServerIPTextView.text!
            self.oSoapConnect.ServerPort = self.PortTextView.text!
            self.oSoapConnect.ComparyNO = self.CompanyTextView.text!
            self.oSoapConnect.UserName = self.UserTextView.text!
            self.oSoapConnect.Password = self.PasswordTextView.text!
            if self.ErpxOneSegment.selectedSegmentIndex == 0 {
                self.oSoapConnect.ErpOrxOne = 1
            } else {
                self.oSoapConnect.ErpOrxOne = 2
            }
            self.oSoapConnect.returnvalue = ""
            self.oSoapConnect.myRunLogin()
            })
        })
        // 當區塊完成後會執行這一區塊
        operation1.completionBlock = {
            print("Operation 1 completed")
            DispatchQueue.main.sync { // Correct
              self.LoginUILabel.isHidden = false
              self.LoginUILabel.text = "登入中..."
              // 加一個 Timer 檢查回傳狀態，
              self.timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: (#selector( LoginViewController.updateStatus )), userInfo: nil, repeats: true)
             }
        }
        queue.addOperation(operation1 )
        mGoLogin.endEditing(false)

        print("Login 3333")
    }
    
    func mysaveloginparams(succes:Bool) {
        // 用來操作 Core Data 的常數
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
                    loginParams?.serverIP = ServerIPTextView.text!
                    loginParams?.port = PortTextView.text!
                    loginParams?.userID = UserTextView.text!
                    loginParams?.password = PasswordTextView.text!
                    if self.ErpxOneSegment.selectedSegmentIndex == 0 {
                        loginParams?.erp_xone = 1
                    } else {
                        loginParams?.erp_xone = 2
                    }
                    loginParams?.company = CompanyTextView.text!
                    print("111_string company \(String(describing: loginParams?.company!))")
                    loginParams?.signed = succes
                    try context.save()
                } catch {
                    fatalError("111.. \(error)")
                }
            }
        } catch {
            fatalError("222... \(error)")
        }

    }
    
    func showMessage(msg:String,boxTitle:String) {
        let alertController = UIAlertController(title: boxTitle, message: msg, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

   
    
    /*
    // MARK: - Navigation
    // 在一個基於故事板的應用程序中，您通常需要在導航之前做一些準備工作
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 使用 segue.destinationViewController 獲取新的視圖控制器。
        // Get the new view controller using segue.destinationViewController.
        // 將選定的對像傳遞給新的視圖控制器。
        // Pass the selected object to the new view controller.
    }
    // 啟動另一個畫面
    self.present(LoginView, animated: true, completion: nil)
    // 返回前一個畫面
    self.dismiss(animated: true , completion: nil)
    DispatchQueue.main.async { // Correct
      //支線程式不可更新UI，必須包在 DispatchQueue.main.async 下
    }
    延遲兩秒執行的範例  方法 1
    //DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    //    print("已延遲兩秒 \(self.oSoapConnect.returnvalue)")
    //    queue.addOperation(operation2 )
    //} 方法 2
    // self.perform(#selector(updateCounter), with: nil, afterDelay: delay)
    Timer 範例， Timer不可在主線程啟動，否則會被忽略
    //timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: //(#selector( LoginViewController.updateCounter )), userInfo: nil, repeats: true)
    */

}
