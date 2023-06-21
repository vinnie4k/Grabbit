//
//  Color+Extension.swift
//  Grabbit
//
//  Created by Vin Bui on 6/16/23.
//

import SwiftUI

extension Color {
    
    static let grabbit = Grabbit()
    
    struct Grabbit {
        let background = Color(red: 27/255, green: 27/255, blue: 27/255)
        let error = Color(red: 206/255, green: 66/255, blue: 87/255)
        let offWhite = Color(red: 245/255, green: 245/255, blue: 245/255)
        let primary = Color(red: 49/255, green: 49/255, blue: 49/255)
        let shadow = Color(red: 74/255, green: 74/255, blue: 74/255)
        let silver = Color(red: 191/255, green: 191/255, blue: 191/255)
        let success = Color(red: 116/255, green: 198/255, blue: 157/255)
        let warning = Color(red: 255/255, green: 217/255, blue: 61/255)
        let white = Color.white
    }
    
}
