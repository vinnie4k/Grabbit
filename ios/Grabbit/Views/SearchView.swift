//
//  SearchView.swift
//  Grabbit
//
//  Created by Vin Bui on 6/17/23.
//

import SwiftUI

struct SearchView: View {
    
    // MARK: - Properties
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject private var viewModel: ViewModel = ViewModel()
    @State private var workItem: DispatchWorkItem?
    
    // MARK: - Constants
    
    private struct Constants {
        static let sidePadding: CGFloat = 24
    }
    
    // MARK: - UI
    
    var body: some View {
        VStack(spacing: 16) {
            navBar
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 16, pinnedViews: [.sectionHeaders]) {
                    searchResultsSection
                }
            }
        }
        .padding(.horizontal, Constants.sidePadding)
        .setBackground()
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.searchText) { text in
            workItem?.cancel() // Cancel work item
            
            if text.count > 3 {
                let workItem = DispatchWorkItem {
                    Task {
                        await viewModel.searchCourse(text: text)
                    }
                }
                // Wait 0.5 seconds before executing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
                self.workItem = workItem
            } else {
                viewModel.courses = []
            }
        }
    }
    
    private var navBar: some View {
        HStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Image.grabbit.chevronLeft
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.grabbit.offWhite)
                    .frame(width: 16, height: 16)
            }
            
            SearchBar(text: $viewModel.searchText)
                .padding(.leading, 24)
        }
    }
    
    private var searchResultsSection: some View {
        Section {
            if viewModel.searchText.count < 3 {
                VStack(alignment: .center, spacing: 16) {
                    Image.grabbit.error
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                    
                    Text("3 characters needed")
                        .font(.sfProRounded(size: 20, weight: .semibold))
                        .foregroundColor(Color.grabbit.offWhite)
                }
                .frame(maxWidth: .infinity)
            } else {
                if viewModel.isSearching {
                    LoadingAnimation(text: "Searching...")
                        .frame(maxWidth: .infinity)
                } else {
                    ForEach(viewModel.courses, id: \.self) { course in
                        courseCell(for: course)
                    }
                }
            }
        } header: {
            resultsHeader
        }
    }
    
    private var resultsHeader: some View {
        Text("^[\(viewModel.courses.count) results](inflect: true)")
            .font(.sfProRounded(size: 24, weight: .semibold))
            .foregroundColor(Color.grabbit.offWhite)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.grabbit.background)
    }
    
    private func courseCell(for course: Course) -> some View {
        NavigationLink {
            CourseDetailView(course: course)
        } label: {
            ZStack {
                Color.grabbit.primary
                
                HStack {
                    Text("\(course.subject) \(course.number): \(course.title)")
                        .font(.sfProRounded(size: 16, weight: .semibold))
                        .foregroundColor(Color.grabbit.offWhite)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image.grabbit.chevronRight
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.grabbit.offWhite)
                        .frame(width: 12, height: 12)
                }
                .padding(20)
            }
            .cornerRadius(12)
        }
    }
}

//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView()
//    }
//}
