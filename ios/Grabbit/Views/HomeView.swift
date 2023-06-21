//
//  HomeView.swift
//  Grabbit
//
//  Created by Vin Bui on 6/17/23.
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    @EnvironmentObject private var mainUser: User
    @EnvironmentObject private var trackingViewModel: TrackingViewModel
    
    @State private var isFetching: Bool = true
    @State private var showConfirmation: Bool = false
    @State private var clipboardPopup: Bool = false
    @State private var trackedCourse: TrackedCourse? = nil
    @State private var confirmationStatus: ConfirmationStatus = .none
    @State private var removedPopup: Bool = false
    
    @Environment(\.openURL) var openURL
    
    // MARK: - Constants
    
    private struct Constants {
        static let openCellSize: CGSize = CGSize(width: 296, height: 212)
        static let sidePadding: CGFloat = 24
        static let spacing: CGFloat = 24
    }
    
    // MARK: - UI
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Constants.spacing) {
                header
                
                homeSearchBar
                
                if isFetching {
                    LoadingAnimation(text: "Fetching your courses...")
                        .padding(.top, 32)
                } else {
                    if mainUser.getOpenCourses().isEmpty && mainUser.getClosedCourses().isEmpty {
                        completeEmptyState
                    } else if mainUser.getClosedCourses().isEmpty {
                        openSection
                        halfEmptyState
                    } else if mainUser.getOpenCourses().isEmpty {
                        closedSection
                    } else {
                        openSection
                        closedSection
                    }
                }
            }
        }
        .setBackground()
        .refreshable {
            Task {
                await trackingViewModel.refreshUser(mainUser: mainUser)
            }
        }
        .onChange(of: mainUser.id) { _ in
            isFetching = false
        }
        .onChange(of: confirmationStatus) { status in
            showConfirmation = false
            confirmationStatus = .none
            
            switch status {
            case .confirm:
                if let trackedCourse = trackedCourse {
                    removeCourse(with: trackedCourse)
                }
            default:
                break
            }
        }
        .popup(showPopup: clipboardPopup, image: Image.grabbit.checkmark, imageColor: Color.grabbit.success, text: "Copied to clipboard")
        .popup(showPopup: removedPopup, image: Image.grabbit.checkmark, imageColor: Color.grabbit.success, text: "Removed")
        .showConfirmation(
            action: "Remove",
            heading: "Untrack course?",
            subheading: "\(trackedCourse?.subject ?? "") \(String(trackedCourse?.number ?? 0)) \(trackedCourse?.sectionTitle ?? "")",
            showConfirmation: showConfirmation,
            confirmationStatus: $confirmationStatus
        )
    }
    
    private var header: some View {
        HStack(alignment: .center) {
            Text("grabbit")
                .font(.spartanLight(size: 40))
                .foregroundColor(Color.grabbit.offWhite)
            
            Spacer()
            
            NavigationLink {
                SettingsView()
            } label: {
                Image.grabbit.settings
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.top)
        .padding(.horizontal, Constants.sidePadding)
    }
    
    private var homeSearchBar: some View {
        NavigationLink {
            SearchView()
        } label: {
            HStack {
                Image.grabbit.magnifyingGlass
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.grabbit.silver)
                    .frame(width: 16, height: 16)
                
                Text("Search for a course")
                    .font(.sfProRounded(size: 16, weight: .medium))
                    .foregroundColor(Color.grabbit.silver)
                    .padding(.leading, 8)
                
                Spacer()
            }
            .frame(height: 40)
            .padding(.horizontal, 16)
            .background(Color.grabbit.primary)
            .cornerRadius(8)
        }
        .padding(.horizontal, Constants.sidePadding)
    }
    
    private var openSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(mainUser.getOpenCourses().count) open")
                .font(.sfProRounded(size: 24, weight: .semibold))
                .foregroundColor(Color.grabbit.offWhite)
                .padding(.leading, Constants.sidePadding)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(mainUser.getOpenCourses(), id: \.self) { course in
                        openCell(with: course)
                    }
                }
                .padding(.horizontal, Constants.sidePadding)
            }
        }
    }
    
    private func openCell(with course: TrackedCourse) -> some View {
        ZStack {
            Color.grabbit.primary
            
            VStack(alignment: .leading, spacing: 16) {
                cellStatusRow(with: course)
                
                cellTitle(with: course, isOpen: true)
                
                cellDates(with: course)
                                
                enrollButton
            }
            .padding(.horizontal, 20)
        }
        .frame(width: Constants.openCellSize.width, height: Constants.openCellSize.height)
        .cornerRadius(12)
        .animation(.default)
    }
    
    private var closedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(mainUser.getClosedCourses().count) closed")
                .font(.sfProRounded(size: 24, weight: .semibold))
                .foregroundColor(Color.grabbit.offWhite)
            
            ForEach(mainUser.getClosedCourses(), id: \.self) { course in
                closedCell(with: course)
            }
        }
        .padding(.horizontal, Constants.sidePadding)
    }
    
    private func closedCell(with course: TrackedCourse) -> some View {
        ZStack {
            Color.grabbit.primary
            
            VStack(alignment: .leading, spacing: 16) {
                cellStatusRow(with: course)
                
                cellTitle(with: course, isOpen: false)
                
                cellDates(with: course)
            }
            .padding(20)
        }
        .cornerRadius(12)
        .animation(.default)
    }
    
    private func cellStatusRow(with course: TrackedCourse) -> some View {
        HStack(alignment: .center) {
            StatusDots(status: course.status)
                .padding(.trailing, 12)
            
            SectionTitlePill(sectionTitle: course.sectionTitle)
            
            Spacer()
            
            Button {
                Haptics.shared.play(.light)
                showConfirmation.toggle()
                trackedCourse = course
            } label: {
                Image.grabbit.xmark
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color.grabbit.offWhite)
            }
        }
    }
    
    private func cellTitle(with course: TrackedCourse, isOpen: Bool) -> some View {
        Text("\(course.subject) \(String(course.number)): \(course.courseTitle)")
            .font(.sfProRounded(size: 18, weight: .semibold))
            .foregroundColor(Color.grabbit.offWhite)
            .multilineTextAlignment(.leading)
            .frame(height: isOpen ? 48 : nil)
    }
    
    private func cellDates(with course: TrackedCourse) -> some View {
        HStack(alignment: .center) {
            Group {
                Text(course.pattern)
                
                Text("\(course.timeStart.formatStartDate())-\(course.timeEnd.formatEndDate())")
            }
            .font(.sfProRounded(size: 14, weight: .regular))
            .foregroundColor(Color.grabbit.silver)
            
            Spacer()
            
            copyButton(with: String(course.sectionId))
        }
    }
    
    private func copyButton(with code: String) -> some View {
        Button {
            Haptics.shared.play(.light)
            UIPasteboard.general.setValue(code, forPasteboardType: "public.plain-text")
            
            clipboardPopup.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                clipboardPopup.toggle()
            }
        } label: {
            Label(code, image: "copy")
            .font(.sfProRounded(size: 12, weight: .bold))
            .foregroundColor(Color.grabbit.offWhite)
            .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.grabbit.offWhite)
            )
        }
        .frame(height: 30)
    }
    
    private var enrollButton: some View {
        Button {
            if let url = URL(string: Secrets.studentCenterLink) {
                openURL(url)
            }
        } label: {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.grabbit.success)
                .overlay(
                    Text("ENROLL")
                        .font(.sfProRounded(size: 12, weight: .bold))
                        .foregroundColor(Color.grabbit.primary)
                )
        }
        .frame(height: 30)
    }
    
    // MARK: - Empty States
    
    private var completeEmptyState: some View {
        VStack {
            Image.grabbit.eyeSlash
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.grabbit.offWhite)
                .frame(width: 80, height: 80)
                .padding(.bottom, 8)
            
            Text("No tracked courses")
                .font(.sfProRounded(size: 20, weight: .semibold))
                .foregroundColor(Color.grabbit.offWhite)
                .padding(.bottom, 4)
            
            Text("Search for a course to start tracking")
                .font(.sfProRounded(size: 14, weight: .regular))
                .foregroundColor(Color.grabbit.silver)
        }
        .padding(.top, 64)
    }
    
    private var halfEmptyState: some View {
        VStack {
            Image.grabbit.unlock
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.grabbit.offWhite)
                .frame(width: 80, height: 80)
                .padding(.bottom, 8)
            
            Text("Your tracked courses are open")
                .font(.sfProRounded(size: 20, weight: .semibold))
                .foregroundColor(Color.grabbit.offWhite)
                .padding(.bottom, 4)
            
            Text("Quick! Click on the Enroll button above.")
                .font(.sfProRounded(size: 14, weight: .regular))
                .foregroundColor(Color.grabbit.silver)
        }
        .padding(.top, 32)
    }
    
    // MARK: - Helpers
    
    private func removeCourse(with trackedCourse: TrackedCourse) {
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
    }
    
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
