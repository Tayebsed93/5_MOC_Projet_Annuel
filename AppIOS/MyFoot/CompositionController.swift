//
//  CompositionController.swift
//  MyFoot
//
//  Created by Tayeb Sedraia on 19/09/2017.
//  Copyright © 2017 Tayeb Sedraia. All rights reserved.
//

import Foundation

import UIKit
import Alamofire


class CompositionController: UIViewController, UITextFieldDelegate {
    
    struct defaultsKeys {
        static let key0 = "0"
        static let key1 = "1"
        static let key2 = "2"
        static let key3 = "3"
        static let key4 = "4"
        static let key5 = "5"
        static let key6 = "6"
        static let key7 = "7"
        static let key8 = "8"
        static let key9 = "9"
        static let key10 = "10"
        static let key11 = "11"
        
    }
    
    
    var nationality = String()
    var stringComposition = String()
    
    var passapikey = String()
    var dates = [Int]()
    var names = [String]()
    var ages = [Double]()
    
    var newapikey = String()
    var nation = [String]()
    
    var players: [Player]?
    var composition = [String]()
    
    var isPlayer = Bool()
    var isCorrect = false
    
    var curentName = String()
    var curentTag = Int()
    
    let defaults = UserDefaults.standard
    
    @IBOutlet var BtnGroup: [UIButton]!
    
    
    public var addressUrlString = "http://localhost:8888/FootAPI/API/v1"
    public var playerUrlString = "/player"
    public var playerUrlCompo = "/composition"
    public var playerUrlCompoResult = "/composition/result"
    public var scoreUrl = "/user"
    
    
    
