//
//  SectionTitlePill.swift
//  Grabbit
//
//  Created by Vin Bui on 6/17/23.
//

import SwiftUI

struct SectionTitlePill: View {
    
    // MARK: - Properties
    
    let sectionTitle: String
    
    // MARK: - UI
    
    var body: some View {
        Text(sectionTitle)
            .font(.sfProRounded(size: 12, weight: .semibold))
            .foregroundColor(Color.grabbit.offWhite)
            .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .background(Color.grabbit.shadow)
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

