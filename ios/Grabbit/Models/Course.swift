//
//  Course.swift
//  Grabbit
//
//  Created by Vin Bui on 6/16/23.
//

import Foundation

struct Course: Codable, Hashable {
    
    let id: Int
    let number: String
    let sections: [CourseSection]
    let subject: String
    let title: String
    
}

struct CourseSection: Codable, Hashable {
    
    let id: Int
    let pattern: String
    let section: String
    let status: Status
    let timeEnd: String
    let timeStart: String
    let type: String
    
}

enum ConfirmationStatus {
    case none, cancel, confirm
}
