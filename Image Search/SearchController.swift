//
//  SearchController.swift
//  Image Search
//
//  Created by Matt Rayls on 8/9/17.
//  Copyright © 2017 Matt Rayls. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON

class SearchController {
	
	static let shared = SearchController()
	var imageFetchDelegate: ImageFetchDelegate?
	
	let consumerKey = "7XNgKEe25LDq3fGqwGLA9ygEdYXm22XZqhxy4l82"
	let searchURL = "https://api.500px.com/v1/photos/search"
	var pageNum = ""
	var parameters: [String: String] = [:]
	var photos: [Photo] = []
	
	init() {
		parameters["consumer_key"] = consumerKey
		parameters["term"] = "dogs"
		parameters["page"] = "1"
	}
	
	func searchForKeyWord(keyword: String) {
		photos.removeAll()
		parameters["term"] = keyword
		makeRequest()
	}
	
	func makeRequest() {
		Alamofire.request(URL(string: searchURL)!, method: .get, parameters: parameters).validate().responseJSON(completionHandler: { response in
			guard response.result.isSuccess else {
				if let error = response.error {
					print(error.localizedDescription)
					// Display Alert on SearchViewController with error message
					self.imageFetchDelegate?.showAlertError(errorMessage: error.localizedDescription)
				}
				return
			}
			
			let json = JSON(response.data)

			for (index, photo) in json["photos"] {
				let photoEntry = Photo(photoData: photo)
				self.photos.append(photoEntry)
				self.downloadImage(forIndex: Int(index)!)
			}
			// Let the SearchViewController that we're ready to reload the CollectionView
			self.imageFetchDelegate?.loadCollectionViewData()
		})
	}
	
	func getImage(imageURL: URL, completion: @escaping (_ image: UIImage) -> ()) {
		var img: UIImage?
		Alamofire.request(imageURL, method: .get).responseImage { response in
			
			guard response.result.isSuccess else {
				return
			}
			
			img = UIImage(data: response.data!)
			completion(img!)
		}
	}
	
	func downloadImage(forIndex: Int) {
		Alamofire.request(URL(string:photos[forIndex].imageURL!)!, method: .get).responseImage { response in
			
			guard response.result.isSuccess else {
				return
			}
			
			var img: UIImage?
			img = UIImage(data: response.data!)
			self.photos[forIndex].image = img
		}
	}
}
