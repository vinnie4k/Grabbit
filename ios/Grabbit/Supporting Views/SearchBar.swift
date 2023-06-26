//
//  SearchBar.swift
//  Grabbit
//
//  Created by Vin Bui on 6/17/23.
//

import SwiftUI

struct SearchBar: View {
    
    // MARK: - Properties
    
    @FocusState var focusedField: FocusedField?
    @Binding var text: String
    
    // MARK: - UI
 
    var body: some View {
        HStack {
            Image.grabbit.magnifyingGlass
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.grabbit.silver)
                .frame(width: 16, height: 16)
            
            TextField("Search course (ex. CS 2800)", text: $text)
                .font(.sfProRounded(size: 16, weight: .medium))
                .foregroundColor(Color.grabbit.offWhite)
                .tint(Color.grabbit.offWhite)
                .padding(.leading, 8)
                .focused($focusedField, equals: .searchBar)
        }
        .frame(height: 40)
        .padding(.horizontal, 16)
        .background(Color.grabbit.primary)
        .cornerRadius(8)
        .onAppear {
            focusedField = .searchBar
        }
    }
}

enum FocusedField {
    case searchBar
}

//struct SearchBar_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchBar(submittedText: .constant(""), text: .constant(""))
//    }
//}
