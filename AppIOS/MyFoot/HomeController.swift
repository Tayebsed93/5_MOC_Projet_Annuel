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
    

    var nationality = String()
    
    var passapikey = String()

    var isPlayer = Bool()
    
    
    public var addressUrlString = "http://poubelle-connecte.pe.hu/PoubelleAPI/API/v1"
    public var dateUrlString = "/poubelles/date"
    
    @IBOutlet weak var anneeText: UITextField!
    let button = UIButton(type: UIButtonType.custom)
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isPlayer = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated)
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





