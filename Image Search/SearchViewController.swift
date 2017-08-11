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
	
	// Fullscreen view
	@IBOutlet weak var fullscreenView: UIView!
	@IBOutlet weak var fullscreenLabel: UILabel!
	@IBOutlet weak var fullscreenImageView: UIImageView!
	@IBOutlet weak var fullscreenTextView: UITextView!
	@IBOutlet weak var viewedCountLabel: UILabel!
	@IBOutlet weak var favoriteCountLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		searchController.imageFetchDelegate = self
		searchController.makeRequest()
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
		let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	func showFullscreenImage(index: Int) {
		searchBar.resignFirstResponder()
		fullscreenView.isHidden = false
		fullscreenLabel.text = searchController.photos[index].name
		
		if let text = searchController.photos[index].description {
			fullscreenTextView.text = text
			fullscreenTextView.isHidden = false
		} else {
			fullscreenTextView.isHidden = true
		}
		
		if let viewed = searchController.photos[index].timesViewed {
			viewedCountLabel.text = String(describing: viewed)
		}
		
		if let favorites = searchController.photos[index].favoritesCount {
			favoriteCountLabel.text = String(describing: favorites)
		}
		
		fullscreenImageView.af_setImage(withURL: URL(string: searchController.photos[index].imageURL!)!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.4), runImageTransitionIfCached: false, completion: { _ in
		
		})
	}
	
	@IBAction func hideFullscreenImage() {
		fullscreenView.isHidden = true
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
		// Called when we send a request for more entries
		print("Adding cells for infinite scroll")
		searchCollectionView.reloadData()
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
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
		showFullscreenImage(index: indexPath.row)
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
