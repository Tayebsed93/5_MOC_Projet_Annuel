//
//  PlayerController.swift
//  MyFoot
//
//  Created by Tayeb Sedraia on 23/09/2017.
//  Copyright © 2017 Tayeb Sedraia. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerController: UITableViewController, UISearchBarDelegate {
    
    var players: [Player]?
    var player: Player?

    var nb: Int = 0
    var nationality = String()
    var name = String()
    
    var curentName = String()
    var curentTag = Int()
    
    @IBOutlet weak var searchBar: UISearchBar!
    public var addressUrlString = "http://localhost:8888/FootAPI/Pictures"
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        //Recuperer Donnée de la BDD
        loadData()
        searchBar.text = ""

        
        self.title = nationality
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keywords = searchBar.text
        self.loadSearchData(_cleRecherche: keywords!)
        

        self.view.endEditing(true)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        return (players?.count)!
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
    
         var mainImageView = cell?.viewWithTag(1) as! UIImageView
            if let profileImageName = UIImage(named: (players?[indexPath.row].name)!) {
                mainImageView.image = UIImage(named: (players?[indexPath.row].name)!)
            }
            else{
                mainImageView.image = UIImage(named: "profile")
            }
        
        // Nom du joueur
        let name:String
        let labelName = cell?.viewWithTag(2) as! UILabel
        labelName.text = players?[indexPath.row].name
        
        // Age
        let labelAge = cell?.viewWithTag(3) as! UILabel
        let a = Int((players?[indexPath.row].age)!)
        let b: String = String(a)
        labelAge.text = b + " Ans"
        
        var paysImage = cell?.viewWithTag(4) as! UIImageView
        paysImage.image = UIImage(named: nationality)
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //getting the index path of selected row
        let indexPath = tableView.indexPathForSelectedRow
        
        //getting the current cell from the index path
        let currentCell = tableView.cellForRow(at: indexPath!)! as UITableViewCell
        
        //getting the text of that cell
        let currentItem = currentCell.viewWithTag(2) as! UILabel
        
        self.curentName = currentItem.text!
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Supprimer") { (action, indexPath) in
            print("Suprime", indexPath)
            self.tableView.reloadData()
            
        }
        
        //self.tableView.reloadData()
        return [delete]
    }
    
    
    
    @IBAction func DeconnexionClick(_ sender: Any) {
        
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CompositionController") as? CompositionController {
            viewController.nationality = self.nationality
            viewController.isPlayer = false
            viewController.curentName = self.curentName
            viewController.curentTag = self.curentTag
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: false)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
