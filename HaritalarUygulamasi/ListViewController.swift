//
//  ListViewController.swift
//  HaritalarUygulamasi
//
//  Created by Muzaffer Baran on 22.01.2023.
//

import UIKit

//bu vc de yaptıklarımız kayıt ettigimiz core data bilgilerinin ilk ekrana gelmesini saglayacak

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(artiButtonuTiklandi))
        
    }
    
    @objc func artiButtonuTiklandi() {
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "test"
        return cell
    }
    

   

}
