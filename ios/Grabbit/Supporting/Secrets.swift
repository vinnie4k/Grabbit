//
//  Secrets.swift
//  Grabbit
//
//  Created by Vin Bui on 6/16/23.
//

import Foundation

struct Secrets {
    
    static let aboutLink = Secrets.keyDict["about-link"] as! String
    static let coursesEndpoint = Secrets.keyDict["courses-endpoint"] as! String
    static let feedbackForm = Secrets.keyDict["feedback-form"] as! String
    static let studentCenterLink = Secrets.keyDict["student-center-link"] as! String
    static let userEndpoint = Secrets.keyDict["user-endpoint"] as! String
    
    private static let keyDict: NSDictionary = {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path)
        else { return [:] }
        return dict
    }()
    
}
