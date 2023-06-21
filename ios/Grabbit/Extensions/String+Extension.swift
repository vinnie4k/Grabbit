//
//  String+Extension.swift
//  Grabbit
//
//  Created by Vin Bui on 6/17/23.
//

import Foundation

extension String {
    
    func formatStartDate() -> String {
        let newString = self.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
        return String(newString.dropLast(2))
    }
    
    func formatEndDate() -> String {
        return self.replacingOccurrences(of: "^0+", with: "", options: .regularExpression).lowercased()
    }
    
}
