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
	let downloader = ImageDownloader()
	
	let consumerKey = "7XNgKEe25LDq3fGqwGLA9ygEdYXm22XZqhxy4l82"
	let searchURL = "https://api.500px.com/v1/photos/search"
	var pageNum = ""
	var parameters: [String: String] = [:]
	var photos: [Photo] = []
	
	var appendingArray = false
	
	init() {
		parameters["consumer_key"] = consumerKey
		parameters["term"] = "dogs"
		parameters["page"] = "1"
		parameters["image_size"] = "3"
	}
	
	func searchForKeyWord(keyword: String) {
		appendingArray = false
		photos.removeAll()
		parameters["page"] = "1"
		parameters["term"] = keyword
		makeRequest()
	}
	
	func makeRequest() {
		Alamofire.request(URL(string: searchURL)!, method: .get, parameters: parameters).validate().responseJSON(completionHandler: { response in
			print("Request: \n\(String(describing: response.request))")
			
			guard response.result.isSuccess else {
				if let error = response.error {
					print(error.localizedDescription)
					// Display Alert on SearchViewController with error message
					self.imageFetchDelegate?.showAlertError(errorMessage: error.localizedDescription)
				}
				return
			}
			
			let json = JSON(response.data!)

			for (_, photo) in json["photos"] {
				let photoEntry = Photo(photoData: photo)
				self.photos.append(photoEntry)
			}
			
			print("Photos Count: \(self.photos.count)")
			if self.appendingArray == true {
				self.imageFetchDelegate?.addMorePhotos()
			} else {
				// Let the SearchViewController that we're ready to reload the CollectionView with the initial request
				self.imageFetchDelegate?.reloadCollectionViewData()
			}
		})
	}
	
	func incrementPage() {
		appendingArray = true
		let i = Int(parameters["page"]!)! + 1
		parameters["page"] = "\(i)"
		print("We're on page \(parameters["page"]!)")
	}
}
