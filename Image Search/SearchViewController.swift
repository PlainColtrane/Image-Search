//
//  ViewController.swift
//  Image Search
//
//  Created by Matt Rayls on 8/9/17.
//  Copyright © 2017 Matt Rayls. All rights reserved.
//

import UIKit

private let reuseIdentifier = "SearchCell"

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ImageFetchDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {
	
	let searchController = SearchController.shared

	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var searchCollectionView: UICollectionView!
	let activityIndicator = UIActivityIndicatorView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		searchController.imageFetchDelegate = self
		searchController.makeRequest()
		setupActivityIndicator()
	}

	func setupActivityIndicator() {
		activityIndicator.hidesWhenStopped = true
		activityIndicator.activityIndicatorViewStyle = .whiteLarge
		view.addSubview(activityIndicator)
		activityIndicator.center = self.view.center
		
		showActivityIndicator()
	}
	
	func showActivityIndicator() {
		activityIndicator.startAnimating()
		searchCollectionView.isHidden = true
	}
	
	func hideActivityIndicator() {
		searchCollectionView.isHidden = false
		activityIndicator.stopAnimating()
	}
	
	func reloadCollectionViewData() {
		// Called when we search for a keyword
		print("Reloading Collection data")
		searchCollectionView.reloadData()
		searchCollectionView.setContentOffset(CGPoint.zero, animated: false)
		hideActivityIndicator()
	}
	
	func addMorePhotos() {
		// Called when we send a request for more entries
		print("Adding cells for infinite scroll")
		searchCollectionView.reloadData()
	}
	
	func showAlertError(errorMessage: String) {
		let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	func showFullscreenImage(forIndex: Int) {
		let imgView = UIImageView(frame: CGRect(x: view.bounds.width/2, y: view.bounds.height/2, width: view.bounds.width*0.9, height: view.bounds.height*0.75))
		
	}
	
	// MARK: UICollectionView Functions
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.view.bounds.width/3 - 4, height: self.view.bounds.width/3 - 4)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 1.0
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return searchController.photos.count
	}
	

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print("Selected")
		showFullscreenImage(forIndex: indexPath.row)
		print(searchController.photos[indexPath.row])
		
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SearchCell
		
		cell.layer.cornerRadius = 5
		cell.layer.borderColor = UIColor.white.cgColor
		cell.layer.borderWidth = 0.5
		
		// Check to make sure that we won't get a crash for an invalid index
		guard searchController.photos.count > 0 else {
			return cell
		}
		
		cell.imageTitleLabel.text = self.searchController.photos[indexPath.row].name
		cell.searchImageView.af_setImage(withURL: URL(string: searchController.photos[indexPath.row].imageURL!)!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.4), runImageTransitionIfCached: false, completion: { _ in
			
		})
		
		// Request the next page automatically
		if (searchController.photos.count - indexPath.item) == 20 {
			searchController.incrementPage() // Let the Controller know we want the next page in order
			searchController.makeRequest()
		}
		
		return cell
	}
	
	// MARK: SearchBar Functions
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		print("Editing has begun")
	}
	
	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		print("Should end editing")
		
		guard (searchBar.text?.characters.count)! > 0 else {
			return true
		}
		
		searchController.searchForKeyWord(keyword: searchBar.text!)
		showActivityIndicator()
		
		return true
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		// Called just so we can realign the activity indicator to the center
		coordinator.animate(alongsideTransition: { _ in
			self.activityIndicator.center = self.view.center
		}, completion: { _ in
			self.searchCollectionView.reloadData()
		})
		
	}
}
