//
//  InscriptionController.swift
//  MyFoot
//
//  Created by Tayeb Sedraia on 07/10/2017.
//  Copyright © 2017 Tayeb Sedraia. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class InscriptionController: UIViewController {
    
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var prenomTxt: UITextField!
    @IBOutlet weak var mdp1Txt: UITextField!
    @IBOutlet weak var mdp2Txt: UITextField!
    

    
    public var mutableURLRequest: NSMutableURLRequest!
    public var url: NSURL?
    public var addressUrlString = "http://localhost:8888/FootAPI/API/v1"
    
    var test = ""
    public var loginUrlString = "/register"
    var api:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSinscrire(_ sender: Any) {
        callAPIRegister()
    }
    
    func callAPIRegister() {
        let urlToRequest = addressUrlString+loginUrlString
        let url4 = URL(string: urlToRequest)!
        let session4 = URLSession.shared
        let request = NSMutableURLRequest(url: url4)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let paramString = String(format:"name=%@&email=%@&password=%@",nameTxt.text!,prenomTxt.text!,mdp1Txt.text!)
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
                        print(json)
                        if let apiKey = json["apiKey"]
                        {
                            
                            //self.passData(apiKey: apiKey as! String)
                        }
                        
                        if let messageError = json["message"]
                        {
                            self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func btnAnnuler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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





