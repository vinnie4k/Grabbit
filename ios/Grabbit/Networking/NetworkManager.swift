//
//  NetworkManager.swift
//  Grabbit
//
//  Created by Vin Bui on 6/17/23.
//

import Alamofire
import SwiftUI

class NetworkManager: ObservableObject {
    
    // MARK: - Properties
    
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
        let urlString = Secrets.coursesEndpoint + "/search/"
        let parameters: Parameters = [
            "subject": subject,
            "number": number
        ]
        
        do {
            let value = try await AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(ResponseType.self).value
            
            switch value {
            case .courses(let courses):
                print("Successfully fetched \(courses.count) courses")
                return .success(courses)
            case .error(let error):
                print("Error in NetworkManager.searchCourse: \(error)")
                return .failure(CustomError.requestError(error))
            default:
                return .failure(CustomError.requestError("Invalid request"))
            }
        } catch {
            print("Error in NetworkManager.searchCourse: \(error)")
            return .failure(error)
        }
    }
    
    // MARK: - User Requests
    
    /**
     Removes a course to be untracked for a user
     
     - Parameters:
        - user: the user to remove the course from
        - trackedCourse: the course to untrack
     - Returns: the removed `TrackedCourse` if successful; otherwise `Error`
     */
    func untrackCourse(for user: User, with trackedCourse: TrackedCourse) async -> Result<TrackedCourse, Error> {
        let urlString = Secrets.userEndpoint + "/untrack/"
        let parameters: Parameters = [
            "course_id": trackedCourse.courseId,
            "course_title": trackedCourse.courseTitle,
            "device_id": user.deviceId,
            "number": trackedCourse.number,
            "pattern": trackedCourse.pattern,
            "section_id": trackedCourse.sectionId,
            "section_title": trackedCourse.sectionTitle,
            "status": trackedCourse.status.rawValue,
            "subject": trackedCourse.subject,
            "time_end": trackedCourse.timeEnd,
            "time_start": trackedCourse.timeStart,
            "user_id": user.id
        ]
        
        do {
            let value = try await AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(ResponseType.self).value
            
            switch value {
            case .trackedCourse(let course):
                print("Successfuly untracked \(trackedCourse.subject) \(trackedCourse.number) \(trackedCourse.sectionTitle) for user \(user.id)")
                return .success(course)
            case .error(let error):
                print("Error in NetworkManager.untrackCourse: \(error)")
                return .failure(CustomError.requestError(error))
            default:
                return .failure(CustomError.requestError("Invalid request"))
            }
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
     - Returns: the `TrackedCourse` if successful; otherwise `Error`
     */
    func trackCourse(for user: User, with trackedCourse: TrackedCourse) async -> Result<TrackedCourse, Error> {
        let urlString = Secrets.userEndpoint + "/track/"
        let parameters: Parameters = [
            "course_id": trackedCourse.courseId,
            "course_title": trackedCourse.courseTitle,
            "device_id": user.deviceId,
            "number": trackedCourse.number,
            "pattern": trackedCourse.pattern,
            "section_id": trackedCourse.sectionId,
            "section_title": trackedCourse.sectionTitle,
            "status": trackedCourse.status.rawValue,
            "subject": trackedCourse.subject,
            "time_end": trackedCourse.timeEnd,
            "time_start": trackedCourse.timeStart,
            "user_id": user.id
        ]
                
        do {
            let value = try await AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(ResponseType.self).value
            
            switch value {
            case .trackedCourse(let course):
                print("Successfuly tracked \(trackedCourse.subject) \(trackedCourse.number) \(trackedCourse.sectionTitle) for user \(user.id)")
                return .success(course)
            case .error(let error):
                print("Error in NetworkManager.trackCourse: \(error)")
                return .failure(CustomError.requestError(error))
            default:
                return .failure(CustomError.requestError("Invalid request"))
            }
        } catch {
            print("Error in NetworkManager.trackCourse: \(error)")
            return .failure(error)
        }
    }
    
    /**
     Updates the user's device ID
          
     - Parameters:
        - deviceId: the device ID to fetch and replace (FCM Token)
        - userId: the user ID to fetch
     - Returns: the fetched`User` if successful; otherwise `Error`
     */
    func updateDeviceToken(deviceId: String, userId: String) async -> Result<User, Error> {
        let urlString = Secrets.userEndpoint + "/token-update/"
        let parameters: Parameters = [
            "device_id": deviceId,
            "user_id": userId
        ]
        
        do {
            let value = try await AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(ResponseType.self).value
            
            switch value {
            case .user(let user):
                print("Successfully updated token \(deviceId) for user \(user.id)")
                UserDefaults.standard.set(deviceId, forKey: "deviceId")
                return .success(user)
            case .error(let error):
                print("Error in NetworkManager.updateDeviceToken: \(error)")
                return .failure(CustomError.requestError(error))
            default:
                return .failure(CustomError.requestError("Invalid request"))
            }
        } catch {
            print("Error in NetworkManager.updateDeviceToken: \(error)")
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
        let urlString = Secrets.userEndpoint + "/fetch/"
        let parameters: Parameters = [
            "device_id": deviceId,
            "email": email,
            "user_id": userId
        ]
        
        do {
            let value = try await AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(ResponseType.self).value
            
            switch value {
            case .user(let user):
                print("Successfully fetched user: \(user.id)")
                return .success(user)
            case .error(let error):
                print("Error in NetworkManager.fetchUser: \(error)")
                return .failure(CustomError.requestError(error))
            default:
                return .failure(CustomError.requestError("Invalid request"))
            }
        } catch {
            print("Error in NetworkManager.fetchUser: \(error)")
            return .failure(error)
        }
    }
    
}

extension NetworkManager {
    
    enum ResponseType: Decodable {
        
        case courses([Course])
        case error(String)
        case trackedCourse(TrackedCourse)
        case trackedCourses([TrackedCourse])
        case user(User)
        
        enum CodingKeys: String, CodingKey {
            case status
            case result
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let status = try container.decode(String.self, forKey: .status)

            switch status {
            case "success":
                if let value = try? container.decode(User.self, forKey: .result) {
                    self = .user(value)
                    return
                }
                
                if let value = try? container.decode([Course].self, forKey: .result) {
                    self = .courses(value)
                    return
                }
                
                if let value = try? container.decode(TrackedCourse.self, forKey: .result) {
                    self = .trackedCourse(value)
                    return
                }
                
                if let value = try? container.decode([TrackedCourse].self, forKey: .result) {
                    self = .trackedCourses(value)
                    return
                }
                
                throw DecodingError.typeMismatch(ResponseType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Type is not matched", underlyingError: nil))
            case "error":
                let errorString = try container.decode(String.self, forKey: .result)
                self = .error(errorString)
            default:
                fatalError("Unknown status received")
            }
        }
    }
    
}

enum CustomError: Error {
    case authError
    case requestError(String)
}
