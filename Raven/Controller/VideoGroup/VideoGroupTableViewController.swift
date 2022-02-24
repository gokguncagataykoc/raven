//
//  VideoGroupTableViewController.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 12.02.2022.
//

import UIKit
import CoreData

class VideoGroupTableViewController: UITableViewController {

    let userDefaults:UserDefaults = UserDefaults.standard
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<VideoGroup>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<VideoGroup> = VideoGroup.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "videoGroup")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        // Fix the tableview bottom part bar issue
        tableView.contentInset.bottom = self.tabBarController?.tabBar.frame.height ?? 0
        
        //login control
        loginService()
        
        // fetch data
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // fetch data
        setupFetchedResultsController()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let videoGroupObject = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoGroupCell", for: indexPath) as! VideoGroupTableViewCell

        // Configure the cell...
        cell.nameLabel.text = videoGroupObject.name
        
        // Create Date Formatter
        let dateFormatter = DateFormatter()
        // Set Date Format
        dateFormatter.dateFormat = "dd/MM/YYYY"
        cell.creationDateLabel.text = dateFormatter.string(from: videoGroupObject.creationDate!)
        
        if let count = videoGroupObject.videoList?.count {
            let pageString = count == 1 ? "video" : "videos"
            cell.countLabel.text = "\(count) \(pageString)"
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteGroup(at: indexPath)
        default: () // Unsupported
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Actions
    
    @IBAction func addNewGroupButton(_ sender: UIBarButtonItem) {
        presentNewNotebookAlert()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Editing
    
    func presentNewNotebookAlert() {
        let alert = UIAlertController(title: "New Group", message: "Enter a name for this group", preferredStyle: .alert)

        // Create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text {
                self?.addGroup(name: name)
            }
        }
        saveAction.isEnabled = false

        // Add a text field
        alert.addTextField { textField in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                if let text = textField.text, !text.isEmpty {
                    saveAction.isEnabled = true
                } else {
                    saveAction.isEnabled = false
                }
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }

    /// Adds a new notebook to the end of the `notebooks` array
    func addGroup(name: String) {
        let videoGroup = VideoGroup(context: dataController.viewContext)
        videoGroup.name = name
        videoGroup.creationDate = Date()
        try? dataController.viewContext.save()
    }
    
    func deleteGroup(at indexPath: IndexPath) {
        let groupToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(groupToDelete)
        try? dataController.viewContext.save()
    }

    func updateEditButtonState() {
        if let sections = fetchedResultsController.sections {
            navigationItem.rightBarButtonItem?.isEnabled = sections[0].numberOfObjects > 0
        }
    }
    
    // -------------------------------------------------------------------------
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let vc = segue.destination as? VideoListTableViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.videoGroup = fetchedResultsController.object(at: indexPath)
                vc.dataController = dataController
            }
        }
    }
    // -------------------------------------------------------------------------
    
    // MARK: - Login
    
    func loginService() {
        var email:String = ""
        if (userDefaults.string(forKey: "email") != nil)
        {
            email = userDefaults.string(forKey: "email")!
        }

        var password:String = ""
        if (userDefaults.string(forKey: "password") != nil)
        {
            password = userDefaults.string(forKey: "password")!
        }
        
        if email != "" && password != "" {
            let loginManager = FirebaseAuthManager()
            loginManager.signIn(email: email, pass: password) {[weak self] (success, error) in
                guard let `self` = self else { return }
                var message: String = ""
                if (success) {
                    // success
                    debugPrint("login success")
                } else {
                    // user defaults
                    let userDefaults:UserDefaults = UserDefaults.standard
                    userDefaults.set("", forKey: "email")
                    userDefaults.set("", forKey: "password")
                    // alert
                    message = error
                    let alertController = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        self.showLoginViewController()
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        else
        {
            showLoginViewController()
        }
    }
    
    func showLoginViewController()
    {
        var loginViewController:LoginViewController = LoginViewController()
        loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginViewController.modalPresentationStyle = .fullScreen
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        
        // user defaults
        let userDefaults:UserDefaults = UserDefaults.standard
        userDefaults.set("", forKey: "email")
        userDefaults.set("", forKey: "password")
        
        // delete all core data
        
        self.showLoginViewController()
    }
    
    // -------------------------------------------------------------------------

}

extension VideoGroupTableViewController:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        @unknown default:
            break
        }
    }

    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
