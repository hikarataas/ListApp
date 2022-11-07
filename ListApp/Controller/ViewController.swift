//
//  ViewController.swift
//  ListApp
//
//  Created by Hilal Karataş on 5.11.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var alertController = UIAlertController()
    
    @IBOutlet weak var tableView : UITableView!
    
    var data = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        fetch()
    }
    
    @IBAction func didRemoveBarButtonItemTapped (_ sender : UIBarButtonItem){
        presentAlert(title: "Uyari!",
                     message: "Listadeki butun elemanlar silinsin mi?",
                     cancelButtonTitle: "Vazgec",
                     defaultButtonTitle: "Evet") { _ in
            //self.data.removeAll()
            //self.tableView.reloadData()
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            for item in self.data {
                            managedObjectContext?.delete(item)
                        }
                        
                        try? managedObjectContext?.save()
                        
                        self.fetch()
        }
        
    }
    @IBAction func didAddBarButtonItemTapped (_ sender : UIBarButtonItem){
        presentAddAlert()
    }
    
    func presentAlert(title: String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style = .alert,
                      cancelButtonTitle: String?,
                      defaultButtonTitle: String? = nil,
                      defaultButtonHandler: ((UIAlertAction) -> Void)? = nil,
                      isTextFieldAvaible: Bool = false){
        
        alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: preferredStyle)
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                              style: .default,
                                              handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel)
        
        
        if isTextFieldAvaible{
            alertController.addTextField()
        }
       
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true)
    
}
    
    func presentAddAlert(){
        presentAlert(title: "Yeni Eleman ekle!",
                     message: nil,
                     cancelButtonTitle: "Vazgec",
                     defaultButtonTitle: "Ekle",
                     defaultButtonHandler:{_ in
            let text = self.alertController.textFields?.first?.text
            if text != "" {
                
                //self.data.append((text)!) --> coredata dan cekilecek ve kod duzeni array coredata da
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem",
                                                        in: managedObjectContext!)
                
                let ListItem = NSManagedObject(entity: entity!,
                                               insertInto: managedObjectContext)
                
                ListItem.setValue(text, forKey: "title")
                
                try? managedObjectContext?.save()
                
                self.fetch()
            } else {
                presentWarningAlert()
            }
        }, isTextFieldAvaible: true)
        
        
        
        func presentWarningAlert(){
            presentAlert(title: "Uyari!",
                         message: "Liste elemani bos olamaz.",
                         cancelButtonTitle: "Tamam")
        }
        
        
    }
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        tableView.reloadData()
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal,
                                              title: "Sil") { _, _, _ in
            //self.data.remove(at: indexPath.row)
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            managedObjectContext?.delete(self.data[indexPath.row])
            try? managedObjectContext?.save()
            
            self.fetch()
            
            tableView.reloadData()
        }
        
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal,
                                            title: "Duzenle") { [self] _, _, _ in
            self.presentAlert(title: "Elemani duzenle",
                              message: nil,
                              cancelButtonTitle: "Vazgec",
                              defaultButtonTitle: "Duzenle",
                              defaultButtonHandler:{_ in
                let text = self.alertController.textFields?.first?.text
                if text != "" {
                    //self.data[indexPath.row] = text!
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if managedObjectContext!.hasChanges{
                        try? managedObjectContext?.save()
                    }
                    
                    self.tableView.reloadData()
                } else {
                    self.presentAddAlert()
                }
            }, isTextFieldAvaible: true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return config
    }
}

