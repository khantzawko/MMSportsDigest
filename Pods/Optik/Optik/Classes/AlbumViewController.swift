//
//  AlbumViewController.swift
//  Optik
//
//  Created by Htin Linn on 5/9/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

internal final class AlbumViewController: UIViewController {
    
    fileprivate struct Constants {
        static let SpacingBetweenImages: CGFloat = 40
        static let DismissButtonDimension: CGFloat = 60
        
        static let TransitionAnimationDuration: TimeInterval = 0.3
    }
    
    // MARK: - Properties
    
    // MARK: Private properties
    
    fileprivate var pageViewController: UIPageViewController?
    
    fileprivate var imageData: ImageData
    fileprivate var initialImageDisplayIndex: Int
    fileprivate var activityIndicatorColor: UIColor?
    fileprivate var dismissButtonImage: UIImage?
    fileprivate var dismissButtonPosition: DismissButtonPosition
    
    fileprivate var cachedRemoteImages: [URL: UIImage] = [:]
    fileprivate var viewDidAppear: Bool = false
    
    // MARK: - Init/Deinit
    
    init(imageData: ImageData, initialImageDisplayIndex: Int, activityIndicatorColor: UIColor?, dismissButtonImage: UIImage?, dismissButtonPosition: DismissButtonPosition) {
        self.imageData = imageData
        self.initialImageDisplayIndex = initialImageDisplayIndex
        self.activityIndicatorColor = activityIndicatorColor
        self.dismissButtonImage = dismissButtonImage
        self.dismissButtonPosition = dismissButtonPosition
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Invalid initializer.")
    }
    
    // MARK: - Override functions
    
    override func loadView() {
        super.loadView()
        
        setupPageViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDesign()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // HACK: UIKit doesn't animate status bar transition on iOS 9. So, manually animate it.
        if !viewDidAppear {
            viewDidAppear = true
            
            UIView.animate(withDuration: Constants.TransitionAnimationDuration, animations: {
                self.setNeedsStatusBarAppearanceUpdate()
            }) 
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (_) in
            self.pageViewController?.view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            }, completion: nil)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .fade
    }
    
    override func didReceiveMemoryWarning() {
        cachedRemoteImages = [:]
    }
    
    // MARK: - Private functions
    
    fileprivate func setupDesign() {
        view.backgroundColor = UIColor.black
        
        setupDismissButton()
    }
    
    fileprivate func setupPageViewController() {
        let pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                      navigationOrientation: .horizontal,
                                                      options: [UIPageViewControllerOptionInterPageSpacingKey : Constants.SpacingBetweenImages])
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let imageViewController = imageViewControllerAtIndex(initialImageDisplayIndex) {
            pageViewController.setViewControllers([imageViewController],
                                                  direction: .forward,
                                                  animated: false,
                                                  completion: nil)
        }
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        didMove(toParentViewController: pageViewController)
        
        self.pageViewController = pageViewController
    }
    
    fileprivate func setupDismissButton() {
        let dismissButton = UIButton(type: .custom)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.setImage(dismissButtonImage, for: UIControlState())
        dismissButton.addTarget(self, action: #selector(AlbumViewController.didTapDismissButton(_:)), for: .touchUpInside)
        
        let xAnchorAttribute = dismissButtonPosition.xAnchorAttribute()
        let yAnchorAttribute = dismissButtonPosition.yAnchorAttribute()
        
        view.addSubview(dismissButton)
        
        view.addConstraint(
            NSLayoutConstraint(item: dismissButton,
                attribute: xAnchorAttribute,
                relatedBy: .equal,
                toItem: view,
                attribute: xAnchorAttribute,
                multiplier: 1,
                constant: 0)
        )
        view.addConstraint(
            NSLayoutConstraint(item: dismissButton,
                attribute: yAnchorAttribute,
                relatedBy: .equal,
                toItem: view,
                attribute: yAnchorAttribute,
                multiplier: 1,
                constant: 0)
        )
        view.addConstraint(
            NSLayoutConstraint(item: dismissButton,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: Constants.DismissButtonDimension)
        )
        view.addConstraint(
            NSLayoutConstraint(item: dismissButton,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: Constants.DismissButtonDimension)
        )
    }
    
    fileprivate func imageViewControllerAtIndex(_ index: Int) -> ImageViewController? {
        switch imageData {
        case .local(let images):
            guard index >= 0 && index < images.count else {
                return nil
            }
            
            return ImageViewController(image: images[index], index: index)
        case .remote(let urls, let imageDownloader):
            guard index >= 0 && index < urls.count else {
                return nil
            }
            
            let imageViewController = ImageViewController(activityIndicatorColor: activityIndicatorColor, index: index)
            let url = urls[index]
            
            if let image = cachedRemoteImages[url] {
                imageViewController.image = image
            } else {
                imageDownloader.downloadImageAtURL(url, completion: {
                    [weak self] (image) in
                    
                    self?.cachedRemoteImages[url] = image
                    imageViewController.image = image
                    })
            }
            
            return imageViewController
        }
    }
    
    @objc fileprivate func didTapDismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension AlbumViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let imageViewController = viewController as? ImageViewController else {
            return nil
        }
        
        return imageViewControllerAtIndex(imageViewController.index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let imageViewController = viewController as? ImageViewController else {
            return nil
        }
        
        return imageViewControllerAtIndex(imageViewController.index + 1)
    }
    
}

extension AlbumViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                                               previousViewControllers: [UIViewController],
                                               transitionCompleted completed: Bool) {
        guard completed == true && previousViewControllers.count > 0 else {
            return
        }
        
        previousViewControllers.forEach { (viewController) in
            let imageViewController = viewController as? ImageViewController
            imageViewController?.resetImageView()
        }
    }
    
}
