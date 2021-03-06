//
//  Photo.swift
//  Image Search
//
//  Created by Matt Rayls on 8/10/17.
//  Copyright © 2017 Matt Rayls. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Photo {	
	let imageURL: String?
	let highQualityImageURL: String?
	let name: String?
	let description: String?
	let timesViewed: Int?
	let favoritesCount: Int?
	
	init(photoData: JSON) {
		self.imageURL = photoData["images"][0]["url"].stringValue
		self.highQualityImageURL = photoData["images"][1]["url"].stringValue
		self.name = photoData["name"].stringValue
		self.description = photoData["description"].stringValue
		self.timesViewed = photoData["times_viewed"].intValue
		self.favoritesCount = photoData["favorites_count"].intValue
	}
}
