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

class PrismMediaController: UITableViewController, UIWebViewDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var headlineImage: UIImageView!
    
    var htmlContent: String!
    var headerView: UIView!
    var headerMaskLayer: CAShapeLayer!
    var contentHeight: CGFloat = 0.0
    
    
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
        
        htmlContent = "<style> body {margin-left: 12px; margin-right: 12px; font-family: Helvetica Neue; font-size: 16px;}</style> <body> <h3> Prism Media</h3><p> ● Sports Digest is a product of Prism Media, Inc. yet the Best Sports App in features and technology factor <br>  ● Contact Us: <a href='contactus@prismmedia.co'>contactus@prismmedia.co</a>  <br> </p> <h3> Version 1.0.0 </h3><p> ● Realtime sports news update <br> ● Ability to watch football highlights <br> ● Ability to check livescore </p> <h3> What's New in this version </h3> <p> ● Discussion Panel added. <br> ● Users are able to regieter, post discussion headline and discuss through the app. <br> ● Comment section added. <br> ● Android version is COMING SOON! :) </p> </body>"
        
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! PrismMediaCell
    
        cell.webView.tag = indexPath.row
        cell.webView.delegate = self
        cell.isUserInteractionEnabled = true
        cell.webView.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height)
        cell.backgroundView = cell.webView
        cell.webView.loadHTMLString(htmlContent, baseURL: nil)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return contentHeight
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! PrismMediaCell
        cell.webView.isUserInteractionEnabled = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        if contentHeight == webView.scrollView.contentSize.height {
            return
        }
        
        contentHeight = webView.scrollView.contentSize.height
        
        let index = IndexPath(row: 0, section: 0)
        tableView.reloadRows(at: [index as IndexPath], with: .automatic)
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
}
