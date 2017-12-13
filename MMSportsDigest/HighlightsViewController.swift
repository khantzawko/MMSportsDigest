//
//  HighlightsViewController.swift
//  MMSportsDigest
//
//  Created by Khant Zaw Ko on 25/10/16.
//  Copyright © 2016 Khant Zaw Ko. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase

private let kTableViewHeaderHeight: CGFloat = 150.0
private let kTableHeaderCutAway: CGFloat = 0.0

class HighlightsViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var headlineImage: UIImageView!
    
    let highlightsRef = Database.database().reference().child("Highlights")
    var highlightsVidsOnStart = 1
    var highlightsVidsOnScroll = 1
    var loadFirst: Bool = false
    
    var items = [HightlightsItem]()
    
    var headerView: UIView!
    var headerMaskLayer: CAShapeLayer!
    var contentOffset: CGPoint = CGPoint()
    
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
        updateNewsFeedOnLoad()
        
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
    
    func updateNewsFeedOnLoad() {
        
        highlightsRef.queryOrdered(byChild: "timestamp").queryLimited(toFirst: UInt(highlightsVidsOnStart)).observe(.childAdded, with: {(snapshot: DataSnapshot) in
            
            var postDict = snapshot.value as! [String : AnyObject]
            
            if let homeTeam = postDict["homeTeam"], let awayTeam = postDict["awayTeam"], let videoUrl = postDict["videoUrl"], let videoSize = postDict["videoSize"], let videoPublishedDate = postDict["videoPublishedDate"], let timestamp = postDict["timestamp"] {
                
                let updatedVideoObj = HightlightsItem(homeTeam: homeTeam as! String, awayTeam: awayTeam as! String, videoUrl: videoUrl as! String, videoSize: videoSize as! String, videoPublishedDate: videoPublishedDate as! String, timestamp: timestamp as! Int)
                
                self.items.append(updatedVideoObj)
                self.items = self.items.sorted(by: {$0.timestamp < $1.timestamp})
                self.loadFirst = true
            }
            self.reloadTableView()
        })
    }
    
    func loadMore() {
        
        highlightsVidsOnStart = items.count + highlightsVidsOnScroll
        
        highlightsRef.queryOrdered(byChild: "timestamp").queryLimited(toFirst: UInt(highlightsVidsOnStart)).observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
            
            var newPage = [HightlightsItem]()
            
            if snapshot.exists(){
                let count: Int = 0
                for snap in snapshot.children {
                    
                    if (count == Int(snapshot.childrenCount) - 1) {
                        break
                    }
                    
                    let homeTeam = (snap as AnyObject).childSnapshot(forPath: "homeTeam").value as! String
                    let awayTeam = (snap as AnyObject).childSnapshot(forPath: "awayTeam").value as! String
                    let videoUrl = (snap as AnyObject).childSnapshot(forPath: "videoUrl").value as! String
                    let videoSize = (snap as AnyObject).childSnapshot(forPath: "videoSize").value as! String
                    let videoPublishedDate = (snap as AnyObject).childSnapshot(forPath: "videoPublishedDate").value as! String
                    let timestamp = (snap as AnyObject).childSnapshot(forPath: "timestamp").value as! Int
                    
                let updatedVideoObj = HightlightsItem(homeTeam: homeTeam, awayTeam: awayTeam, videoUrl: videoUrl, videoSize: videoSize, videoPublishedDate: videoPublishedDate, timestamp: timestamp)
                    
                    newPage.append(updatedVideoObj)
                }
                
                if newPage.count >= self.highlightsVidsOnStart {
                    newPage.removeSubrange(0..<(self.highlightsVidsOnStart - self.highlightsVidsOnScroll))
                    self.items.append(contentsOf: newPage)
                    self.reloadTableView()
                } else {
                    self.highlightsVidsOnStart = self.highlightsVidsOnStart - self.highlightsVidsOnScroll
                }
            }
        })
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height) && loadFirst
        {
            loadMore()
        }
    }
    
    func reloadTableView() {
        
        self.contentOffset = self.tableView.contentOffset
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        self.tableView.contentOffset = self.contentOffset
        //self.scrollViewDidEndDecelerating(_, false)
    }
    
    
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HighlightsItemCell
        cell.highlightsItem = item
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videoURL = NSURL(string: items[indexPath.row].videoUrl)
        let player = AVPlayer(url: videoURL! as URL)
        let controller = AVPlayerViewController()
        controller.player = player
        player.play()
        present(controller, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
}

extension AVPlayerViewController {
    
    override open var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    override open var shouldAutorotate: Bool {
        return true
    }
    
    
}
