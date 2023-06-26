//
//  AnalyticsViewModel.swift
//  Grabbit
//
//  Created by Vin Bui on 6/21/23.
//

import FirebaseAnalytics

class AnalyticsManager {
    
    // MARK: - Properties
    
    static let shared = AnalyticsManager()
    
    func logEvent(_ name: GrabbitEvent) {
        Analytics.logEvent(name.rawValue, parameters: nil)
    }
    
}

enum GrabbitEvent: String {
    
    /// Untracks a course in the "Closed" section of the home page
    case untrackClosedHome = "untrack_closed_home"
    
    /// Untracks a course in the "Open" section of the home page
    case untrackOpenHome = "untrack_open_home"
    
    /// Copies the code for a course in the home page
    case copyCode = "copy_code"
    
    /// Taps on the "Enroll" button
    case tapEnroll = "tap_enroll"
    
    /// Taps on the search bar on the home page
    case tapSearchBar = "tap_search_bar"
    
    /// Taps on a search result
    case tapSearchResults = "tap_search_results"
    
    /// Taps on the settings button to open the Settings page
    case tapSettings = "tap_settings"
    
    /// Tracks a course in the detailed course view
    case trackDetail = "track_detail"
    
    /// Untracks a course in the detailed course view
    case untrackDetail = "untrack_detail"
    
}
