//
//  ImageFetchDelegate.swift
//  Image Search
//
//  Created by Matt Rayls on 8/10/17.
//  Copyright © 2017 Matt Rayls. All rights reserved.
//

import Foundation


protocol ImageFetchDelegate {
	func reloadCollectionViewData()
	func addMorePhotos()
	func showAlertError(errorMessage: String)
}
