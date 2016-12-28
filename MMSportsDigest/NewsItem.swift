//
//  NewsItem.swift
//  MMSportsDigest
//
//  Created by Khant Zaw Ko on 9/5/16.
//  Copyright © 2016 Khant Zaw Ko. All rights reserved.
//

import Foundation
import UIKit

struct NewsItem {
    
    enum NewsCategory {
        case worldcup
        case bpl
        case seriesa
        case europaleague
        case championleague
        case laliga
        case mnl
        case other
        
        func toString() -> String {
            switch self {
            case .worldcup:
                return "World Cup"
            case .bpl:
                return "Premier League"
            case .seriesa:
                return "Series A"
            case .europaleague:
                return "Europa League"
            case .championleague:
                return "Champion League"
            case .laliga:
                return "La Liga"
            case .mnl:
                return "Myanmar National League"
            case .other:
                return "Other"
            }
        }
        
        func toColor() -> UIColor {
            switch self {
            case .worldcup:
                return UIColor(red: 0.106, green: 0.686, blue: 0.125, alpha: 1)
            case .bpl:
                return UIColor(red: 0.124, green: 0.639, blue: 0.984, alpha: 1)
            case .seriesa:
                return UIColor(red: 0.322, green: 0.459, blue: 0.984, alpha: 1)
            case .europaleague:
                return UIColor(red: 0.502, green: 0.290, blue: 0.984, alpha: 1)
            case .championleague:
                return UIColor(red: 0.988, green: 0.271, blue: 0.282, alpha: 1)
            case .laliga:
                return UIColor(red: 0.620, green: 0.776, blue: 0.153, alpha: 1)
            case .mnl:
                return UIColor(red: 0.322, green: 0.776, blue: 0.153, alpha: 1)
            case .other:
                return UIColor(red: 0.322, green: 0.639, blue: 0.153, alpha: 1)
            }
        }
        
        
        func toHighlight() -> UIColor {
            
            let alphaIndex: CGFloat = 0.15
            
            switch self {
            case .worldcup:
                return UIColor(red: 0.106, green: 0.686, blue: 0.125, alpha: alphaIndex)
            case .bpl:
                return UIColor(red: 0.124, green: 0.639, blue: 0.984, alpha: alphaIndex)
            case .seriesa:
                return UIColor(red: 0.322, green: 0.459, blue: 0.984, alpha: alphaIndex)
            case .europaleague:
                return UIColor(red: 0.502, green: 0.290, blue: 0.984, alpha: alphaIndex)
            case .championleague:
                return UIColor(red: 0.988, green: 0.271, blue: 0.282, alpha: alphaIndex)
            case .laliga:
                return UIColor(red: 0.620, green: 0.776, blue: 0.153, alpha: alphaIndex)
            case .mnl:
                return UIColor(red: 0.322, green: 0.776, blue: 0.153, alpha: alphaIndex)
            case .other:
                return UIColor(red: 0.322, green: 0.639, blue: 0.153, alpha: alphaIndex)
            }
        }
    }
    
    let title: String
    let category: NewsCategory
    let content: String
    let reference: String
    let imageUrl: String
    let publishedDate: String
    let timestamp: Int
}
