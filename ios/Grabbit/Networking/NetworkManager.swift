//
//  NetworkManager.swift
//  Grabbit
//
//  Created by Vin Bui on 6/17/23.
//

import Alamofire
import SwiftUI

class NetworkManager: ObservableObject {

    private init() {}

    // MARK: - Properties

    /// Shared singleton instance of `NetworkManager`
    static let shared = NetworkManager()

    // MARK: - Course Requests

    /**
     Search for a course in the Class Roster

     - Parameters:
        - subject: the subject to fetch (e.g. "MATH")
        - number: the course number (e.g. 1920)
     - Returns: a list of `Course` objects if successful; otherwise `Error`
     */
    func searchCourse(subject: String, number: Int) async -> Result<[Course], Error> {
        let urlString = Secrets.apiEndpoint + "/search"
        let parameters: Parameters = [
            "subject": subject,
            "number": number
        ]

        do {
            let value = try await AF.request(
                urlString,
                method: .get,
                parameters: parameters,
                encoding: URLEncoding.queryString
            ).serializingDecodable([Course].self).value
            return .success(value)
        } catch {
            print("Error in NetworkManager.searchCourse: \(error)")
            return .failure(error)
        }
    }

    // MARK: - User Requests

    /**
     Delete a user account

     - Parameters:
        - userId: the ID of the user account to delete

     - Returns: `true` if successful; otherwise `Error`
     */
    func deleteAccount(for user: User) async -> Result<Bool, Error> {
        let urlString = Secrets.apiEndpoint + "/users/delete/\(user.id)"

        do {
            try await AF.request(
                urlString,
                method: .delete
            ).serializingData().value
            return .success(true)
        } catch {
            print("Error in NetworkManager.deleteAccount: \(error)")
            return .failure(error)
        }
    }

    /**
     Removes a course to be untracked for a user

     - Parameters:
        - user: the user to remove the course from
        - trackedCourse: the course to untrack

     - Returns: `true` if successful; otherwise `Error`
     */
    func untrackCourse(for user: User, with trackedCourse: TrackedCourse) async -> Result<Bool, Error> {
        let urlString = Secrets.apiEndpoint + "/users/untrack/\(user.id)"
        let parameters: Parameters = [
            "sectionId": trackedCourse.sectionId
        ]

        do {
            try await AF.request(
                urlString,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default
            ).serializingData().value
            return .success(true)
        } catch {
            print("Error in NetworkManager.untrackCourse: \(error)")
            return .failure(error)
        }
    }

    /**
     Adds a course to be tracked for a user

     - Parameters:
        - user: the user to add the course to
        - trackedCourse: the course to track

     - Returns: `true` if successful; otherwise `Error`
     */
    func trackCourse(for user: User, with trackedCourse: TrackedCourse) async -> Result<Bool, Error> {
        let urlString = Secrets.apiEndpoint + "/users/track/\(user.id)"
        let parameters: Parameters = [
            "courseId": trackedCourse.courseId,
            "courseTitle": trackedCourse.courseTitle,
            "number": trackedCourse.number,
            "pattern": trackedCourse.pattern,
            "sectionId": trackedCourse.sectionId,
            "sectionTitle": trackedCourse.sectionTitle,
            "status": trackedCourse.status.rawValue,
            "subject": trackedCourse.subject,
            "timeEnd": trackedCourse.timeEnd,
            "timeStart": trackedCourse.timeStart
        ]

        do {
            let value = try await AF.request(
                urlString,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default
            ).serializingData().value
            return .success(true)
        } catch {
            print("Error in NetworkManager.trackCourse: \(error)")
            return .failure(error)
        }
    }

    /**
     Fetch a user given a user ID and device ID, updating the device ID if outdated

     If the user does not exist, a new user is created and returned

     - Parameters:
        - deviceId: the device ID to fetch and replace (FCM Token)
        - userId: the user ID to fetch

     - Returns: the fetched`User` if successful; otherwise `Error`
     */
    func fetchUser(deviceId: String, email: String, userId: String) async -> Result<User, Error> {
        let urlString = Secrets.apiEndpoint + "/users/fetch/\(userId)"
        let parameters: Parameters = [
            "deviceId": deviceId,
            "email": email
        ]

        do {
            let value = try await AF.request(
                urlString,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default
            ).serializingDecodable(User.self).value
            return .success(value)
        } catch {
            print("Error in NetworkManager.fetchUser: \(error)")
            return .failure(error)
        }
    }

}

enum CustomError: Error {
    case authError
    case requestError(String)
}
