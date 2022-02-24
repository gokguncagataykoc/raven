//
//  VideoSearchTableViewController.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 18.02.2022.
//

import UIKit
import CoreData

class VideoSearchTableViewController: UITableViewController, UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var videoSearchBar: UISearchBar!
    
    var videos = [Video]()
    
    var selectedIndex = 0
    var currentSearchTask: URLSessionDataTask?
    var indicator = UIActivityIndicatorView()
    
    var videoGroup: VideoGroup!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<VideoList>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<VideoList> = VideoList.fetchRequest()
        let predicate = NSPredicate(format: "videoGroup == %@", videoGroup)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
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
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return videos.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoSearchCell", for: indexPath) as! VideoSearchTableViewCell
        
        let video = videos[indexPath.row]

        // Configure the cell...
        cell.videoId.text = video.id.videoId
        cell.title.text = video.snippet.title
        cell.channelTitle.text = video.snippet.channelTitle
        cell.publishTime.text = video.snippet.publishTime
        DispatchQueue.global().async {
            let urlStr = video.snippet.thumbnails.high.url
            if let url = URL(string: urlStr) {
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            cell.thumbnail.image = image
                        }
                    }
                    else {
                        cell.thumbnail.image = UIImage(named: "emptyImage")
                        
                        let message = "The image of the video " + video.snippet.title + " could not be loaded."
                        let alertController = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectedVideo = videos[indexPath.row]
        //VideoListTableViewController().addVideo(selectedVideo: selectedVideo)
        let video = VideoList(context: dataController.viewContext)
        video.id = selectedVideo.id.videoId
        video.title = selectedVideo.snippet.title
        video.channelTitle = selectedVideo.snippet.channelTitle
        video.publishTime = selectedVideo.snippet.publishTime
        video.thumbnail = selectedVideo.snippet.thumbnails.high.url
        video.creationDate = Date()
        video.videoGroup = videoGroup
        
        try? dataController.viewContext.save()

        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // -------------------------------------------------------------------------
    
    // MARK: - Search bare akus
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchTask?.cancel()
        activityIndicator()
        indicator.startAnimating()
        indicator.backgroundColor = .white
        currentSearchTask = YoutubeClient.getVideolist(query: searchText, pageToken: "") { videos, error in
            
            if error == nil {
                self.videos = videos
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.indicator.stopAnimating()
                    self.indicator.hidesWhenStopped = true
                }
            } else {
                let message = error?.localizedDescription
                let alertController = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        videoSearchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        videoSearchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        videoSearchBar.endEditing(true)
    }
    
    // -------------------------------------------------------------------------
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
}
