//
//  Optional.swift
//  Githubsearch
//
//  Created by David Vallas on 3/19/18.
//  Copyright © 2018 David Vallas. All rights reserved.
//

import Foundation

extension Optional {
    
    var array: [AnyObject] {
        if let array = self as? [AnyObject] { return array }
        print("Error: unable to unwrap \(String(describing: self)) as array, returning []")
        return []
    }
    
    var dict: [String : AnyObject] {
        if let dict = self as? [String: AnyObject] { return dict }
        print("Error: unable to unwrap \(String(describing: self)) as dict, returning [:]")
        return [:]
    }
    
    var string: String {
        if let string = self as? String { return string }
        print("Error: unable to unwrap \(String(describing: self)) as string, returning ''")
        return ""
    }
    
    var int: Int {
        if let string = self as? Int { return string }
        print("Error: unable to unwrap \(String(describing: self)) as string, returning 0")
        return 0
    }
    
    var stringLanguage: String {
        if let string = self as? String {
            if string == "" {
                return "Unknown"
            }
            return string
        }
        return "Unknown"
    }
    
    var stringDescription: String {
        if let string = self as? String {
            if string == "" {
                return "No description provided."
            }
            return string
        }
        return "No description provided."
    }
    
    var date: Date {
        if let date = self as? Date { return date }
        if let string = self as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = formatter.date(from: string) {
                return date
            } else {
                print("Error: unable to unwrap \(String(describing: self)) - could not be parsed - as date, returning now")
                return Date()
            }
        }
        print("Error: unable to unwrap \(String(describing: self)) as date, returning now")
        return Date()
    }
    
    
}
