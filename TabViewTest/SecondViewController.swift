//
//  SecondViewController.swift
//  TabViewTest
//
//  Created by Ben_Mac on 2017/12/6.
//  Copyright © 2017年 Ben_Mac. All rights reserved.
//

import UIKit
//import CoreData

class SecondViewController: UIViewController , UITableViewDelegate ,UITableViewDataSource ,XMLParserDelegate ,UITextFieldDelegate {
    
    @IBOutlet weak var TestLabel: UILabel!
    @IBOutlet weak var QueryLabel: UILabel!
    @IBOutlet weak var QueryText: UITextField!
    @IBOutlet weak var QueryButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var StockBarButton: UIBarButtonItem!
    @IBOutlet weak var CustomBarButton: UIBarButtonItem!
    @IBOutlet weak var SupplierBarButton: UIBarButtonItem!
    @IBOutlet weak var BillBarButton: UIBarButtonItem!
    @IBOutlet weak var StackView: UIStackView!
    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var BottomTabBar: UITabBarItem!
    
    @IBOutlet weak var NavigationBarItem: UINavigationItem!
    
    var viewBounds = CGRect()
    var myServerIP : String = ""
    var myPort : String = ""
    var myCompany : String = ""
    var myUserID : String = ""
    var myPassword : String = ""                      
    var myErp_xone : Int = 1
    var mysigned : Bool = false
    var myQueryKind : String = ""
    var currentElementName = ""
    var returnvalue :String = ""
    var dataArray = [AnyObject]()

    let ShowDetailView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShowDetailView") as! ShowDetialViewController

