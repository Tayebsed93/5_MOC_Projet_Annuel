//
//  LoginController.swift
//  MyFoot
//
//  Created by Tayeb Sedraia on 13/09/2017.
//  Copyright © 2017 Tayeb Sedraia. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class LoginController: UIViewController {
    
    

    @IBOutlet weak var txtEMail: UITextField!

    @IBOutlet weak var txtMdp: UITextField!
    
    public var mutableURLRequest: NSMutableURLRequest!
    public var url: NSURL?
    public var addressUrlString = "http://localhost:8888/FootAPI/API/v1"
    var test = ""
    public var loginUrlString = "/login"
    var api:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        txtEMail.text = "az@gmail.com"
        txtMdp.text = "az"
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        callAPILogin()
    }
    
    
    func callAPILogin() {
        let urlToRequest = addressUrlString+loginUrlString
        let url4 = URL(string: urlToRequest)!
        let session4 = URLSession.shared
        let request = NSMutableURLRequest(url: url4)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let paramString = String(format:"email=%@&password=%@",txtEMail.text!,txtMdp.text!)
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
            //print("Response : \n \(dataString)") //JSONSerialization in String
            
            
            //JSONSerialization in Object
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                DispatchQueue.main.async()
                    {
                        if let apiKey = json["apiKey"]
                        {
                            
                            self.passData(apiKey: apiKey as! String)
                        }
                        
                        if let messageError = json["message"]
                        {
                            self.alerteMessage(message: messageError as! String)
                        }
                        
                }
                /*
                 DispatchQueue.main.async() {
                 self.dismiss(animated: true, completion: nil)
                 }
                 */
                
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
        }
        ;task.resume()
    }
    
    func passData(apiKey : String) {
        print(apiKey)
        
        
        
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tabVc = storyboard.instantiateViewController(withIdentifier: "tbController") as! UITabBarController
        
        
        /////////****** 1er controller
        //Convertie la tabViewController en UINavigationController
        let navigation = tabVc.viewControllers?[0] as! UINavigationController
        
        //Convertie la UINavigationController en UIViewController (Home)
        let homeController = navigation.topViewController as? HomeController
        
        //Envoie le nom et le mot de passe à la page statistique
        homeController?.passapikey = apiKey
        
        
        /////////****** 2nd controller
        //Chart
        /*
         let chartsViewController = tabVc.viewControllers![1] as! ChartsViewController
         //Envoie l'apikey à la page ChartsViewController
         chartsViewController.passapikey = apiKey
         
         //Change la page vers Statistique
         self.present(tabVc, animated: true, completion: nil)
         */
        /*
        //Remplissage
        let remplissageController = tabVc.viewControllers![1] as! RemplissageController
        
        //Envoie l'apikey à la page ChartsViewController
        remplissageController.passapikey = apiKey
        
 */
        //Change la page vers Statistique
        self.present(tabVc, animated: true, completion: nil)
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




