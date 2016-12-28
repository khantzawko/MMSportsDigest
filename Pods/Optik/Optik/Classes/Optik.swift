//
//  Optik.swift
//  Optik
//
//  Created by Htin Linn on 5/14/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

// MARK: - Public functions

/**
 Creates and returns a view controller in which the specified images are displayed.
 
 - parameter images:                        Images to be displayed.
 - parameter initialImageDisplayIndex:      Index of first image to display.
 - parameter dismissButtonImage:            Image for the dismiss button.
 - parameter dismissButtonPosition:         Dismiss button position.
 
 - returns: The created view controller.
 */
public func imageViewerWithImages(_ images: [UIImage],
                                  initialImageDisplayIndex: Int = 0,
                                  dismissButtonImage: UIImage? = nil,
                                  dismissButtonPosition: DismissButtonPosition = .topLeading) -> UIViewController {
    return imageViewerWithData(.local(images: images),
                               initialImageDisplayIndex: initialImageDisplayIndex,
                               dismissButtonImage: dismissButtonImage,
                               dismissButtonPosition: dismissButtonPosition)
}

/**
 Creates and returns a view controller in which images from the specified URLs are downloaded and displayed.
 
 - parameter urls:                          Image URLs.
 - parameter initialImageDisplayIndex:      Index of first image to display.
 - parameter imageDownloader:               Image downloader.
 - parameter activityIndicatorColor:        Tint color of the activity indicator that is displayed while images are being downloaded.
 - parameter dismissButtonImage:            Image for the dismiss button.
 - parameter dismissButtonPosition:         Dismiss button position.
 
 - returns: The created view controller.
 */
public func imageViewerWithURLs(_ urls: [URL],
                                initialImageDisplayIndex: Int = 0,
                                imageDownloader: ImageDownloader,
                                activityIndicatorColor: UIColor = UIColor.white,
                                dismissButtonImage: UIImage? = nil,
                                dismissButtonPosition: DismissButtonPosition = .topLeading) -> UIViewController {
    return imageViewerWithData(.remote(urls: urls, imageDownloader: imageDownloader),
                               initialImageDisplayIndex: initialImageDisplayIndex,
                               activityIndicatorColor: activityIndicatorColor,
                               dismissButtonImage: dismissButtonImage,
                               dismissButtonPosition: dismissButtonPosition)
}

// MARK: - Private functions

private func imageViewerWithData(_ imageData: ImageData,
                                 initialImageDisplayIndex: Int,
                                 activityIndicatorColor: UIColor? = nil,
                                 dismissButtonImage: UIImage?,
                                 dismissButtonPosition: DismissButtonPosition) -> UIViewController {
    let bundle = Bundle(for: AlbumViewController.self)
    let defaultDismissButtonImage = UIImage(named: "DismissIcon", in: bundle, compatibleWith: nil)
    
    return AlbumViewController(imageData: imageData,
                               initialImageDisplayIndex: initialImageDisplayIndex,
                               activityIndicatorColor: activityIndicatorColor,
                               dismissButtonImage: (dismissButtonImage != nil) ? dismissButtonImage : defaultDismissButtonImage,
                               dismissButtonPosition: dismissButtonPosition)
}
