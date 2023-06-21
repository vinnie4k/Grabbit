//
//  TrackingViewModel.swift
//  Grabbit
//
//  Created by Vin Bui on 6/18/23.
//

import SwiftUI

class TrackingViewModel: ObservableObject {
        
    // MARK: - Requests
    
    /// Returns `True` if successful tracked the course; `False` otherwise
    func trackCourse(for user: User, with course: TrackedCourse) async -> Bool {
        let result = await NetworkManager.shared.trackCourse(for: user, with: course)
        
        switch result {
        case .success(_):
            return true
        case .failure(let error):
            print("Error in TrackingViewModel.trackCourse: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Returns `True` if successful untracked the course; `False` otherwise
    func untrackCourse(for user: User, with course: TrackedCourse) async -> Bool {
        let result = await NetworkManager.shared.untrackCourse(for: user, with: course)
        
        switch result {
        case .success(_):
            return true
        case .failure(let error):
            print("Error in TrackingViewModel.untrackCourse: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Returns `True` if refresh successful; `False` otherwise
    func refreshUser(mainUser: User) async -> Bool {
        let result = await NetworkManager.shared.fetchUser(deviceId: mainUser.deviceId, email: mainUser.email, userId: mainUser.id)
        
        switch result {
        case .success(let user):
            
            DispatchQueue.main.async {
                mainUser.id = user.id
                mainUser.deviceId = user.deviceId
                mainUser.email = user.email
                mainUser.tracking = user.tracking
            }
            
            print("Successfully refreshed user information")
            return true
        case .failure(let error):
            print("Error in TrackingViewModel.refreshUser: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Helpers
    
    /// Convert a `Course` and `CourseSection` to a `TrackedCourse`
    func convertCourseToTrackedCourse(course: Course, section: CourseSection) -> TrackedCourse {
        return TrackedCourse(
            courseId: course.id,
            courseTitle: course.title,
            number: Int(course.number) ?? 0,
            pattern: section.pattern,
            sectionId: section.id,
            sectionTitle: (section.type + " " + section.section),
            status: section.status,
            subject: course.subject,
            timeEnd: section.timeEnd,
            timeStart: section.timeStart
        )
    }
    
}
