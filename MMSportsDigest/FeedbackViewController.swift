//
//  FeedbackViewController.swift
//  MMSportsDigest
//
//  Created by Khant Zaw Ko on 25/10/16.
//  Copyright © 2016 Khant Zaw Ko. All rights reserved.
//

import UIKit
import Firebase

private let kTableViewHeaderHeight: CGFloat = 150.0
private let kTableHeaderCutAway: CGFloat = 0.0

class FeedbackViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var headlineImage: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    let userFeedbackRef = Database.database().reference().child("UserFeedback")
    let staticUserFeedback = String()
    let currentDateTime = NSDate()

    
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
        
        self.hideKeyboardWhenTappedAround()

        textView.delegate = self
        textView.returnKeyType = .done

        
        self.revealViewController().bounceBackOnOverdraw = true
        self.revealViewController().rightViewRevealWidth = 220
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func pressedSubmit(_ sender: AnyObject) {
        
        if self.textView.text == "" {
            cancelFeedbackAction()
        } else {
            submitFeedbackAction()
        }
    }
    
    func submitFeedbackAction() {
        let alertController = UIAlertController(title: "Confirmation!", message: "Are you sure about submiting feedback?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("you have pressed the Cancel button")
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Submit", style: .default) { (action:UIAlertAction!) in
            self.submittingFeedback()
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
    
    func submittingFeedback() {
        
        let alertController = UIAlertController(title: "Thank you for your feedback!", message: "", preferredStyle: .alert)

        let OKAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in
            
            self.post()
            self.textView.text = ""
            self.dismissKeyboard()            
        }
        
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
    
    func post() {
        guard let staticUserFeedback = self.textView.text else {
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
        
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        var feedbackDate = formatter.string(from: currentDateTime as Date)
        feedbackDate = feedbackDate.replacingOccurrences(of: "+0000", with: "GMT")
        
        let feedbackTimestamp = 0 - currentDateTime.timeIntervalSince1970 * 1000

        let post = ["feedback": staticUserFeedback, "feedbackDate": feedbackDate, "timestamp": Int(feedbackTimestamp)] as [String : Any]
        userFeedbackRef.childByAutoId().setValue(post)
    }
    
    func NSDateToString(date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        return dateFormatter.string(from: date as Date)
    }
    
    func cancelFeedbackAction() {
        
        let alertController = UIAlertController(title: "Please fill up feedback form!", message: "", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in

        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion:nil)
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

