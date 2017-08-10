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
	let baseurl = "https://api.500px.com/v1/photos/search"
	
	var searchTerm = "dogs"
	var pageNum = ""
	var query = "?term=SEARCH_TERM&consumer_key=CONSUMER_KEY&page=PAGE_NUM"
	
	var parameters: [String: String] = [:]
	var photos: [Photo] = []
	
	init() {
//		query = "?term=\(searchTerm)&consumer_key=\(consumerKey)&page=PAGE_NUM"
		parameters["consumer_key"] = consumerKey
//		parameters["consumer_key"] = "22"
		parameters["term"] = "dogs"
		parameters["page"] = "1"
	}
	
	func makeRequest() {
		Alamofire.request(URL(string: baseurl)!, method: .get, parameters: parameters).validate().responseJSON(completionHandler: { response in
			print("Request: \n\(String(describing: response.request))")
			print("Response is \n\(String(describing: response.response))")
			print("Result: \n\(response.result)")
			
			guard response.result.isSuccess else {
				if let error = response.error {
					print(error.localizedDescription)
					self.imageFetchDelegate?.showAlertError(errorMessage: error.localizedDescription)
				}
				return
			}
			
			let json = JSON(response.data)
			
			for (_,photo) in json["photos"] {
				let photoEntry = Photo(photoData: photo)
				self.photos.append(photoEntry)
			}
			print(self.photos.count)
			print("Photo Array: \n\(self.photos)")
			
			// Let
			self.imageFetchDelegate?.loadCollectionViewData()
		})
	}
	
	func getImage(imageURL: URL, completion: @escaping (_ image: UIImage) -> ()) {
		var img: UIImage?
		Alamofire.request(imageURL, method: .get).responseImage { response in
			guard let image = response.result.value else {
				print("There was an error retrieving the image")
				return
			}
			img = UIImage(data: response.data!)
			
			completion(img!)
		}
	}
}