    // my Function   ---------------------------------------------------------------
    func mySelfGetParams() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let myEntityName = "ILoginParams"
        let coreDataConnect = CoreDataConnect(context: context)
        // select
        let selectResult = coreDataConnect.getdata(myEntityName)
        if let results = selectResult {
            for result in results {
                myServerIP = result.value(forKey: "serverIP") as! String
                myPort = result.value(forKey: "port") as! String
                myCompany = result.value(forKey: "company") as! String
                myUserID = result.value(forKey: "userID") as! String
                myPassword = result.value(forKey: "password") as! String
                myErp_xone = result.value(forKey: "erp_xone") as! Int
                mysigned = (result.value(forKey: "signed") != nil)
                print("mySelfGetParams IP \(result.value(forKey: "serverIP")!) Company. \(result.value(forKey: "company")!) ： \(result.value(forKey: "userID")!)")
            }
        }
        print("\(myUserID)  :  \(myPassword)  ")
        if myQueryKind.isEmpty {
           myQueryKind = "STOCK"
          // StockBarButton?.tintColor = UIColor.blue
           myRefreshBarButtonItem()
        }
        
    }
    
    func myRefreshBarButtonItem() {

        var myPressButton = UIBarButtonItem()
        let mSystemVer = UIObject().sysVersion

        if  mSystemVer > "10.3" {
            StockBarButton?.tintColor = UIColor.lightGray // 文字顏色
            BillBarButton?.tintColor = UIColor.lightGray // 文字顏色
            CustomBarButton?.tintColor = UIColor.lightGray // 文字顏色
            SupplierBarButton?.tintColor = UIColor.lightGray // 文字顏色

        } else  {
            let disattrs = [
                NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                NSAttributedString.Key.font: UIFont(name: "Georgia", size: 16)!
            ]
            StockBarButton?.setTitleTextAttributes(disattrs , for: .normal)
            BillBarButton?.setTitleTextAttributes(disattrs , for: .normal)
            CustomBarButton?.setTitleTextAttributes(disattrs , for: .normal)
            SupplierBarButton?.setTitleTextAttributes(disattrs , for: .normal)

        }
        

        if myQueryKind == "STOCK" {
            myPressButton = StockBarButton!
            QueryLabel.text = " 品 號 "
        } else if myQueryKind == "BILL" {
            myPressButton = BillBarButton!
            QueryLabel.text = " 單 號 "
        } else if myQueryKind == "CUSTOM" {
            myPressButton = CustomBarButton!
            QueryLabel.text = " 編 號 "
        } else if myQueryKind == "SUPPLIER" {
            myPressButton = SupplierBarButton!
            QueryLabel.text = " 編 號 "
        }
        
        if mSystemVer > "10.3" {
           // iOS 11 沒作用，只能用文字顏色
           myPressButton.tintColor = UIColor.blue // 文字顏色
        } else  {
           // IOS 10.3 以後沒有作用
           let attrs = [
               NSAttributedString.Key.foregroundColor: UIColor.blue,
               NSAttributedString.Key.font: UIFont(name: "Georgia-Bold", size: 20)!  ]
           myPressButton.setTitleTextAttributes(attrs , for: .focused)
        }
        
       // NavigationBarItem.leftBarButtonItem?.setTitleTextAttributes(disattrs, for: .normal)
       // NavigationBarItem.leftBarButtonItem?.setTitleTextAttributes(attrs, for: .highlighted)
        
        /* 以下可設定字型大小及屬性
        QueryLabel.textColor = UIColor.blue // 文字顏色
        //QueryLabel.font = UIFont(name: "Helvetica-Light", size: 20) // 文字的字型與大小
        //QueryLabel.font = QueryLabel.font.withSize(24) // 可以再修改文字的大小
        QueryLabel.font = UIFont.systemFont(ofSize: 24) // 或是可以使用系統預設字型 並設定文字大小
        // 設定文字位置 置左、置中或置右等等
        QueryLabel.textAlignment = NSTextAlignment.center  // 也可以簡寫成這樣 QueryLabel.textAlignment = .center
        QueryLabel.numberOfLines = 1  // 文字行數
        QueryLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail  // 文字過多時 過濾的方式
        QueryLabel.shadowColor = UIColor.black // 陰影的顏色 如不設定則預設為沒有陰影
        QueryLabel.shadowOffset = CGSize(width: 2, height: 2) // 陰影的偏移量 需先設定陰影的顏色
        */
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    //UIViewController -----------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        //取得螢幕大小（不包括狀態列高度）
        viewBounds = CGRect(x:0,y:20, width: UIScreen.main.bounds.width,height:   UIScreen.main.bounds.height-20)

        // Do any additional setup after loading the view, typically from a nib.
        // 設定代理
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        //設定成高度會依長度自動折行
        //1. 設定 estimatedRowHeight 屬性的預設值
        tableView.estimatedRowHeight = 44.0;
        //2. rowHeight属性設成 UITableViewAutomaticDimension
        tableView.rowHeight = UITableView.automaticDimension;
        //QueryButton.backgroundColor = UIColor.darkGray // 按鈕背景顏色
        //tableView.backgroundColor = UIColor.darkGray
        NavigationBar.backgroundColor = UIColor.darkGray

        // -----------------------------------------------------
        // 要自己加自動配置，必須先關掉系統的自動配置功能
        NavigationBar.translatesAutoresizingMaskIntoConstraints = false
        StackView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // item 是要設定constraint的圖形元素,也可以是其他的圖形元素(button、label、image view等)。
        // attribute 是透過簡單的文字去描述我們設定的constraint類型(例如：leading、trailing、top…等)，它是 NSLayoutAttribute 的 value
        // relatedBy 表示視圖attribute屬性設定的constraint與其他視圖attribute屬性的關係，它是一個NSLayoutRelation值，簡單來說，它提供一個選項，讓第一個attribute參數值可選擇等於、大於或是小於下一個參數值。
        // toItem 是另一個視圖，用來做為原視圖constraint設定的參考點，在某些時候它可以為nil。
        // attribute 參數(第二個)是參考視圖的constraint type，它用來表達與目標視圖的attribute之間約束關係，relatedBy參數值用來指定對應關係。
        // multiplier 參數將第二個attribute參數的值乘以另一個做為參數給定的值。通常設置的默認值為1.0。
        // constant 的值會被加到第二個attribute參數，因而讓item內所設定的視圖生成預期的結果。
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
        
        // 左邊
        let svleading = NSLayoutConstraint(item: StackView as Any,
                                           attribute: .leading,
                                           relatedBy: .equal,
                                           toItem: self.view,
                                           attribute: .leading,
                                           multiplier: 1.0,
                                           constant: 1)
        // 寬度
        let svtrailing = NSLayoutConstraint(item: StackView as Any,
                                            attribute: .trailing,
                                            relatedBy: .equal,
                                            toItem: self.view,
                                            attribute: .trailing,
                                            multiplier: 1.0,
                                            constant: 1 )
        //上邊界
        let svtop = NSLayoutConstraint(item: StackView as Any,     // StackView 的
            attribute: .top,     // 頂端
            relatedBy: .equal,   // 相等
            toItem: NavigationBar,   // 與 導覽列
            attribute: .bottom,     // 的底端對齊
            multiplier: 1.0,     // 中間間隔的乘積為 1.0
            constant: 2)        // 中間的間隔為2點
        //高度
        let svheight = NSLayoutConstraint(item: StackView as Any,
                                          attribute: .height,
                                          relatedBy: .equal,
                                          toItem: nil,
                                          attribute: .notAnAttribute,
                                          multiplier: 1.0,
                                          constant: 50.0)
        NSLayoutConstraint.activate([svleading, svtrailing, svtop, svheight])

        
        let tvleading = NSLayoutConstraint(item: tableView as Any,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self.view,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 1.0)
        
        let tvtrailing = NSLayoutConstraint(item: tableView!,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: self.view,
                                          attribute: .trailing,
                                          multiplier: 1.0,
                                          constant: 1.0)
        
        let tvtop = NSLayoutConstraint(item: tableView as Any,     // tableView的
                                     attribute: .top,     // 頂端
                                     relatedBy: .equal,   // 相等
                                     toItem: StackView,   // 與 StackView
                                     attribute: .bottom,  // 的底端對齊
                                     multiplier: 1.0,     // 中間間隔的乘積為 1.0
                                     constant: 1.0)         // 中間的間隔為5點
     
        let tvheight = NSLayoutConstraint(item: tableView as Any,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: self.view,
                                        attribute: .height,
                                        multiplier: 1.0,
                                        constant: -105.0)  // 中間的高度要減掉上方狀態列+NavigationBar + StackView 的高度
        NSLayoutConstraint.activate([tvleading, tvtrailing, tvtop, tvheight])
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
      print("viewDidAppear Page2 ")
      mySelfGetParams()
      myRefreshBarButtonItem()
        
    }

    // UITableViewDelegate  ---------------------------------------------------------------
    
    // 必須實作的方法：每一組有幾個 cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (dataArray.count > 0) {
            print("JSON_bb_111: \(dataArray.count )" )
            //依據動物數量呈現
            return dataArray.count;
        } else {
            return 0;
        }
    }
    
    // 顯示列資料
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // print("JSON_cc_111:" )
        // 要注意，畫面上看不到 tableview 會連事件也不會觸發，只會走到上面 numberOfRowsInSection 的事件就停了
        // CELL 重用機制，ViewDidLoad 必須註冊一列Cell register 的 forCellReuseIdentifier = withIdentifier 名稱要相同
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        cell.accessoryType = .detailButton // ! 圈圈金嘆號
        // cell.accessoryType = .detailDisclosureButton  //! 圈圈金嘆號和右箭頭
        // cell.accessoryType = .disclosureIndicator // 右箭頭
        // cell.accessoryType = .checkmark // 勾勾
        //3. cell.textLabel?.numberOfLines = 0 設成 0,即會自動折行
        cell.textLabel?.numberOfLines = 0
        //cell.textLabel?.numberOfLines = 10

        switch myQueryKind {
        case "BILL":
           // cell.textLabel?.numberOfLines = 6
            cell.textLabel?.text = "表頭：" + (dataArray[indexPath.row]["品號"]  as? String)! + " " + (dataArray[indexPath.row]["品名"]  as? String)!
            cell.textLabel?.text?.append("客戶編號：" + (dataArray[indexPath.row]["客戶編號"]  as? String)! )

        case "CUSTOM":
           // cell.textLabel?.numberOfLines = 10
            cell.textLabel?.text = "客戶：" + (dataArray[indexPath.row]["客戶編號"]  as? String)! + " " + (dataArray[indexPath.row]["客戶名稱"]  as? String)!
            cell.textLabel?.text?.append("\n" + "統一編號：" + (dataArray[indexPath.row]["統一編號"]  as? String)! )
            cell.textLabel?.text?.append("\n" + "聯絡人：" + (dataArray[indexPath.row]["聯絡人"]  as? String)! )
            cell.textLabel?.text?.append("\n" + "公司地址：" + (dataArray[indexPath.row]["地址"]  as? String)! )
            cell.textLabel?.text?.append("\n" + "送貨地址：" + (dataArray[indexPath.row]["送貨地址"]  as? String)! )
            if myErp_xone == 1 {
               cell.textLabel?.text?.append("\n" + "客戶備註：" + (dataArray[indexPath.row]["客戶備註"]  as? String)! )
            } else {
               cell.textLabel?.text?.append("\n" + "客戶備註：" + (dataArray[indexPath.row]["備註一"]  as? String)! )
            }

        case "SUPPLIER":
           // cell.textLabel?.numberOfLines = 10
            cell.textLabel?.text = "廠商：" + (dataArray[indexPath.row]["廠商編號"]  as? String)! + " " + (dataArray[indexPath.row]["廠商名稱"]  as? String)!
            if myErp_xone == 1 {
                cell.textLabel?.text?.append("\n" + "統一編號：" + (dataArray[indexPath.row]["統一編號"]  as? String)! )
                cell.textLabel?.text?.append("\n" + "聯絡人：" + (dataArray[indexPath.row]["聯絡人"]  as? String)! )
                cell.textLabel?.text?.append("\n" + "廠商地址：" + (dataArray[indexPath.row]["廠商地址"]  as? String)! )
                cell.textLabel?.text?.append("\n" + "電話：" + (dataArray[indexPath.row]["電話"]  as? String)! )
                cell.textLabel?.text?.append("\n" + "廠商備註：" + (dataArray[indexPath.row]["廠商備註"]  as? String)! )
            } else {
                cell.textLabel?.text?.append("\n" + "統一編號：" + (dataArray[indexPath.row]["統編"]  as? String)! )
                cell.textLabel?.text?.append("\n" + "聯絡人：" + (dataArray[indexPath.row]["聯絡人"]  as? String)! )
                cell.textLabel?.text?.append("\n" + "廠商地址：" + (dataArray[indexPath.row]["地址"]  as? String)! )
                cell.textLabel?.text?.append("\n" + "電話：" + (dataArray[indexPath.row]["電話"]  as? String)! )
                cell.textLabel?.text?.append("\n" + "廠商備註：" + (dataArray[indexPath.row]["備註一"]  as? String)! )
            }
            
        default: //"STOCK"
           // cell.textLabel?.numberOfLines = 2
            cell.textLabel?.text = "品號：" + (dataArray[indexPath.row]["品號"]  as? String)! + " " + (dataArray[indexPath.row]["品名"]  as? String)!
            cell.textLabel?.text?.append("\n" + "倉庫：" + (dataArray[indexPath.row]["倉庫"]  as? String)! + " " + (dataArray[indexPath.row]["倉名"]  as? String)! )
            cell.textLabel?.numberOfLines = 10
            cell.textLabel?.text?.append("\n" + "帳上數：" + (dataArray[indexPath.row]["帳上數"]  as? String)! )
            cell.textLabel?.text?.append("\n" + "帳上數(進銷單位)：" + (dataArray[indexPath.row]["帳上數(進銷單位)"]  as? String)! )
            cell.textLabel?.text?.append("\n" + "實際可用數：" + (dataArray[indexPath.row]["實際可用數"]  as? String)! )
            cell.textLabel?.text?.append("\n" + "實際可用數(進銷單位)：" + (dataArray[indexPath.row]["實際可用數(進銷單位)"]  as? String)! )

        }

        return cell;
        
    }
    
    // 點擊一列觸發
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        // 取消 cell 的選取狀態
        tableView.deselectRow( at: indexPath, animated: true)
        
        switch myQueryKind {
        case "BILL":
            let name = (dataArray[indexPath.row]["單號"] as? String)!
            print("選擇的是 \(name)")

        case "CUSTOM":
            let name = (dataArray[indexPath.row]["客戶編號"] as? String)!
            print("選擇的是 \(name)")
            if myErp_xone == 1 {
            } else {
            }
            
        case "SUPPLIER":
            let name = (dataArray[indexPath.row]["廠商編號"] as? String)!
            print("選擇的是 \(name)")
            if myErp_xone == 1 {
            } else {
            }
            
        default: //"STOCK"
            let name = (dataArray[indexPath.row]["品號"] as? String)!
            print("選擇的是 \(name)")
        }
        
        // 取得當前列的 JSON         JSON 教學 https://developer.apple.com/swift/blog/?id=37
        let jsonitem = dataArray[indexPath.row] as? [String:Any]
        // print(jsonitem ?? String())
        // 遍尋此列 JSON
        for (key, value) in jsonitem! {
            print("key:\(key) ,Value:\(value) " )
        }
        // 登入 要開的畫面在上方定義
        ShowDetailView.myJsonData = jsonitem! //(dataArray[indexPath.row] as? [String:Any])!
        self.present(ShowDetailView, animated: true, completion: nil)
        
        // 傳參數進另一個畫面，使用代理 Delegate 的方式傳入
        //self.loginParamdelegate = LoginView
        // 代理的 讓另一個類幫我做事，要建立一組 protocol ， 另一個畫面用 extension 實作
        //self.loginParamdelegate?.mySetparam(param: loginParams!)
        // print("LoginButtion_OnClick")
        
    }
    
    // XMLParserDelegate  ---------------------------------------------------------------
    //開始解析XML時觸發
    func parserDidStartDocument(_ parser: XMLParser) {
        print("parser_111: 開始解析 ")
        returnvalue = ""
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        print("parser_111: 遇到標籤時 " + elementName)
        currentElementName = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //print("parser_aaa_111: " + string)
        if currentElementName == "return" {
            // print("parser_111: 遇到標籤 " + currentElementName + "加入" + string)
            returnvalue = returnvalue + string
        }
    }
    // 完成XML載入後觸發
    func parserDidEndDocument(_ parser: XMLParser) {
        //self.jsonTextView.text = self.returnvalue as String!
        // print("JSON_aa1_111: \(self.returnvalue as String!) " )
        //JSON資料處理
        let dataDic = try? JSONSerialization.jsonObject(with: self.returnvalue.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject]
        if (dataDic == nil) {
            print("JSON_aa2_111: dataDic = nil " )
            UIObject().showMessage(parent: self, msg: "查無資料。", boxTitle: "查詢")
        } else {
            print("JSON_aa3_111: \(String(describing:  dataDic?.count ))" )
            //依據先前觀察的結構，取得result對應中的results所對應的陣列
            self.dataArray = dataDic!["retval"] as! [AnyObject]  // 得到 retval 預先串好的 JSON 資料
            if self.dataArray.count > 0 {
               //print("JSON_aa6_111: \(String(describing:  self.dataArray ))" )

               DispatchQueue.main.async { // Correct
                  //重新整理Table View
                self.tableView.reloadData()
               }
            } else {
              UIObject().showMessage(parent: self, msg: "查無資料。", boxTitle: "查詢")
            }
            
        }
        DispatchQueue.main.async { // Correct
            // 打開按鈕
            self.QueryButton.isEnabled = true
        }
    }
    
    // Button Action ----------------------------------------------------------------------
    @IBAction func myBarButtonOnClick(_ sender: Any) {
        let myPressButton = sender as? UIBarButtonItem
        
        if myPressButton == StockBarButton {
            myQueryKind = "STOCK"
            QueryLabel.text = " 品 號 "
        } else if myPressButton == BillBarButton {
            myQueryKind = "BILL"
            QueryLabel.text = " 單 號 "
        } else if myPressButton == CustomBarButton {
            myQueryKind = "CUSTOM"
            QueryLabel.text = " 編 號  "
        } else if myPressButton == SupplierBarButton {
            myQueryKind = "SUPPLIER"
            QueryLabel.text = " 編 號 "
        }
        
        //StockBarButton?.tintColor = UIColor.lightGray
        //BillBarButton?.tintColor = UIColor.lightGray
        //CustomBarButton?.tintColor = UIColor.lightGray
        //SupplierBarButton?.tintColor = UIColor.lightGray
        //myPressButton?.tintColor = UIColor.blue
        myRefreshBarButtonItem()
        // 清除表格內的資料
        dataArray.removeAll()
        DispatchQueue.main.async { // Correct
            //重新整理Table View
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func myQueryButtonOnClick(_ sender: Any) {
        if QueryText.text!.isEmpty {
            UIObject().showMessage(parent: self, msg: "\(QueryLabel.text!) 不可空白。", boxTitle: "訊息")
            return
        }
        self.view.endEditing(true)
        self.QueryButton.isEnabled = false  // 按鈕關掉

        // OK 重點在BODY的參數
        let ccdate = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: ccdate)
        let month = calendar.component(.month, from: ccdate)
        let myQueryText = QueryText.text!
        // 清除表格內的資料
        dataArray.removeAll()
        DispatchQueue.main.async { // Correct
            //重新整理Table View
            self.tableView.reloadData()
        }
        
        //let Action = "GETBILL"
        var Action = ""
        var Params = ""
        switch myQueryKind {
        case "BILL":
            Action = "GETBILL"
            Params = "\(myQueryText)"

        case "CUSTOM":
            Action = "GETCUSTOM"
            Params = "\(year),\(myQueryText)"

        case "SUPPLIER":
            Action = "GETSUPPLIER"
            Params = "\(year),\(myQueryText)"

        default: //"STOCK"
            Action = "GETSTOCK"
            Params = "\(year),\(month),,\(myQueryText)"
            break
        }
        
        var soapMessage = "<?xml version='1.0' encoding='utf-8'?>        <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>"
        soapMessage = soapMessage + "<soap:Body>"
        soapMessage = soapMessage + "<myGetActionJson>"
        soapMessage = soapMessage + "<ServerIP>\(myServerIP)</ServerIP>"
        soapMessage = soapMessage + "<ComparyNO>\(myCompany)</ComparyNO>"
        soapMessage = soapMessage + "<UserName>\(myUserID)</UserName>"
        soapMessage = soapMessage + "<Password>\(myPassword)</Password>"
        soapMessage = soapMessage + "<Action>\(Action)</Action>"
        soapMessage = soapMessage + "<Params>\(Params)</Params>"
        soapMessage = soapMessage + "<ErpOrxOne>\(myErp_xone)</ErpOrxOne>"
        soapMessage = soapMessage + "</myGetActionJson>"
        soapMessage = soapMessage + "</soap:Body>"
        soapMessage = soapMessage + "</soap:Envelope>"
        let is_URL = "http://"+myServerIP+":"+myPort+"/soap/ISoapWebService"
        let lobj_Request = NSMutableURLRequest(url: URL(string: is_URL)!)
        let session = URLSession.shared
        //let err: NSError?
        lobj_Request.httpMethod = "POST"
        lobj_Request.httpBody = soapMessage.data(using: String.Encoding.utf8)
        lobj_Request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        lobj_Request.addValue(String(soapMessage.count), forHTTPHeaderField: "Content-Length")
        let task = session.dataTask(with: lobj_Request as URLRequest, completionHandler: {
            ( data, response, error ) in
            if error == nil  {
                //print("Response_111: \(String(describing: response))")
                //let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                //print("Body_111: \(String(describing:strData))")
                let xmlParser = XMLParser(data: data!)
                xmlParser.delegate = self
                xmlParser.parse()
                xmlParser.shouldResolveExternalEntities = true
            } else {
                print("Error_111: " + error.debugDescription)
            }
        })
        task.resume()
        
    }
}


