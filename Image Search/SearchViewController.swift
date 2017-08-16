//
//  ViewController.swift
//  Image Search
//
//  Created by Matt Rayls on 8/10/17.
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
		searchController.imageFetchDelegate = self
		searchController.makeRequest() // Sets the initial request so that the Collection view is filled with dogs upon load
		setupActivityIndicator()
	}

	func setupActivityIndicator() {
		activityIndicator.hidesWhenStopped = true
		activityIndicator.activityIndicatorViewStyle = .whiteLarge
		activityIndicator.center = self.view.center
		view.addSubview(activityIndicator)
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
	
	func showAlertError(errorMessage: String) {
		// Displays if there's an error while fetching photos
		let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	// MARK: UICollectionView Functions
	func reloadCollectionViewData() {
		// Called when we search for a keyword
		print("Reloading Collection data")
		searchCollectionView.reloadData()
		searchCollectionView.setContentOffset(CGPoint.zero, animated: false)
		hideActivityIndicator()
	}
	
	func addMorePhotos() {
		// Called when we send a request for more entries (and scroll the collection view towards the end indexes)
		print("Adding cells for infinite scroll")
		searchCollectionView.reloadData()
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		// Makes sure we get 3 images in a row (with a couple pixels to spare) and that the imageView is a square shape
		return CGSize(width: self.view.bounds.width/3 - 4, height: self.view.bounds.width/3 - 4)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 1.0
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return searchController.photos.count
	}
	

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print("Selected Item at: \(indexPath.row)")
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
		
		// Requests the next page of photos automatically
		if (searchController.photos.count - indexPath.item) == 20 {
			searchController.incrementPage() // Let the Controller know we want the next page in order
			searchController.makeRequest()
		}
		
		return cell
	}
	
	// MARK: PrepareForSegue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "detailSegue" {
			let fullscreenDetailVC = segue.destination as! FullscreenDetailViewController
			if let indexPath = searchCollectionView.indexPathsForSelectedItems?.first {
				fullscreenDetailVC.index = indexPath.row
			}
		}
	}
	
	// MARK: SearchBar Functions
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		
		guard (searchBar.text?.characters.count)! > 0 else {
			return
		}
		
		searchController.searchForKeyWord(keyword: searchBar.text!)
		showActivityIndicator()
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
