//
//  ViewController.swift
//  MMSportsDigest
//
//  Created by Khant Zaw Ko on 9/5/16.
//  Copyright © 2016 Khant Zaw Ko. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
//import SlideMenuControllerSwift

private let kTableViewHeaderHeight: CGFloat = 350.0
private let kTableHeaderCutAway: CGFloat = 45.0

class TableViewController: UITableViewController {
    
    @IBOutlet weak var headlineImage: UIImageView!
    @IBOutlet weak var menuButton: UIBarButtonItem!

    let newsFeedRef = Database.database().reference().child("NewsFeed")
    var newsFeedOnStart = 10
    var newsFeedUpdateOnScroll = 5
    var loadFirst: Bool = false
    
    var headerView: UIView!
    var headerMaskLayer: CAShapeLayer!
    var categoryDict = [String:Any]()
    var savedSelectedIndexPath: IndexPath!
    var items = [NewsItem]()
    var contentOffset: CGPoint = CGPoint()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryDict = ["Premier League": NewsItem.NewsCategory.bpl,
                        "La Liga": NewsItem.NewsCategory.laliga,
                        "Series A": NewsItem.NewsCategory.seriesa,
                        "Champion League": NewsItem.NewsCategory.championleague,
                        "Europa League": NewsItem.NewsCategory.europaleague,
                        "World Cup": NewsItem.NewsCategory.worldcup,
                        "MNL": NewsItem.NewsCategory.mnl,
                        "Other": NewsItem.NewsCategory.other]
        