    //let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if isPlayer == true {
            //Supprime tout
            defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            defaults.set(self.passapikey, forKey: defaultsKeys.key11)
            callAPIPlayer()
        }
        else {
            
            switch (self.curentTag)
            {
            case 0:
                defaults.set(self.curentName, forKey: defaultsKeys.key0)
                
            case 1:
                defaults.set(self.curentName, forKey: defaultsKeys.key1)

            case 2:
                defaults.set(self.curentName, forKey: defaultsKeys.key2)
                
            case 3:
                defaults.set(self.curentName, forKey: defaultsKeys.key3)
                
            case 4:
                defaults.set(self.curentName, forKey: defaultsKeys.key4)
                
            case 5:
                defaults.set(self.curentName, forKey: defaultsKeys.key5)
            
            case 6:
                defaults.set(self.curentName, forKey: defaultsKeys.key6)
                
            case 7:
                defaults.set(self.curentName, forKey: defaultsKeys.key7)
                
            case 8:
                defaults.set(self.curentName, forKey: defaultsKeys.key8)
                
            case 9:
                defaults.set(self.curentName, forKey: defaultsKeys.key9)
                
            case 10:
                defaults.set(self.curentName, forKey: defaultsKeys.key10)
                
                
            default:
                print("Integer out of range")
            }
        }

        
        // Getting

        if let string0 = defaults.string(forKey: defaultsKeys.key0) {
            BtnGroup[0].setTitle(string0, for: .normal)
            composition.append(string0)
            
        }
        if let string1 = defaults.string(forKey: defaultsKeys.key1) {
            BtnGroup[1].setTitle(string1, for: .normal)
            composition.append(string1)
        }
        
        if let string2 = defaults.string(forKey: defaultsKeys.key2) {
            BtnGroup[2].setTitle(string2, for: .normal)
            composition.append(string2)
        }
        
        if let string3 = defaults.string(forKey: defaultsKeys.key3) {
            BtnGroup[3].setTitle(string3, for: .normal)
            composition.append(string3)
        }
        if let string3 = defaults.string(forKey: defaultsKeys.key4) {
            BtnGroup[4].setTitle(string3, for: .normal)
            composition.append(string3)
        }
        if let string3 = defaults.string(forKey: defaultsKeys.key5) {
            BtnGroup[5].setTitle(string3, for: .normal)
            composition.append(string3)
        }
        if let string3 = defaults.string(forKey: defaultsKeys.key6) {
            BtnGroup[6].setTitle(string3, for: .normal)
            composition.append(string3)
        }
        if let string3 = defaults.string(forKey: defaultsKeys.key7) {
            BtnGroup[8].setTitle(string3, for: .normal)
            composition.append(string3)
        }
        if let string3 = defaults.string(forKey: defaultsKeys.key8) {

            BtnGroup[7].setTitle(string3, for: .normal)
            composition.append(string3)
        }
        if let string3 = defaults.string(forKey: defaultsKeys.key9) {

            BtnGroup[9].setTitle(string3, for: .normal)
            composition.append(string3)
        }
        if let string3 = defaults.string(forKey: defaultsKeys.key10) {

            BtnGroup[10].setTitle(string3, for: .normal)
            composition.append(string3)
        }

        self.stringComposition = composition.joined(separator: ", ")
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
            
    }
    
    
    func callAPIPlayer() {

        //let config = URLSessionConfiguration.default
        let urlToRequest = addressUrlString+playerUrlString
        let url4 = URL(string: urlToRequest)!
        let session4 = URLSession.shared
        let request = NSMutableURLRequest(url: url4)
        //config.httpAdditionalHeaders = ["Authorization" : apiKey]
        request.addValue(defaults.string(forKey: defaultsKeys.key11)!, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let paramString = String(format:"nationality=%@",self.nationality)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        
        let task = session4.dataTask(with: request as URLRequest)
        { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response, error == nil else
            {
                
                print("ERROR: \(error?.localizedDescription)")
                
                self.alerteMessage(message: (error?.localizedDescription)!)
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            //JSONSerialization in Object
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                DispatchQueue.main.async()
                    {
                        //print(json)
                        if let players = json["player"] as? [[String: Any]] {
                            
                            for player in players {
                                if let name = player["Name"]{
                                  
                                    self.names.append(name as! String)
                                
                                }
                                if let age = player["Age"]{
                                    self.ages.append(age as! Double)
                                }
                            }
                        }
                        
                        if let messageError = json["message"]
                        {
                            self.alerteMessage(message: messageError as! String)
                        }
                        
                        
                        self.setupData(_name: self.names, _age: self.ages)
                        
                        self.isPlayer = false
                }
                
                
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
        }
        ;task.resume()
    }
    
    func callAPICompo() {
        let defaults = UserDefaults.standard
        let urlToRequest = addressUrlString+playerUrlCompo
        let url4 = URL(string: urlToRequest)!
        let session4 = URLSession.shared
        let request = NSMutableURLRequest(url: url4)
        
        request.addValue(defaults.string(forKey: defaultsKeys.key11)!, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let paramString = String(format:"nation=%@&player=%@",self.nationality, stringComposition)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        
        let task = session4.dataTask(with: request as URLRequest)
        { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response, error == nil else
            {
                
                print("ERROR: \(error?.localizedDescription)")
                
                self.alerteMessage(message: (error?.localizedDescription)!)
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            //JSONSerialization in Object
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                DispatchQueue.main.async()
                    {
                        //print(json)
                        if let players = json["player"] as? [[String: Any]] {
                            
                            for player in players {
                                if let name = player["Name"]{
                                    
                                    self.names.append(name as! String)
                                    
                                }
                                if let age = player["Age"]{
                                    self.ages.append(age as! Double)
                                }
                            }
                        }
                        
                        if let messageError = json["message"]
                        {
                            self.alerteMessage(message: messageError as! String)
                            self.callAPIResultCompo()
                        }
                        

                }
                
                
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
        }
        ;task.resume()
    }
    
    
    ///
    //******* Resultat de la compo
    ////
    func callAPIResultCompo() {
        let defaults = UserDefaults.standard
        let urlToRequest = addressUrlString+playerUrlCompoResult
        let url4 = URL(string: urlToRequest)!
        let session4 = URLSession.shared
        let request = NSMutableURLRequest(url: url4)
        
        request.addValue(defaults.string(forKey: defaultsKeys.key11)!, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        
        let task = session4.dataTask(with: request as URLRequest)
        { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response, error == nil else
            {
                
                print("ERROR: \(error?.localizedDescription)")
                
                self.alerteMessage(message: (error?.localizedDescription)!)
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            //JSONSerialization in Object
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                DispatchQueue.main.async()
                    {
                        if let compositions = json["composition"] as? [[String: Any]] {
                            
                            for composition in compositions {
                                if let _nation = composition["nation"]{
                                    
                                    self.nation.append(_nation as! String)
                                    
                                }
                                if let _api_key = composition["api_key"]{
                                    //self.newapikey.append(_api_key as! String)
                                    self.newapikey = _api_key as! String
                                }
                            }
                        }
                        
                        if let messageError = json["message"]
                        {
                            self.alerteMessage(message: messageError as! String)
                        }
                        
                        for na in self.nation {
                            if na == self.nationality {
                                print(na)
                                self.callAPIScore(newkey: self.newapikey)
                                self.isCorrect = true
                                
                            }
                            else {
                                self.isCorrect = false
                            }
                        }
                        
                        print(self.isCorrect)
                        if self.isCorrect == true {
                            //self.callAPIScore(newkey: self.newapikey)
                        }
                }
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        ;task.resume()
    }
    
    
    ///
    //******* Ajout du score
    ////
    func callAPIScore(newkey:String) {
        print("La nouvelle", newkey)
        let defaults = UserDefaults.standard
        let urlToRequest = addressUrlString+scoreUrl
        let url4 = URL(string: urlToRequest)!
        let session4 = URLSession.shared
        let request = NSMutableURLRequest(url: url4)
        
        request.addValue(newkey, forHTTPHeaderField: "Authorization")
        request.httpMethod = "PUT"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        
        let task = session4.dataTask(with: request as URLRequest)
        { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response, error == nil else
            {
                
                print("ERROR: \(error?.localizedDescription)")
                
                self.alerteMessage(message: (error?.localizedDescription)!)
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            //JSONSerialization in Object
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                DispatchQueue.main.async()
                    {
                        if let messageError = json["message"]
                        {
                            
                        }
                }
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
        }
        ;task.resume()
    }
    
    
    
    @IBAction func BtnvaliderCompo(_ sender: Any) {
        // create the alert
        let alert = UIAlertController(title: "Confirmation", message: "Voulez-vous valider la composition ?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Oui", style: UIAlertActionStyle.default, handler: { action in
            self.callAPICompo()
            
        }))
        alert.addAction(UIAlertAction(title: "Non", style: UIAlertActionStyle.cancel, handler: { action in

        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func BtnActionGroup(_ sender: UIButton) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerController") as? PlayerController {
            viewController.nationality = self.nationality
            if (((sender as AnyObject).tag == 0))
            {
                self.curentTag = 0
                viewController.curentTag = self.curentTag
                viewController.nationality = self.nationality
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
            else if (((sender as AnyObject).tag == 1))
            {
                self.curentTag = 1
                viewController.curentTag = self.curentTag
                viewController.nationality = self.nationality
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
                
            }
            else if (((sender as AnyObject).tag == 2))
            {
                self.curentTag = 2
                viewController.curentTag = self.curentTag
                viewController.nationality = self.nationality
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
                
            }
            else if (((sender as AnyObject).tag == 3))
            {
                self.curentTag = 3
                viewController.curentTag = self.curentTag
                viewController.nationality = self.nationality
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
                
            }
            else if (((sender as AnyObject).tag == 4))
            {
                self.curentTag = 4
                viewController.curentTag = self.curentTag
                viewController.nationality = self.nationality
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
                
            }
            else if (((sender as AnyObject).tag == 5))
            {
                self.curentTag = 5
                viewController.curentTag = self.curentTag
                viewController.nationality = self.nationality
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
                
            }
            else if (((sender as AnyObject).tag == 6))
            {
                self.curentTag = 6
                viewController.curentTag = self.curentTag
                viewController.nationality = self.nationality
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
                
            }
            else if (((sender as AnyObject).tag == 7))
            {
                self.curentTag = 7
                viewController.curentTag = self.curentTag
                viewController.nationality = self.nationality
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
                
            }
            else if (((sender as AnyObject).tag == 8))
            {
                self.curentTag = 8
                viewController.curentTag = self.curentTag
                viewController.nationality = self.nationality
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
                
            }
            else if (((sender as AnyObject).tag == 9))
            {
                self.curentTag = 9
                viewController.curentTag = self.curentTag
                viewController.nationality = self.nationality
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
                
            }
            else if (((sender as AnyObject).tag == 10))
            {
                self.curentTag = 10
                viewController.curentTag = self.curentTag
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
                
            }
        }

    }
    
    @IBAction func deconnecteButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alerteMessage(message : String) {
        
        var newMessage = ""
        if (message == "Could not connect to the server." ) {
            newMessage = "Impossible de se connecter au serveur."
            
            let alert = UIAlertController(title: "Erreur", message: newMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
}






