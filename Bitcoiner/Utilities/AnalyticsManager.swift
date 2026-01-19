//
//  AnalyticsManager.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import Foundation
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

/// Analytics event names for the app
enum AnalyticsEvent: String {
    // Screen views
    case screenView = "screen_view"
    
    // Dashboard events
    case dashboardRefresh = "dashboard_refresh"
    case priceCardTapped = "price_card_tapped"
    case fearGreedTapped = "fear_greed_tapped"
    
    // Market data events
    case marketDataViewed = "market_data_viewed"
    case miningDataViewed = "mining_data_viewed"
    case assetComparisonViewed = "asset_comparison_viewed"
    
    // Position events
    case positionAdded = "position_added"
    case positionUpdated = "position_updated"
    case positionDeleted = "position_deleted"
    
    // Learn events
    case learnSectionViewed = "learn_section_viewed"
    case selfCustodyGuideViewed = "self_custody_guide_viewed"
    case selfCustodySectionExpanded = "self_custody_section_expanded"
    case bookListViewed = "book_list_viewed"
    case youtuberListViewed = "youtuber_list_viewed"
    case walletListViewed = "wallet_list_viewed"
    case securityChecklistViewed = "security_checklist_viewed"
    case principlesViewed = "principles_viewed"
    
    // Settings events
    case languageChanged = "language_changed"
    case settingsViewed = "settings_viewed"
    
    // External links
    case externalLinkTapped = "external_link_tapped"
}

/// Analytics parameter keys
enum AnalyticsParam: String {
    case screenName = "screen_name"
    case screenClass = "screen_class"
    case sectionId = "section_id"
    case sectionTitle = "section_title"
    case language = "language"
    case linkUrl = "link_url"
    case linkType = "link_type"
    case assetName = "asset_name"
    case amount = "amount"
    case price = "price"
    case category = "category"
}

/// Centralized analytics manager for Firebase Analytics
final class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // MARK: - Screen Tracking
    
    /// Log screen view event
    func logScreenView(screenName: String, screenClass: String? = nil) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass ?? screenName
        ])
        #endif
        
        #if DEBUG
        print("📊 Analytics: Screen View - \(screenName)")
        #endif
    }
    
    // MARK: - Custom Events
    
    /// Log custom event with optional parameters
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(event.rawValue, parameters: parameters)
        #endif
        
        #if DEBUG
        print("📊 Analytics: \(event.rawValue) - \(parameters ?? [:])")
        #endif
    }
    
    // MARK: - Convenience Methods
    
    /// Log dashboard refresh
    func logDashboardRefresh() {
        logEvent(.dashboardRefresh)
    }
    
    /// Log learn section viewed
    func logLearnSectionViewed(section: String) {
        logEvent(.learnSectionViewed, parameters: [
            AnalyticsParam.sectionId.rawValue: section
        ])
    }
    
    /// Log self custody section expanded
    func logSelfCustodySectionExpanded(sectionId: String, sectionTitle: String) {
        logEvent(.selfCustodySectionExpanded, parameters: [
            AnalyticsParam.sectionId.rawValue: sectionId,
            AnalyticsParam.sectionTitle.rawValue: sectionTitle
        ])
    }
    
    /// Log external link tapped
    func logExternalLinkTapped(url: String, type: String) {
        logEvent(.externalLinkTapped, parameters: [
            AnalyticsParam.linkUrl.rawValue: url,
            AnalyticsParam.linkType.rawValue: type
        ])
    }
    
    /// Log language change
    func logLanguageChanged(to language: String) {
        logEvent(.languageChanged, parameters: [
            AnalyticsParam.language.rawValue: language
        ])
    }
    
    /// Log position event
    func logPositionEvent(_ event: AnalyticsEvent, amount: Double? = nil, price: Double? = nil) {
        var params: [String: Any] = [:]
        if let amount = amount {
            params[AnalyticsParam.amount.rawValue] = amount
        }
        if let price = price {
            params[AnalyticsParam.price.rawValue] = price
        }
        logEvent(event, parameters: params.isEmpty ? nil : params)
    }
    
    // MARK: - User Properties
    
    /// Set user property
    func setUserProperty(_ value: String?, forName name: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.setUserProperty(value, forName: name)
        #endif
        
        #if DEBUG
        print("📊 Analytics: User Property - \(name): \(value ?? "nil")")
        #endif
    }
    
    /// Set preferred language
    func setPreferredLanguage(_ language: String) {
        setUserProperty(language, forName: "preferred_language")
    }
}
