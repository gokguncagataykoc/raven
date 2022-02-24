//
//  VideoDetailTableViewController.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 19.02.2022.
//

import UIKit
import CoreData

class VideoDetailTableViewController: UITableViewController {

    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var videoStats: Stats!
    
    var currentSearchTask: URLSessionDataTask?
    
    var videoList: VideoList!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<VideoStats>!
    
    @IBOutlet weak var imgActivityIndicator: UIActivityIndicatorView!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<VideoStats> = VideoStats.fetchRequest()
        let predicate = NSPredicate(format: "list2 == %@", videoList)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(videoList.id!)-list")
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
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.navigationItem.title = videoList.channelTitle
        self.titleLabel.text = videoList.title
        imgActivityIndicator.startAnimating()
        
        DispatchQueue.global().async {
            if let urlStr:String = self.videoList.thumbnail {
                if let url = URL(string: urlStr) {
                    if let data = try? Data(contentsOf: url) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.thumbnail.image = image
                                self.imgActivityIndicator.stopAnimating()
                            }
                        }
                    }
                }
            }
        }
        
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
        let stats = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoDetailCell", for: indexPath) as! VideoDetailTableViewCell

        // Configure the cell...
        let viewCount = Int(stats.viewCount!)
        let likeCount = Int(stats.likeCount!)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal          // Set defaults to the formatter that are common for showing decimal numbers
        numberFormatter.usesGroupingSeparator = true    // Enabled separator
        numberFormatter.groupingSeparator = "."         // Set the separator to "."
        numberFormatter.groupingSize = 3
        
        cell.viewCountsLabel.text = "View count: \(numberFormatter.string(for: viewCount) ?? "")"
        cell.likeCountsLabel.text = "Like count: \(numberFormatter.string(for: likeCount) ?? "")"
        
        // Create Date Formatter
        let dateFormatter = DateFormatter()
        // Set Date Format
        dateFormatter.dateFormat = "dd/MM/YYYY HH:mm"
        cell.creationDateLabel.text = dateFormatter.string(from: stats.creationDate!)
        

        return cell
    }

    @IBAction func getVideoData(_ sender: UIBarButtonItem) {
        currentSearchTask?.cancel()
        currentSearchTask = YoutubeClient.getVideoStats(videoId: videoList.id!) { stats, error in
            
            let vStats = VideoStats(context: self.dataController.viewContext)
            vStats.id = stats[0].id
            vStats.viewCount = stats[0].statistics.viewCount
            vStats.likeCount = stats[0].statistics.likeCount
            vStats.commentCount = stats[0].statistics.commentCount
            vStats.creationDate = Date()
            vStats.list2 = self.videoList
            
            try? self.dataController.viewContext.save()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension VideoDetailTableViewController:NSFetchedResultsControllerDelegate {
    
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
