//
//  Date.swift
//  Githubsearch
//
//  Created by David Vallas on 3/19/18.
//  Copyright © 2018 David Vallas. All rights reserved.
//

import Foundation

extension Date {
    var simpleDate: String {
        let local = Locale(identifier: "en-US")
        let usDateFormat = DateFormatter.dateFormat(fromTemplate: "MMddyyyy", options: 0, locale: local)
        let formatter = DateFormatter()
        formatter.dateFormat = usDateFormat
        return formatter.string(from: self)
    }
}
