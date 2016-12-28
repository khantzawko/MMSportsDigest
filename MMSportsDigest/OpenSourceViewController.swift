//
//  OpenSourceViewController.swift
//  MMSportsDigest
//
//  Created by Khant Zaw Ko on 25/10/16.
//  Copyright © 2016 Khant Zaw Ko. All rights reserved.
//

import UIKit

private let kTableViewHeaderHeight: CGFloat = 150.0
private let kTableHeaderCutAway: CGFloat = 0.0

class OpenSourceViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var headlineImage: UIImageView!
    
    
    var headerView: UIView!
    var headerMaskLayer: CAShapeLayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        tableView.isUserInteractionEnabled = true
        tableView.rowHeight = UITableViewAutomaticDimension
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        let effectiveHeight = kTableViewHeaderHeight - kTableHeaderCutAway / 2
        tableView.contentInset = UIEdgeInsets(top: effectiveHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -effectiveHeight)
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.black.cgColor
        headerView.layer.mask = headerMaskLayer
        updateHeaderView()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.revealViewController().bounceBackOnOverdraw = true
        self.revealViewController().rightViewRevealWidth = 220
        //
        //        let galleryViewController = GalleryViewController(startIndex: displacedViewIndex, itemsDatasource: self, displacedViewsDatasource: self, configuration: galleryConfiguration)
        //        self.presentImageGallery(galleryViewController)
        
    }
    
    func updateHeaderView() {
        let effectiveHeight = kTableViewHeaderHeight - kTableHeaderCutAway / 2
        var headerRect = CGRect(x: 0, y: -effectiveHeight, width: tableView.bounds.width, height: kTableViewHeaderHeight)
        if tableView.contentOffset.y < -effectiveHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y + kTableHeaderCutAway / 2
        }
        headerView.frame = headerRect
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: headerRect.height))
        path.addLine(to: CGPoint(x: 0, y: headerRect.height - kTableHeaderCutAway))
        headerMaskLayer?.path = path.cgPath
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
}
