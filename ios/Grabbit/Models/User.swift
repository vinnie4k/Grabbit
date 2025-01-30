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
        case id, deviceId, email, hasLimit, tracking
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.deviceId = try container.decode(String.self, forKey: .deviceId)
        self.email = try container.decode(String.self, forKey: .email)
        self.hasLimit = try container.decodeIfPresent(Bool.self, forKey: .hasLimit) ?? true
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
    
}
