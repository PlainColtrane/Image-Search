//
//  FullscreenDetailViewController.swift
//  Image Search
//
//  Created by Matt Rayls on 8/16/17.
//  Copyright © 2017 Matt Rayls. All rights reserved.
//

import UIKit
import AlamofireImage

class FullscreenDetailViewController: UIViewController {
	
	let searchController = SearchController.shared

	@IBOutlet weak var fullscreenLabel: UILabel!
	@IBOutlet weak var fullscreenTextView: UITextView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var viewedCountLabel: UILabel!
	@IBOutlet weak var favoriteCountLabel: UILabel!
	@IBOutlet weak var progressLabel: UILabel!
	
	var index = Int()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		updateInterfaceWithPhotoData()
    }
	
	func updateInterfaceWithPhotoData() {
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
		
		imageView.af_setImage(withURL: URL(string: searchController.photos[index].highQualityImageURL!)!, placeholderImage: nil, filter: nil, progress: { progress in
			// Updates the label with the percent that the image has downloaded
			self.progressLabel.text = "\(Int(progress.fractionCompleted*100))%"
		}, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.4), runImageTransitionIfCached: false, completion: { _ in
			self.progressLabel.isHidden = true
		})
	}

	@IBAction func dismissModal(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
}
