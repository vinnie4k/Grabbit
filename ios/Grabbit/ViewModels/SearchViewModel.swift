//
//  SearchViewModel.swift
//  Grabbit
//
//  Created by Vin Bui on 6/17/23.
//

import SwiftUI

extension SearchView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        // MARK: - Properties
        
        @Published var courses: [Course] = []
        @Published var isSearching: Bool = false
        @Published var searchText: String = ""
        
        // MARK: - Requests
        
        func searchCourse(text: String) async {
            isSearching = true
            
            let text = text.uppercased()
            let subject = filterSubject(from: text)
            let number = Int(filterNumber(from: text)) ?? 1000
                        
            let result = await NetworkManager.shared.searchCourse(subject: subject, number: number)
            switch result {
            case .success(let courses):
                self.courses = courses
                isSearching = false
            case .failure(let error):
                print("Error in SearchViewModel.searchCourse: \(error.localizedDescription)")
                isSearching = false
            }
        }
        
        // MARK: - Helpers
        
        /// Removes non-numeric characters from a string
        private func filterNumber(from text: String) -> String {
            return text.filter("0123456789".contains)
        }
        
        /// Removes numeric characters and spaces from a string
        private func filterSubject(from text: String) -> String {
            return text.filter("ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains)
        }
    }
    
}
