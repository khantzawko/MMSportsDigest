//
//  ViewController.swift
//  MMSportsDigest
//
//  Created by Khant Zaw Ko on 9/5/16.
//  Copyright © 2016 Khant Zaw Ko. All rights reserved.
//

import UIKit
import Firebase
import Optik

private let kTableViewHeaderHeight: CGFloat = 350.0
private let kTableHeaderCutAway: CGFloat = 0.0

class DetailsViewController: UITableViewController, UIWebViewDelegate {
    
    @IBOutlet weak var headlineImage: UIImageView!

    var headerView: UIView!
    var headerMaskLayer: CAShapeLayer!
    var selectedItems = [NewsItem]()
    var htmlContent: String!
    
    var newsTitle: String!
    var newsContent: String!
    var newsCategory: String!
    var newsCategoryColor: UIColor!
    var newsCategoryColorCode: String!
    var newsPublishedDate: String!
    var newsReference: String!
    var contentHeight: CGFloat = 0.0
    
    var imageViews = [UIImageView]()
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        
        _ = navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        getNewsData()
        
        imageViews.append(headlineImage)

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
        
        
        let imageRef = "images/" + self.selectedItems[0].imageUrl
        let pathReference = Storage.storage().reference().child(imageRef)

        self.headlineImage.kf.indicatorType = .activity

        // Fetch the download URL
        pathReference.downloadURL { (URL, error) -> Void in
            if (error != nil) {
                
            } else {
                let image = UIImage(named: "stardust.png")
                self.headlineImage.kf.setImage(with: URL!, placeholder: image)
                self.addHeadlineImageTapGesture()
            }
        }
        
    }
    
    func addHeadlineImageTapGesture() {
        headlineImage.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        headlineImage.addGestureRecognizer(tapGestureRecognizer)
    }

    
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        let imageViewer = Optik.imageViewer(withImages: [headlineImage.image!],
                                            initialImageDisplayIndex: 0,
                                            delegate: self,
                                            dismissButtonImage: UIImage(named: "DismissIcon"), 
                                            dismissButtonPosition: .topTrailing)

        present(imageViewer, animated: true, completion: nil)
    }

    func getNewsData() {
        newsTitle = selectedItems[0].title
        newsContent = selectedItems[0].content
        newsCategory = selectedItems[0].category.toString()
        newsCategoryColor = selectedItems[0].category.toColor()
        newsPublishedDate = selectedItems[0].publishedDate
        newsReference = selectedItems[0].reference
        newsCategoryColorCode = newsCategoryColor.htmlRGBColor
    }
    
    func fromStringToDateTime(_ format: String, dateToString: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: dateToString)
        dateFormatter.dateStyle = .medium
        //dateFormatter.timeStyle = .short
        let dateToString = dateFormatter.string(from: date!)
        
        return dateToString
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return contentHeight
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DetailsNewsItemCell
        
        let formattedDate: String = fromStringToDateTime("E, d MMM yyyy HH:mm:ss Z", dateToString: newsPublishedDate!)
        
        htmlContent = "<style> .category {color: \(newsCategoryColorCode!);} body {margin-left: 12px; margin-right: 12px; font-family: Zawgyi-One; font-size: 16px;}</style> <body> <p class = 'category'> \(newsCategory!) </p> <h3> \(newsTitle!) </h3> <p> \(newsContent!) <br> <br> <b> \(newsReference!), </b> \(formattedDate). </p> </body>"
        
        cell.webView.tag = indexPath.row
        cell.webView.delegate = self
        cell.isUserInteractionEnabled = true
        cell.webView.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height)
        cell.backgroundView = cell.webView
        cell.webView.loadHTMLString(htmlContent, baseURL: nil)

        return cell
    }

    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        if contentHeight == webView.scrollView.contentSize.height {
            return
        }
        
        contentHeight = webView.scrollView.contentSize.height
        
        let index = IndexPath(row: 0, section: 0)
        tableView.reloadRows(at: [index as IndexPath], with: .automatic)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
}

extension DetailsViewController: ImageViewerDelegate {
    
    func transitionImageView(for index: Int) -> UIImageView {
        return headlineImage
    }

    func imageViewerDidDisplayImage(at index: Int) {
    }
    
}

extension UIColor {
    var rgbComponents:(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r,g,b,a)
        }
        return (0,0,0,0)
    }
    // hue, saturation, brightness and alpha components from UIColor**
    var hsbComponents:(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var hue:CGFloat = 0
        var saturation:CGFloat = 0
        var brightness:CGFloat = 0
        var alpha:CGFloat = 0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha){
            return (hue,saturation,brightness,alpha)
        }
        return (0,0,0,0)
    }
    var htmlRGBColor:String {
        return String(format: "#%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255),Int(rgbComponents.blue * 255))
    }
    var htmlRGBaColor:String {
        return String(format: "#%02x%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255),Int(rgbComponents.blue * 255),Int(rgbComponents.alpha * 255) )
    }
}

