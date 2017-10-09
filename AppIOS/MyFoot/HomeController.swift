//
//  HomeController.swift
//  MyFoot
//
//  Created by Tayeb Sedraia on 13/09/2017.
//  Copyright © 2017 Tayeb Sedraia. All rights reserved.
//

import Foundation

import UIKit
import Alamofire


class HomeController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var France: UIImageView!
    @IBOutlet weak var Germany: UIImageView!
    @IBOutlet weak var Italy: UIImageView!
    
    @IBOutlet weak var btnFrance: UIButton!
    @IBOutlet weak var btnGermany: UIButton!
    @IBOutlet weak var btnItaly: UIButton!
    
    public var addressUrlString = "http://localhost:8888/FootAPI/API/v1"
    public var compositionUrlString = "/composition"
    
    var nationality = String()
    
    var passapikey = String()

    var isPlayer = Bool()
    
    var nation = [String]()
    
    struct defaultsKeys {
        static let key11 = "11"
        
    }
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var anneeText: UITextField!
    let button = UIButton(type: UIButtonType.custom)
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults.set(self.passapikey, forKey: defaultsKeys.key11)
        
        self.isPlayer = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated)
        callAPIComposition()
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func FranceClick(_ sender: Any) {
        self.nationality = "France"
        
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CompositionController") as? CompositionController {
            viewController.nationality = self.nationality
            viewController.passapikey = self.passapikey
            viewController.isPlayer = true
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
        
    }
    
    @IBAction func AllemagneClick(_ sender: Any) {
        self.nationality = "Germany"
        
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CompositionController") as? CompositionController {
            viewController.nationality = self.nationality
            viewController.passapikey = self.passapikey
            viewController.isPlayer = true
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func ItalieClick(_ sender: Any) {
        self.nationality = "Italy"
        
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CompositionController") as? CompositionController {
            viewController.nationality = self.nationality
            viewController.passapikey = self.passapikey
            viewController.isPlayer = true
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }

    
    
    @IBAction func deconnecteButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func callAPIComposition() {
        
        //let config = URLSessionConfiguration.default
        let urlToRequest = addressUrlString+compositionUrlString
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
                        //print(json)
                        if let compositions = json["composition"] as? [[String: Any]] {
                            
                            for composition in compositions {
                                if let nation = composition["nation"]{
                                    self.nation.append(nation as! String)
                                    
                                }
                            }
                        }
                        
                        if let messageError = json["message"]
                        {
                            self.alerteMessage(message: messageError as! String)
                        }
                        
                        for ok in self.nation {
                            if (ok == "France") {
                                self.France.alpha = 1
                                self.btnFrance.isEnabled = false
                            }
                            else if (ok == "Germany") {
                                self.Germany.alpha = 1
                                self.btnGermany.isEnabled = false
                            }
                            else if (ok == "Italy") {
                                self.Italy.alpha = 1
                                self.btnItaly.isEnabled = false
                            }
                            
                        }
                        //self.setupData(_name: self.names, _age: self.ages)
                        
                        //self.isPlayer = false
                }
                
                
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
        }
        ;task.resume()
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





