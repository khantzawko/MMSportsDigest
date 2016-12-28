//
//  NewsItemCell.swift
//  MMSportsDigest
//
//  Created by Khant Zaw Ko on 9/5/16.
//  Copyright © 2016 Khant Zaw Ko. All rights reserved.
//

import UIKit

class NewsItemCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var newsItem: NewsItem? {
        
        didSet {
            if let item = newsItem {
                categoryLabel.text = item.category.toString()
                categoryLabel.textColor = item.category.toColor()
                titleLabel.font = UIFont(name:"Zawgyi-One", size:16)
                titleLabel.text = item.title
                
                let formattedDate: String = fromStringToDateTime("E, d MMM yyyy HH:mm:ss Z", dateToString: item.publishedDate)

                timeLabel.text = item.reference + " ● " + formattedDate
            } else {
                categoryLabel.text = nil
                titleLabel.text = nil
            }
        }
    }
    

    func fromStringToDateTime(_ format: String, dateToString: String) -> String {
        
        var dateToString = dateToString
        let formatToLocal = DateFormatter()
        formatToLocal.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        
        
        if let dateFromString = formatToLocal.date(from: dateToString) {
            formatToLocal.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let localStringFromDate = formatToLocal.string(from: dateFromString)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let from = formatter.date(from: localStringFromDate)
            
            let now = Date()
            
            let calendar = Calendar.current
            let calenderUnit = Set<Calendar.Component>([.day, .month, .year, .weekOfMonth, .hour, .minute, .second])
            let difference = calendar.dateComponents(calenderUnit, from: from! as Date,  to: now as Date)
            
            if difference.year! >= 1 {
                dateToString = "\(difference.year!)yr ago"
            } else if difference.month! >= 1{
                dateToString = "\(difference.month!)mth ago"
            } else if difference.weekOfMonth! >= 1{
                dateToString = "\(difference.weekOfMonth!)w ago"
            } else if difference.day! >= 1{
                dateToString = "\(difference.day!)d ago"
            } else if difference.hour! >= 1{
                dateToString = "\(difference.hour!)hr ago"
            } else if difference.minute! >= 1{
                dateToString = "\(difference.minute!)m ago"
            } else if difference.second! >= 1{
                dateToString = "1m ago"
            } else {
                dateToString = "unknown"
            }
        }
        
        return dateToString
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
