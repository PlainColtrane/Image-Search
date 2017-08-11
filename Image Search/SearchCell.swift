//
//  SearchCell.swift
//  Image Search
//
//  Created by Matt Rayls on 8/10/17.
//  Copyright © 2017 Matt Rayls. All rights reserved.
//

import UIKit

class SearchCell: UICollectionViewCell {
	@IBOutlet weak var searchImageView: UIImageView!
	@IBOutlet weak var imageTitleLabel: UILabel!

	override func prepareForReuse() {
		super.prepareForReuse()
		
		searchImageView.af_cancelImageRequest()
		searchImageView.layer.removeAllAnimations()
		searchImageView.image = nil
	}
}
