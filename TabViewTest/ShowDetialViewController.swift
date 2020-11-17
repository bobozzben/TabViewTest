//
//  ShowDetialViewController.swift
//  TabViewTest
//
//  Created by Ben_Mac on 2017/12/27.
//  Copyright © 2017年 Ben_Mac. All rights reserved.
//

import UIKit

class ShowDetialViewController: UIViewController , UITableViewDelegate ,UITableViewDataSource ,UITextFieldDelegate {
   // struct Objects {
   //     var sectionName : String!
   //     var sectionObjects : String!
   // }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var GoBackButton: UIBarButtonItem!

    var myJsonData = [String:Any]()
   // var objectArray = [Objects]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        //設定成高度會依長度自動折行
        //1. 設定 estimatedRowHeight 屬性的預設值
        tableView.estimatedRowHeight = 44.0;
        //2. rowHeight属性設成 UITableViewAutomaticDimension
        tableView.rowHeight = UITableView.automaticDimension;
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 遍尋此列 JSON
        // https://stackoverflow.com/questions/31136084/how-can-i-group-tableview-items-from-a-dictionary-in-swift
        //if objectArray.count == 0 {
        //   for (key, value) in myJsonData {
        //       print("key:\(key) ,Value:\(value) " )
        //    objectArray.append(Objects(sectionName: key, sectionObjects: value as! String ))
        //   }
        print( "ArrayCount: \( Array(self.myJsonData.keys).count ) " )
            DispatchQueue.main.async { // Correct
                //重新整理Table View
                self.tableView.reloadData()
            }
        //}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITableViewDelegate  ---------------------------------------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(self.myJsonData.keys).count  //objectArray[section].sectionObjects.count
    }
    
    // 順序由傳回的SQL決定，KEY是欄位名稱，VALUE是資料
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        //3. cell.textLabel?.numberOfLines = 0 設成 0,即會自動折行
        cell.textLabel?.numberOfLines = 0

        let key   = Array(self.myJsonData.keys)[indexPath.row]
        let value = Array(self.myJsonData.values)[indexPath.row]
        // 使用一般文字顯示
        // cell.textLabel?.text = "\(key) : \(value)"
        // 使用可變的屬性文字顯示
        cell.textLabel?.attributedText = getAttributedString(title: key,subtitle: value as! String )

        return cell;
    }
    
    // 取得該條属性文字
    func getAttributedString(title: String, subtitle: String) -> NSAttributedString {
        //標題字體樣式
        let titleFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        let titleColor = UIColor(red: 45/255, green: 153/255, blue: 0/255, alpha: 1)
        let titleAttributes = [NSAttributedString.Key.font: titleFont, NSAttributedString.Key.foregroundColor: titleColor]
        //內容字體樣式
        let subtitleFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        let subtitleAttributes = [NSAttributedString.Key.font: subtitleFont]
        //合併後將內容傳回去
        let titleString = NSMutableAttributedString(string: "\(title)\n",attributes: titleAttributes)
        let subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
        titleString.append(subtitleString)
        return titleString
    }
    
    // IBAction  ---------------------------------------------------------------

    @IBAction func goBackButtonOnClick(_ sender: UIButton) {
        // 返回前頁
        print("回頭")
        myJsonData.removeAll()
        
        self.dismiss(animated: true , completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
