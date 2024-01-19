//
//  User.swift
//  Grabbit
//
//  Created by Vin Bui on 6/16/23.
//

import Foundation

class User: Decodable, ObservableObject {
    
    @Published var id: String
    @Published var deviceId: String
    @Published var email: String
    @Published var hasLimit: Bool
    @Published var tracking: [TrackedCourse]
    
    static let mainUser = User(id: "", deviceId: "", email: "", hasLimit: true, tracking: [])

    // Default initializer
    init(id: String, deviceId: String, email: String, hasLimit: Bool, tracking: [TrackedCourse]) {
        self.id = id
        self.deviceId = deviceId
        self.email = email
        self.hasLimit = hasLimit
        self.tracking = tracking
    }
    
    // Codable
    enum CodingKeys: CodingKey {
        case id, device_id, email, has_limit, tracking
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.deviceId = try container.decode(String.self, forKey: .device_id)
        self.email = try container.decode(String.self, forKey: .email)
        self.hasLimit = try container.decodeIfPresent(Bool.self, forKey: .has_limit) ?? true
        self.tracking = try container.decode([TrackedCourse].self, forKey: .tracking)
    }
    
    // MARK: - Helpers
    
    func getClosedCourses() -> [TrackedCourse] {
        return self.tracking.filter { $0.status != .open }
    }
    
    func getOpenCourses() -> [TrackedCourse] {
        return self.tracking.filter { $0.status == .open }
    }
    
}

struct TrackedCourse: Decodable, Hashable {
    
    let courseId: Int
    let courseTitle: String
    let number: Int
    let pattern: String
    let sectionId: Int
    let sectionTitle: String
    let status: Status
    let subject: String
    let timeEnd: String
    let timeStart: String
    
    // Default initializer
    init(courseId: Int, courseTitle: String, number: Int, pattern: String, sectionId: Int, sectionTitle: String, status: Status, subject: String, timeEnd: String, timeStart: String) {
        self.courseId = courseId
        self.courseTitle = courseTitle
        self.number = number
        self.pattern = pattern
        self.sectionId = sectionId
        self.sectionTitle = sectionTitle
        self.status = status
        self.subject = subject
        self.timeEnd = timeEnd
        self.timeStart = timeStart
    }
    
    // Codable
    enum CodingKeys: CodingKey {
        case course_id, course_title, number, pattern, section_id, section_title, status, subject, time_end, time_start
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.courseId = try container.decode(Int.self, forKey: .course_id)
        self.courseTitle = try container.decode(String.self, forKey: .course_title)
        self.number = try container.decode(Int.self, forKey: .number)
        self.pattern = try container.decode(String.self, forKey: .pattern)
        self.sectionId = try container.decode(Int.self, forKey: .section_id)
        self.sectionTitle = try container.decode(String.self, forKey: .section_title)
        self.status = try container.decode(Status.self, forKey: .status)
        self.subject = try container.decode(String.self, forKey: .subject)
        self.timeEnd = try container.decode(String.self, forKey: .time_end)
        self.timeStart = try container.decode(String.self, forKey: .time_start)
    }
    
}
