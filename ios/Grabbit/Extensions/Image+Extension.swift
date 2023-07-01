//
//  Image+Extension.swift
//  Grabbit
//
//  Created by Vin Bui on 6/17/23.
//

import SwiftUI

extension Image {
    
    static let grabbit = Grabbit()
    
    struct Grabbit {
        let bell = Image(systemName: "bell.fill")
        let checkmark = Image(systemName: "checkmark")
        let chevronLeft = Image(systemName: "chevron.left")
        let chevronRight = Image(systemName: "chevron.right")
        let copy = Image("copy")
        let delete = Image(systemName: "minus.circle")
        let error = Image("error")
        let eyeSlash = Image(systemName: "eye.slash.fill")
        let flag = Image(systemName: "flag")
        let info = Image(systemName: "info.circle")
        let logo = Image("logo")
        let logout = Image("logout")
        let magnifyingGlass = Image(systemName: "magnifyingglass")
        let settings = Image("settings")
        let unlock = Image(systemName: "lock.open.fill")
        let xmark = Image(systemName: "xmark")
    }
    
}
