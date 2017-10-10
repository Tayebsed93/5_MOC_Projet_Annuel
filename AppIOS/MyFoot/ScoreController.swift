//
//  ScoreController.swift
//  MyFoot
//
//  Created by Tayeb Sedraia on 04/10/2017.
//  Copyright © 2017 Tayeb Sedraia. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh

class ScoreController: UIViewController {
    
    // MARK: -
    // MARK: Vars
    
    fileprivate var tableView: UITableView!
    
    // MARK: -
    var passapikey = String()
    public var addressUrlString = "http://localhost:8888/FootAPI/API/v1"
    public var playerUrlString = "/user"
    
    var names = [String]()
    var scoresresult = [Double]()
    var scores: [Score]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated)
        
        //callAPIScore()
        //loadData()
    }
    
    override func loadView() {
        super.loadView()
        
        callAPIScore()
        
        loadData()
        
        
        print("load",scores?.count)
        

        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0)
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self as! UITableViewDataSource
        tableView.delegate = self as! UITableViewDelegate
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.separatorColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 231/255.0, alpha: 1.0)
        tableView.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 251/255.0, alpha: 1.0)
        view.addSubview(tableView)
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                
                //self?.callAPIScore()
                //self?.loadData()
                
                self?.tableView.dg_stopLoading()
                self?.tableView.reloadData()
                
            })
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
    }
    
    deinit {
        //tableView.dg_removePullToRefresh()

        
    }
    
}

// MARK: -
// MARK: UITableView Data Source

extension ScoreController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if scores?.count != nil {
            return (scores?.count)!
        }
        else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        //var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            //cell!.contentView.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 251/255.0, alpha: 1.0)
            cell!.contentView.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 251/255.0, alpha: 0)
        }
        
        if let cell = cell {
            var label = UILabel(frame: CGRect(x: 280.0, y: 14.0, width: 100.0, height: 30.0))
            
            //label.text = "\((indexPath as NSIndexPath).row)"
            let a = Int((scores?[indexPath.row].score)!)
            let b: String = String(a)
            label.text = b + " Point"
            label.tag = indexPath.row
            cell.contentView.addSubview(label)
            
            //cell.textLabel?.text = "Tayeb Sedraia"
            cell.textLabel?.text = scores?[indexPath.row].name
            cell.imageView?.image = UIImage(named: "profile")
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func callAPIScore() {
        
        
        let apiKey = passapikey
        //let config = URLSessionConfiguration.default
        let urlToRequest = addressUrlString+playerUrlString
        let url4 = URL(string: urlToRequest)!
        let session4 = URLSession.shared
        let request = NSMutableURLRequest(url: url4)
        //config.httpAdditionalHeaders = ["Authorization" : apiKey]
        request.addValue("226f791098549052f704eb37b2ae7999", forHTTPHeaderField: "Authorization")
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
                        
                        if let users = json["users"] as? [[String: Any]] {
                            for user in users {
                                if let name = user["name"]{
                                    
                                    self.names.append(name as! String)
                                    
                                }
                                if let age = user["score"]{
                                    self.scoresresult.append(age as! Double)
                                }
                            }
                        }
                        
                        if let messageError = json["message"]
                        {
                            self.alerteMessage(message: messageError as! String)
                        }
                        

                        self.setupData(_name: self.names, _score: self.scoresresult)
                        
                        //self.isPlayer = false
                }
                
                
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
        }
        ;task.resume()
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

// MARK: -
// MARK: UITableView Delegate

extension ScoreController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
