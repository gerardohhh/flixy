//
//  NowPlayingViewController.swift
//  Flixy
//
//  Created by Gerardo Parra on 6/21/17.
//  Copyright © 2017 Gerardo Parra. All rights reserved.
//

import UIKit
import AlamofireImage

class NowPlayingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var movies: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertController = UIAlertController(title: "Cannot get movies", message: "The internet connection appears to be offline", preferredStyle: .alert)
        
        // create a cancel action
        let cancelAction = UIAlertAction(title: "Try Again", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        // add the cancel action to the alertController
        alertController.addAction(cancelAction)
        
        activityIndicator.startAnimating()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=8ab5fb42722f7bbca141a05b54f53087")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // Runs when the network request returns
            if let error = error {
                print(error.localizedDescription)
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true) {
                    // optional code for what happens after the alert controller has finished presenting
                    self.activityIndicator.stopAnimating()
                }
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movies = dataDictionary["results"] as! [[String: Any]]
                self.movies = movies
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
        task.resume()
        
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        let alertController = UIAlertController(title: "Cannot get movies", message: "The internet connection appears to be offline", preferredStyle: .alert)
        
        // create a cancel action
        let cancelAction = UIAlertAction(title: "Try Again", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        // add the cancel action to the alertController
        alertController.addAction(cancelAction)
        
        // Configure session so that completion handler is executed on main UI thread
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=8ab5fb42722f7bbca141a05b54f53087")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // Runs when the network request returns
            if let error = error {
                print(error.localizedDescription)
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true) {
                    // optional code for what happens after the alert controller has finished presenting
                    refreshControl.endRefreshing()
                }
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movies = dataDictionary["results"] as! [[String: Any]]
                self.movies = movies
                self.tableView.reloadData()
                refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
            }
        }
        task.resume()
    }
    
    // Remove gray effect
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Returns number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    // Implements movie cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let posterPathString = movie["poster_path"] as! String
        let baseURLString = "https://image.tmdb.org/t/p/w185"
        
        let posterURL = URL(string: baseURLString + posterPathString)!
        cell.coverImage.af_setImage(withURL: posterURL)
        
        return cell
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            let movie = movies[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
