//
//  CourseDetailView.swift
//  Grabbit
//
//  Created by Vin Bui on 6/17/23.
//

import SwiftUI

struct CourseDetailView: View {
    
    // MARK: - Properties
    
    let course: Course

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var addedPopup: Bool = false
    @State private var errorPopup: Bool = false
    @State private var removedPopup: Bool = false
    @State private var sectionInfo: [String: [CourseSection]] = [:]
    
    @EnvironmentObject private var mainUser: User
    @EnvironmentObject private var trackingViewModel: TrackingViewModel    
    
    // MARK: - Constants
    
    private struct Constants {
        static let cellHeight: CGFloat = 48
        static let sidePadding: CGFloat = 24
        static let trackingLimit: Int = 5
    }
    
    // MARK: - UI
    
    var body: some View {
        VStack {
            navBar

            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                    ForEach(Array(sectionInfo.keys.sorted {
                            sectionInfo[$0]?.count ?? 0 < sectionInfo[$1]?.count ?? 0
                        }), id: \.self) { key in
                        courseSection(title: key, sections: sectionInfo[key] ?? [])
                    }
                }
                .padding(.horizontal, Constants.sidePadding)
            }
        }
        .onAppear {
            sortSections()
        }
        .setBackground()
        .navigationBarBackButtonHidden(true)
        .popup(showPopup: addedPopup, image: Image.grabbit.checkmark, imageColor: Color.grabbit.success, text: "Added")
        .popup(showPopup: removedPopup, image: Image.grabbit.checkmark, imageColor: Color.grabbit.success, text: "Removed")
        .popup(showPopup: errorPopup, image: Image.grabbit.error, imageColor: Color.grabbit.error, text: "Max of 5 courses")
    }
    
    private var navBar: some View {
        ZStack {
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
                
                Spacer()
            }
                        
            Text("\(course.subject) \(course.number)")
                .font(.sfProRounded(size: 16, weight: .semibold))
                .foregroundColor(Color.grabbit.offWhite)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, Constants.sidePadding)
        .frame(height: 40)
    }
    
    private func courseSection(title: String, sections: [CourseSection]) -> some View {
        Section {
            VStack(spacing: 16) {
                ForEach(sections, id: \.self) { section in
                    sectionCell(for: section)
                }
            }
            .padding(.bottom, 24)
        } header: {
            Text(title)
                .font(.sfProRounded(size: 20, weight: .semibold))
                .foregroundColor(Color.grabbit.offWhite)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
                .background(Color.grabbit.background)
        }
    }
    
    private func sectionCell(for section: CourseSection) -> some View {
        ZStack {
            Color.grabbit.primary
            
            HStack(spacing: 16) {
                StatusDots(status: section.status)
                
                VStack(alignment:.leading, spacing: 4) {
                    Text("\(section.type) \(section.section)")
                        .font(.sfProRounded(size: 14, weight: .semibold))
                        .foregroundColor(Color.grabbit.offWhite)
                    
                    HStack(spacing: 8) {
                        Text(section.pattern)
                            .font(.sfProRounded(size: 14, weight: .regular))
                            .foregroundColor(Color.grabbit.silver)
                        
                        Text("\(section.timeStart.formatStartDate())-\(section.timeEnd.formatEndDate())")
                            .font(.sfProRounded(size: 14, weight: .regular))
                            .foregroundColor(Color.grabbit.silver)
                    }
                }
                
                Spacer()
                
                trackButton(section: section)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .cornerRadius(8)
    }
    
    @ViewBuilder
    private func trackButton(section: CourseSection) -> some View {
        let isTracking = mainUser.tracking.contains { $0.sectionId == section.id }
        let trackedCourse = trackingViewModel.convertCourseToTrackedCourse(course: course, section: section)
        
        Button {
            Haptics.shared.play(.light)
            toggleCourseTracking(trackedCourse: trackedCourse, isTracking: isTracking)
        } label: {
            Text(isTracking ? "UNTRACK" : "TRACK")
                .font(.sfProRounded(size: 12, weight: .semibold))
                .foregroundColor(Color.grabbit.offWhite)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.grabbit.offWhite)
                )
        }
        .frame(height: 30)
    }
    
    // MARK: - Helpers
    
    /// Track or untrack a given course
    private func toggleCourseTracking(trackedCourse: TrackedCourse, isTracking: Bool) {
        if isTracking {
            Task {
                let success = await trackingViewModel.untrackCourse(for: mainUser, with: trackedCourse)
                
                if success {
                    await trackingViewModel.refreshUser(mainUser: mainUser)
                    removedPopup.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        removedPopup.toggle()
                    }
                }
            }
            
            // Log analytics
            AnalyticsManager.shared.logEvent(.untrackDetail)
        } else {
            // User cannot have more than 5 courses
            if mainUser.tracking.count >= Constants.trackingLimit {
                errorPopup.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    errorPopup.toggle()
                }
            } else {
                Task {
                    let success = await trackingViewModel.trackCourse(for: mainUser, with: trackedCourse)
                    
                    if success {
                        await trackingViewModel.refreshUser(mainUser: mainUser)
                        addedPopup.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            addedPopup.toggle()
                        }
                    }
                }
            }
            
            // Log analytics
            AnalyticsManager.shared.logEvent(.trackDetail)
        }
    }
    
    /// Splits the course sections into different groupings
    private func sortSections() {
        course.sections.forEach { section in
            if sectionInfo.keys.contains(section.type) {
                // Already has a key
                sectionInfo[section.type]?.append(section)
            } else {
                // Does not have key
                sectionInfo[section.type] = [section]
            }
        }
    }
    
    /// Returns an `Array` of section groupings sorted by ascending order
//    private func sectionInfoArray() -> [Dictionary<String, [CourseSection]>] {
//        return Array(sectionInfo.keys.sorted {
//            sectionInfo[$0]?.count ?? 0 < sectionInfo[$1]?.count ?? 0
//        })
//    }
}

//struct CourseDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        CourseDetailView(course: Course(id: 1, number: "1920", sections: [CourseSection(id: 2, pattern: "MWF", section: "001", status: .closed, timeEnd: "09:55AM", timeStart: "09:05AM", type: "LEC")], subject: "MATH", title: ""))
//    }
//}
