//
//  SoapConnect.swift
//  TabViewTest
//
//  Created by Ben_Mac on 2017/12/11.
//  Copyright © 2017年 Ben_Mac. All rights reserved.
//

import Foundation

class myTopSoapConnect : NSObject{
    var ServerIP : String = ""
    var ServerPort :String = ""
    var ComparyNO : String = ""
    var UserName : String = ""
    var Password : String = ""
    var Action : String = ""
    var Params : String = ""
    var ErpOrxOne : Int32 = 0
    
    var currentElementName = ""
    var returnvalue = ""
    
}

class mySoapConnect :  myTopSoapConnect , XMLParserDelegate  {
    let connectionTimeOut_Seconds = 40

    //開始解析XML時觸發
    func parserDidStartDocument(_ parser: XMLParser) {
        //print("parser_111: 開始解析 ")
    }
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        //print("parser_111: 遇到錯誤時 " + parseError.localizedDescription)
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        //print("parser_111: 遇到標籤時 " + elementName)
        self.currentElementName = elementName
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
      // print("parser_aaa_111: " + string)
      if currentElementName == "return" {
           self.returnvalue = self.returnvalue + string
      }
    }
    // 完成XML載入後觸發
    func parserDidEndDocument(_ parser: XMLParser) {
        
        //self.jsonTextView.text = self.returnvalue as String!
        print("JSON_aa1_111: \(self.returnvalue as String?) " )
        //JSON資料處理
        /*
        let dataDic = try? JSONSerialization.jsonObject(with: self.returnvalue.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
        if (dataDic == nil) {
            print("JSON_aa2_111: dataDic = nil " )
        } else {
            print("JSON_aa3_111: \(String(describing:  dataDic?.count ))" )
            
            //依據先前觀察的結構，取得result對應中的results所對應的陣列
            self.dataArray = dataDic!["retval"] as! [AnyObject]  // 得到 retval 預先串好的 JSON 資料
            
            do {
                let jsonDecoder = JSONDecoder()
                let myrecs = try jsonDecoder.decode(myRec.self, from: self.returnvalue.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! )   // JSON 解析不成功，上面顯示出的JSON 都沒逗號
                print("JSON_aa5_111: \(String(describing: myrecs.retcode ))" )
                print("JSON_aa6_111: \(String(describing: myrecs.retval ))" )
            } catch {
                print("JSON_aa5_111 _Error")
            }
            
            DispatchQueue.main.async { // Correct
                //重新整理Table View
                //self.tableView.reloadData()
                
            }
        }
 */
    }
    
    func myRunLogin() {
        var soapMessage = "<?xml version='1.0' encoding='utf-8'?>        <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>"
        soapMessage = soapMessage + "<soap:Body>"
        soapMessage = soapMessage + "<echoLogin>"
        soapMessage = soapMessage + "<ServerIP>\(ServerIP)</ServerIP>"
        soapMessage = soapMessage + "<ComparyNO>\(ComparyNO)</ComparyNO>"
        soapMessage = soapMessage + "<UserName>\(UserName)</UserName>"
        soapMessage = soapMessage + "<Password>\(Password)</Password>"
        soapMessage = soapMessage + "<ErpOrxOne>\(ErpOrxOne)</ErpOrxOne>"
        soapMessage = soapMessage + "</echoLogin>"
        soapMessage = soapMessage + "</soap:Body>"
        soapMessage = soapMessage + "</soap:Envelope>"
        let is_URL = "http://"+ServerIP+":"+ServerPort+"/soap/ISoapWebService"
        let lobj_Request = NSMutableURLRequest(url: URL(string: is_URL)!)
        let session = URLSession.shared
        lobj_Request.timeoutInterval = TimeInterval(connectionTimeOut_Seconds)
        lobj_Request.httpMethod = "POST"
        lobj_Request.httpBody = soapMessage.data(using: String.Encoding.utf8)
        lobj_Request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        lobj_Request.addValue(String(soapMessage.count), forHTTPHeaderField: "Content-Length")
        let task = session.dataTask(with: lobj_Request as URLRequest, completionHandler: {
            ( data, response, error ) in
            if error == nil  {
                 let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                 print("task_111: \(String(describing:strData))")
                let xmlParser = XMLParser(data: data!)
                xmlParser.delegate = self
                xmlParser.parse()
                xmlParser.shouldResolveExternalEntities = true
            } else {
                self.returnvalue = "連線錯誤"
                print("Error_111: \( error.debugDescription ) response: \( response.debugDescription ) " )
            }
        })
        task.resume()
        
    }
    
    func myRunSoap() {
        var soapMessage = "<?xml version='1.0' encoding='utf-8'?>  <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>"
        soapMessage = soapMessage + "<soap:Body>"
        soapMessage = soapMessage + "<myGetActionJson>" // xmlns='http://\(iptxt!):\(porttxt!)/'>"
        soapMessage = soapMessage + "<ServerIP>\(ServerIP)</ServerIP>"
        soapMessage = soapMessage + "<ComparyNO>\(ComparyNO)</ComparyNO>"
        soapMessage = soapMessage + "<UserName>\(UserName)</UserName>"
        soapMessage = soapMessage + "<Password>\(Password)</Password>"
        soapMessage = soapMessage + "<Action>\(Action)</Action>"
        soapMessage = soapMessage + "<Params>\(Params)</Params>"
        soapMessage = soapMessage + "<ErpOrxOne>\(ErpOrxOne)</ErpOrxOne>"
        soapMessage = soapMessage + "</myGetActionJson>"
        soapMessage = soapMessage + "</soap:Body>"
        soapMessage = soapMessage + "</soap:Envelope>"
        let is_URL = "http://"+ServerIP+":"+ServerPort+"/soap/ISoapWebService"
        let lobj_Request = NSMutableURLRequest(url: URL(string: is_URL)!)
        let session = URLSession.shared
        lobj_Request.timeoutInterval = TimeInterval(connectionTimeOut_Seconds)
        lobj_Request.httpMethod = "POST"
        lobj_Request.httpBody = soapMessage.data(using: String.Encoding.utf8)
        lobj_Request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        lobj_Request.addValue(String(soapMessage.count), forHTTPHeaderField: "Content-Length")
        
        let task = session.dataTask(with: lobj_Request as URLRequest, completionHandler: {
            ( data, response, error ) in
            if error == nil  {
                print("task \(String(describing: data!))")
                let xmlParser = XMLParser(data: data!)
                xmlParser.delegate = self
                xmlParser.parse()
                xmlParser.shouldResolveExternalEntities = true
            } else {
                self.returnvalue = "連線錯誤"
                print("Error_111: \( error.debugDescription ) response: \( response.debugDescription ) " )
            }
        })
        task.resume()
        
    }
    
    
}

