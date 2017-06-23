//
//  SuperheroViewController.swift
//  Flixy
//
//  Created by Gerardo Parra on 6/23/17.
//  Copyright © 2017 Gerardo Parra. All rights reserved.
//

import UIKit

class SuperheroViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var movies: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        
        fetchMovies()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell
        let movie = movies[indexPath.item]
        if let posterPathString = movie["poster_path"] as? String {
            let baseURLString = "https://image.tmdb.org/t/p/w500"
            let posterURL = URL(string: baseURLString + posterPathString)!
            cell.posterImageView.af_setImage(withURL: posterURL)
        }
        return cell
    }
    
    func fetchMovies() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=8ab5fb42722f7bbca141a05b54f53087")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // Runs when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movies = dataDictionary["results"] as! [[String: Any]]
                self.movies = movies
                self.collectionView.reloadData()
                // refreshControl.endRefreshing()
            }
        }
        task.resume()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