        tableView.rowHeight = UITableViewAutomaticDimension
        headerView = tableView.tableHeaderView
        
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)

        let effectiveHeight = kTableViewHeaderHeight - kTableHeaderCutAway
        tableView.contentInset = UIEdgeInsets(top: effectiveHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -effectiveHeight)
        
        navigationController?.navigationBar.isHidden = true
        clearsSelectionOnViewWillAppear = false
        
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.black.cgColor
        headerView.layer.mask = headerMaskLayer
        updateHeaderView()
        updateNewsFeedOnLoad()
        updateHeadlineImage()
        

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.revealViewController().bounceBackOnOverdraw = true
        self.revealViewController().rightViewRevealWidth = 220
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        savedSelectedIndexPath = nil
    }

    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
        
        savedSelectedIndexPath = tableView.indexPathForSelectedRow as IndexPath!
        
        if savedSelectedIndexPath != nil {
            tableView.deselectRow(at: savedSelectedIndexPath as IndexPath, animated: true)
            
            let selectedCell:UITableViewCell = tableView.cellForRow(at: savedSelectedIndexPath as IndexPath)!
            selectedCell.contentView.backgroundColor = UIColor.white
        }
    }
    
    func updateHeadlineImage() {
        
        newsFeedRef.queryOrdered(byChild: "timestamp").queryLimited(toFirst: 1).observe(.childAdded, with: {(snapshot: DataSnapshot) in
            var postDict = snapshot.value as! [String : AnyObject]
            let imageURL = postDict["imageUrl"] as! String
            let imageRef = "images/" + imageURL
            
            let pathReference = Storage.storage().reference().child(imageRef)
            self.headlineImage.kf.indicatorType = .activity

            
            pathReference.downloadURL { (URL, error) -> Void in
                if (error != nil) {
                    //-->
                } else {
                    let image = UIImage(named: "stardust.png")
                    self.headlineImage.kf.setImage(with: URL!, placeholder: image)
                    self.headlineImage.reloadInputViews()
                }
            }
        })
    }
    
    func updateNewsFeedOnLoad() {
        
        newsFeedRef.queryOrdered(byChild: "timestamp").queryLimited(toFirst: UInt(newsFeedOnStart)).observe(.childAdded, with: {(snapshot: DataSnapshot) in
            
            var postDict = snapshot.value as! [String : AnyObject]
            
            if let newsTitle = postDict["title"], let newsContent = postDict["content"], let newsCategory = postDict["category"], let newsReference = postDict["reference"], let imageUrl = postDict["imageUrl"], let publishedDate = postDict["publishedDate"], let newsTimestamp = postDict["timestamp"] {
                
                let newsCategoryObj = self.categoryDict[newsCategory as! String]
                
                let updateItemObj = NewsItem(title: newsTitle as! String, category: newsCategoryObj! as! NewsItem.NewsCategory, content: newsContent as! String, reference: newsReference as! String, imageUrl: imageUrl as! String, publishedDate: publishedDate as! String, timestamp: newsTimestamp as! Int)
                
                self.items.append(updateItemObj)
                self.items = self.items.sorted(by: {$0.timestamp < $1.timestamp})
                self.loadFirst = true
            }
            self.reloadTableView()
        })
    }
    
    func loadMore() {
        
        newsFeedOnStart = items.count + newsFeedUpdateOnScroll
        
        newsFeedRef.queryOrdered(byChild: "timestamp").queryLimited(toFirst: UInt(newsFeedOnStart)).observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
            var newPage = [NewsItem]()
            
            if snapshot.exists(){
                let count: Int = 0
                for snap in snapshot.children {
                    
                    if (count == Int(snapshot.childrenCount) - 1) {
                        break
                    }
                    
                    let newsTitle = (snap as AnyObject).childSnapshot(forPath: "title").value as! String
                    let newsContent = (snap as AnyObject).childSnapshot(forPath: "content").value as! String
                    let newsCategory = (snap as AnyObject).childSnapshot(forPath: "category").value as! String
                    let newsCategoryObj = self.categoryDict[newsCategory]
                    let newsReference = (snap as AnyObject).childSnapshot(forPath: "reference").value as! String
                    let imageUrl = (snap as AnyObject).childSnapshot(forPath: "imageUrl").value as! String
                    let publishedDate = (snap as AnyObject).childSnapshot(forPath: "publishedDate").value as! String
                    let newsTimestamp = (snap as AnyObject).childSnapshot(forPath: "timestamp").value as! Int
                    
                    let updateItemObj = NewsItem(title: newsTitle, category: newsCategoryObj as! NewsItem.NewsCategory, content: newsContent, reference: newsReference, imageUrl: imageUrl, publishedDate: publishedDate, timestamp: newsTimestamp)
                    
                    newPage.append(updateItemObj)
                }
                
                if newPage.count >= self.newsFeedOnStart {
                    newPage.removeSubrange(0..<(self.newsFeedOnStart - self.newsFeedUpdateOnScroll))
                    self.items.append(contentsOf: newPage)
                    self.reloadTableView()
                } else {
                    self.newsFeedOnStart = self.newsFeedOnStart - self.newsFeedUpdateOnScroll
                }                
            }
        })
    }
    
    func reloadTableView() {
        
        self.contentOffset = self.tableView.contentOffset
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        self.tableView.contentOffset = self.contentOffset
        //self.scrollViewDidEndDecelerating(_, false)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height) && loadFirst
        {
            loadMore()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    func updateHeaderView() {
        let effectiveHeight = kTableViewHeaderHeight - kTableHeaderCutAway
        var headerRect = CGRect(x: 0, y: -effectiveHeight, width: tableView.bounds.width, height: kTableViewHeaderHeight)
        if tableView.contentOffset.y < -effectiveHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y + kTableHeaderCutAway
        }
        headerView.frame = headerRect
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: headerRect.height))
        path.addLine(to: CGPoint(x: 0, y: headerRect.height - kTableHeaderCutAway))
        headerMaskLayer?.path = path.cgPath
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsItemCell
        
        cell.newsItem = item
        cell.categoryLabelTopConstraint.constant = (indexPath.row == 0) ? 20 : 1
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let item = items[(indexPath as NSIndexPath).row]
        
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        
//        if indexPath.row == 0 {
//            print(tableView.backgroundView)
//            print(headerView)
//        }
        
        selectedCell.contentView.backgroundColor = item.category.toHighlight()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[(indexPath as NSIndexPath).row]
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = item.category.toHighlight()
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.white
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "detailsView" {

            let indexPath: IndexPath = self.tableView.indexPathForSelectedRow!
            let dvc: DetailsViewController = segue.destination as! DetailsViewController
            dvc.selectedItems = [items[(indexPath as NSIndexPath).row]]
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
}
