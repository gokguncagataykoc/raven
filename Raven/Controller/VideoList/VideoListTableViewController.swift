//
//  VideoListTableViewController.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 12.02.2022.
//

import UIKit
import CoreData

class VideoListTableViewController: UITableViewController {

    var videoGroup: VideoGroup!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<VideoList>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<VideoList> = VideoList.fetchRequest()
        let predicate = NSPredicate(format: "videoGroup == %@", videoGroup)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(videoGroup.name!)-list")
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
        
        self.navigationItem.title = videoGroup.name
        
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
        self.tableView.reloadData()
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
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let video = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoListCell", for: indexPath) as! VideoListTableViewCell

        // Configure the cell...
        cell.title.text = video.title
        cell.channelTitle.text = video.channelTitle
        // ISO8601 String to Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let publishDate = dateFormatter.date(from: video.publishTime!)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let dateStr = formatter.string(from: publishDate!)
        cell.publishTime.text = "\(dateStr)"
        cell.imgActivityIndicator.startAnimating()
        
        DispatchQueue.global().async {
            if let urlStr:String = video.thumbnail {
                if let url = URL(string: urlStr) {
                    if let data = try? Data(contentsOf: url) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                cell.thumbnail.image = image
                                cell.imgActivityIndicator.stopAnimating()
                            }
                        }
                    }
                }
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteVideo(at: indexPath)
        default: () // Unsupported
        }
    }
    
    // -------------------------------------------------------------------------
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? VideoSearchTableViewController {
            vc.videoGroup = videoGroup
            vc.dataController = dataController
        }
        else if let vc = segue.destination as? VideoDetailTableViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.videoList = fetchedResultsController.object(at: indexPath)
                vc.dataController = dataController
            }
        }
    }
    // -------------------------------------------------------------------------
    
    // MARK: - Editing

    // Adds a new `Video` to the end of the `Video Group`'s `Video` array
    func addVideo(selectedVideo: Video) {
        let video = VideoList(context: dataController.viewContext)
        video.id = selectedVideo.id.videoId
        video.title = selectedVideo.snippet.title
        video.channelTitle = selectedVideo.snippet.channelTitle
        video.publishTime = selectedVideo.snippet.publishTime
        video.thumbnail = selectedVideo.snippet.thumbnails.high.url
        video.creationDate = Date()
        video.videoGroup = videoGroup
        
        try? dataController.viewContext.save()
    }

    // Deletes the `Note` at the specified index path
    func deleteVideo(at indexPath: IndexPath) {
        let videoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(videoToDelete)
        try? dataController.viewContext.save()
    }

    func updateEditButtonState() {
       navigationItem.rightBarButtonItem?.isEnabled = fetchedResultsController.sections![0].numberOfObjects > 0
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    // -------------------------------------------------------------------------
    
}

extension VideoListTableViewController:NSFetchedResultsControllerDelegate {
    
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
