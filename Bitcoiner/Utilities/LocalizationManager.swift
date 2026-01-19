//
//  LocalizationManager.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import SwiftUI
import Combine

// MARK: - Language Enum
enum AppLanguage: String, CaseIterable {
    case english = "en"
    case korean = "ko"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .korean: return "한국어"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .korean: return "🇰🇷"
        }
    }
}

// MARK: - Localization Manager
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @AppStorage("appLanguage") private var storedLanguage: String = AppLanguage.english.rawValue
    @Published var currentLanguage: AppLanguage = .english
    
    private var bundle: Bundle?
    
    private init() {
        currentLanguage = AppLanguage(rawValue: storedLanguage) ?? .english
        loadBundle()
    }
    
    func setLanguage(_ language: AppLanguage) {
        storedLanguage = language.rawValue
        currentLanguage = language
        loadBundle()
        objectWillChange.send()
    }
    
    private func loadBundle() {
        if let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
        } else {
            self.bundle = Bundle.main
        }
    }
    
    func localizedString(for key: String) -> String {
        bundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
}

// MARK: - Localization Keys
enum L10n {
    // MARK: - Tab Bar
    static var tabDashboard: String { LocalizationManager.shared.localizedString(for: "tab_dashboard") }
    static var tabMarket: String { LocalizationManager.shared.localizedString(for: "tab_market") }
    static var tabPositions: String { LocalizationManager.shared.localizedString(for: "tab_positions") }
    static var tabLearn: String { LocalizationManager.shared.localizedString(for: "tab_learn") }
    static var tabSettings: String { LocalizationManager.shared.localizedString(for: "tab_settings") }
    
    // MARK: - Dashboard
    static var dashboardTitle: String { LocalizationManager.shared.localizedString(for: "dashboard_title") }
    static var loadingData: String { LocalizationManager.shared.localizedString(for: "loading_data") }
    static var quickStats: String { LocalizationManager.shared.localizedString(for: "quick_stats") }
    static var circulatingSupply: String { LocalizationManager.shared.localizedString(for: "circulating_supply") }
    static var ofMaxSupply: String { LocalizationManager.shared.localizedString(for: "of_max_supply") }
    static var marketSentiment: String { LocalizationManager.shared.localizedString(for: "market_sentiment") }
    static var retry: String { LocalizationManager.shared.localizedString(for: "retry") }
    static var lastUpdated: String { LocalizationManager.shared.localizedString(for: "last_updated") }
    
    // MARK: - Fear & Greed
    static var fearGreedIndex: String { LocalizationManager.shared.localizedString(for: "fear_greed_index") }
    static var extremeFear: String { LocalizationManager.shared.localizedString(for: "extreme_fear") }
    static var fear: String { LocalizationManager.shared.localizedString(for: "fear") }
    static var neutral: String { LocalizationManager.shared.localizedString(for: "neutral") }
    static var greed: String { LocalizationManager.shared.localizedString(for: "greed") }
    static var extremeGreed: String { LocalizationManager.shared.localizedString(for: "extreme_greed") }
    
    // MARK: - Market Data
    static var marketTitle: String { LocalizationManager.shared.localizedString(for: "market_title") }
    static var miningData: String { LocalizationManager.shared.localizedString(for: "mining_data") }
    static var exchangeReserves: String { LocalizationManager.shared.localizedString(for: "exchange_reserves") }
    static var hashRate: String { LocalizationManager.shared.localizedString(for: "hash_rate") }
    static var difficulty: String { LocalizationManager.shared.localizedString(for: "difficulty") }
    static var blockHeight: String { LocalizationManager.shared.localizedString(for: "block_height") }
    static var miningCost: String { LocalizationManager.shared.localizedString(for: "mining_cost") }
    
    // MARK: - Positions
    static var positionsTitle: String { LocalizationManager.shared.localizedString(for: "positions_title") }
    static var longShortRatio: String { LocalizationManager.shared.localizedString(for: "long_short_ratio") }
    static var longPositions: String { LocalizationManager.shared.localizedString(for: "long_positions") }
    static var shortPositions: String { LocalizationManager.shared.localizedString(for: "short_positions") }
    
    // MARK: - Learn
    static var learnTitle: String { LocalizationManager.shared.localizedString(for: "learn_title") }
    static var selfCustodyGuide: String { LocalizationManager.shared.localizedString(for: "self_custody_guide") }
    static var selfCustodySubtitle: String { LocalizationManager.shared.localizedString(for: "self_custody_subtitle") }
    static var walletRecommendations: String { LocalizationManager.shared.localizedString(for: "wallet_recommendations") }
    static var walletSubtitle: String { LocalizationManager.shared.localizedString(for: "wallet_subtitle") }
    static var securityChecklist: String { LocalizationManager.shared.localizedString(for: "security_checklist") }
    static var securitySubtitle: String { LocalizationManager.shared.localizedString(for: "security_subtitle") }
    static var koreanMarketInfo: String { LocalizationManager.shared.localizedString(for: "korean_market_info") }
    static var koreanMarketSubtitle: String { LocalizationManager.shared.localizedString(for: "korean_market_subtitle") }
    static var bitcoinBooks: String { LocalizationManager.shared.localizedString(for: "bitcoin_books") }
    static var booksSubtitle: String { LocalizationManager.shared.localizedString(for: "books_subtitle") }
    static var youtubeChannels: String { LocalizationManager.shared.localizedString(for: "youtube_channels") }
    static var youtubeSubtitle: String { LocalizationManager.shared.localizedString(for: "youtube_subtitle") }
    static var bitcoinPrinciples: String { LocalizationManager.shared.localizedString(for: "bitcoin_principles") }
    static var bitcoinPrinciplesSubtitle: String { LocalizationManager.shared.localizedString(for: "bitcoin_principles_subtitle") }
    static var concepts: String { LocalizationManager.shared.localizedString(for: "concepts") }
    
    // MARK: - Bitcoin Principles View
    static var bpNavTitle: String { LocalizationManager.shared.localizedString(for: "bp_nav_title") }
    static var bpHeaderTitle: String { LocalizationManager.shared.localizedString(for: "bp_header_title") }
    static var bpHeaderSubtitle: String { LocalizationManager.shared.localizedString(for: "bp_header_subtitle") }
    
    // Section Titles
    static var bpSectionDecentralized: String { LocalizationManager.shared.localizedString(for: "bp_section_decentralized") }
    static var bpSectionBlockchain: String { LocalizationManager.shared.localizedString(for: "bp_section_blockchain") }
    static var bpSectionMining: String { LocalizationManager.shared.localizedString(for: "bp_section_mining") }
    static var bpSectionSupply: String { LocalizationManager.shared.localizedString(for: "bp_section_supply") }
    static var bpSectionP2p: String { LocalizationManager.shared.localizedString(for: "bp_section_p2p") }
    
    // Decentralized Network
    static var bpDecentralizedDesc: String { LocalizationManager.shared.localizedString(for: "bp_decentralized_desc") }
    
    // Blockchain
    static var bpPrevHash: String { LocalizationManager.shared.localizedString(for: "bp_prev_hash") }
    static var bpBlock: String { LocalizationManager.shared.localizedString(for: "bp_block") }
    static var bpBlockchainDesc: String { LocalizationManager.shared.localizedString(for: "bp_blockchain_desc") }
    
    // Mining
    static var bpMiners: String { LocalizationManager.shared.localizedString(for: "bp_miners") }
    static var bpSolvePuzzle: String { LocalizationManager.shared.localizedString(for: "bp_solve_puzzle") }
    static var bpNewBlock: String { LocalizationManager.shared.localizedString(for: "bp_new_block") }
    static var bpEarn: String { LocalizationManager.shared.localizedString(for: "bp_earn") }
    static var bpReward: String { LocalizationManager.shared.localizedString(for: "bp_reward") }
    static var bpBlockTime: String { LocalizationManager.shared.localizedString(for: "bp_block_time") }
    static var bpDifficulty: String { LocalizationManager.shared.localizedString(for: "bp_difficulty") }
    static var bpHalving: String { LocalizationManager.shared.localizedString(for: "bp_halving") }
    static var bpBlockTimeValue: String { LocalizationManager.shared.localizedString(for: "bp_block_time_value") }
    static var bpDifficultyValue: String { LocalizationManager.shared.localizedString(for: "bp_difficulty_value") }
    static var bpHalvingValue: String { LocalizationManager.shared.localizedString(for: "bp_halving_value") }
    static var bpMiningDesc: String { LocalizationManager.shared.localizedString(for: "bp_mining_desc") }
    
    // Supply
    static var bpMined: String { LocalizationManager.shared.localizedString(for: "bp_mined") }
    static var bpLeft: String { LocalizationManager.shared.localizedString(for: "bp_left") }
    static var bpMaxSupply: String { LocalizationManager.shared.localizedString(for: "bp_max_supply") }
    static var bpHalvingSchedule: String { LocalizationManager.shared.localizedString(for: "bp_halving_schedule") }
    static var bpSupplyDesc: String { LocalizationManager.shared.localizedString(for: "bp_supply_desc") }
    
    // P2P Transactions
    static var bpSender: String { LocalizationManager.shared.localizedString(for: "bp_sender") }
    static var bpReceiver: String { LocalizationManager.shared.localizedString(for: "bp_receiver") }
    static var bpSignedVerified: String { LocalizationManager.shared.localizedString(for: "bp_signed_verified") }
    static var bpPrivateKey: String { LocalizationManager.shared.localizedString(for: "bp_private_key") }
    static var bpPublicKey: String { LocalizationManager.shared.localizedString(for: "bp_public_key") }
    static var bpSecretNeverShare: String { LocalizationManager.shared.localizedString(for: "bp_secret_never_share") }
    static var bpYourAddress: String { LocalizationManager.shared.localizedString(for: "bp_your_address") }
    static var bpP2pDesc: String { LocalizationManager.shared.localizedString(for: "bp_p2p_desc") }
    
    // Key Properties
    static var bpKeyProperties: String { LocalizationManager.shared.localizedString(for: "bp_key_properties") }
    static var bpSecure: String { LocalizationManager.shared.localizedString(for: "bp_secure") }
    static var bpSecureDesc: String { LocalizationManager.shared.localizedString(for: "bp_secure_desc") }
    static var bpBorderless: String { LocalizationManager.shared.localizedString(for: "bp_borderless") }
    static var bpBorderlessDesc: String { LocalizationManager.shared.localizedString(for: "bp_borderless_desc") }
    static var bpPseudonymous: String { LocalizationManager.shared.localizedString(for: "bp_pseudonymous") }
    static var bpPseudonymousDesc: String { LocalizationManager.shared.localizedString(for: "bp_pseudonymous_desc") }
    static var bpIrreversible: String { LocalizationManager.shared.localizedString(for: "bp_irreversible") }
    static var bpIrreversibleDesc: String { LocalizationManager.shared.localizedString(for: "bp_irreversible_desc") }
    static var bpVerifiable: String { LocalizationManager.shared.localizedString(for: "bp_verifiable") }
    static var bpVerifiableDesc: String { LocalizationManager.shared.localizedString(for: "bp_verifiable_desc") }
    static var bpImmutable: String { LocalizationManager.shared.localizedString(for: "bp_immutable") }
    static var bpImmutableDesc: String { LocalizationManager.shared.localizedString(for: "bp_immutable_desc") }
    
    // Quote
    static var bpQuote: String { LocalizationManager.shared.localizedString(for: "bp_quote") }
    static var bpQuoteAuthor: String { LocalizationManager.shared.localizedString(for: "bp_quote_author") }
    static var topics: String { LocalizationManager.shared.localizedString(for: "topics") }
    static var wallets: String { LocalizationManager.shared.localizedString(for: "wallets") }
    static var items: String { LocalizationManager.shared.localizedString(for: "items") }
    static var books: String { LocalizationManager.shared.localizedString(for: "books") }
    static var channels: String { LocalizationManager.shared.localizedString(for: "channels") }
    static var education: String { LocalizationManager.shared.localizedString(for: "education") }
    static var selfCustodyHeader: String { LocalizationManager.shared.localizedString(for: "self_custody_header") }
    static var notYourKeys: String { LocalizationManager.shared.localizedString(for: "not_your_keys") }
    
    // MARK: - Settings
    static var settingsTitle: String { LocalizationManager.shared.localizedString(for: "settings_title") }
    static var appName: String { LocalizationManager.shared.localizedString(for: "app_name") }
    static var appTagline: String { LocalizationManager.shared.localizedString(for: "app_tagline") }
    static var version: String { LocalizationManager.shared.localizedString(for: "version") }
    static var general: String { LocalizationManager.shared.localizedString(for: "general") }
    static var language: String { LocalizationManager.shared.localizedString(for: "language") }
    static var autoRefresh: String { LocalizationManager.shared.localizedString(for: "auto_refresh") }
    static var refreshInterval: String { LocalizationManager.shared.localizedString(for: "refresh_interval") }
    static var hapticFeedback: String { LocalizationManager.shared.localizedString(for: "haptic_feedback") }
    static var dataSources: String { LocalizationManager.shared.localizedString(for: "data_sources") }
    static var active: String { LocalizationManager.shared.localizedString(for: "active") }
    static var premium: String { LocalizationManager.shared.localizedString(for: "premium") }
    static var about: String { LocalizationManager.shared.localizedString(for: "about") }
    static var rateApp: String { LocalizationManager.shared.localizedString(for: "rate_app") }
    static var sendFeedback: String { LocalizationManager.shared.localizedString(for: "send_feedback") }
    static var privacyPolicy: String { LocalizationManager.shared.localizedString(for: "privacy_policy") }
    static var termsOfService: String { LocalizationManager.shared.localizedString(for: "terms_of_service") }
    static var disclaimer: String { LocalizationManager.shared.localizedString(for: "disclaimer") }
    
    // MARK: - Time Intervals
    static var seconds15: String { LocalizationManager.shared.localizedString(for: "seconds_15") }
    static var seconds30: String { LocalizationManager.shared.localizedString(for: "seconds_30") }
    static var minute1: String { LocalizationManager.shared.localizedString(for: "minute_1") }
    static var minutes5: String { LocalizationManager.shared.localizedString(for: "minutes_5") }
    
    // MARK: - Historical Prices
    static var timeMachine: String { LocalizationManager.shared.localizedString(for: "time_machine") }
    static var yearsAgo: String { LocalizationManager.shared.localizedString(for: "years_ago") }
    static var yearAgo: String { LocalizationManager.shared.localizedString(for: "year_ago") }
    static var monthsAgo: String { LocalizationManager.shared.localizedString(for: "months_ago") }
    static var sincePrice: String { LocalizationManager.shared.localizedString(for: "since_price") }
    
    // MARK: - Asset Comparison
    static var assetComparison: String { LocalizationManager.shared.localizedString(for: "asset_comparison") }
    static var btcVsGold: String { LocalizationManager.shared.localizedString(for: "btc_vs_gold") }
    
    // MARK: - Debt Counter
    static var usDebt: String { LocalizationManager.shared.localizedString(for: "us_debt") }
    static var debtPerSecond: String { LocalizationManager.shared.localizedString(for: "debt_per_second") }
    static var btcEquivalent: String { LocalizationManager.shared.localizedString(for: "btc_equivalent") }
    
    // MARK: - Hyperinflation
    static var hyperinflation: String { LocalizationManager.shared.localizedString(for: "hyperinflation") }
    static var fiatWarning: String { LocalizationManager.shared.localizedString(for: "fiat_warning") }
    
    // MARK: - Wallets
    static var hardwareWallets: String { LocalizationManager.shared.localizedString(for: "hardware_wallets") }
    static var softwareWallets: String { LocalizationManager.shared.localizedString(for: "software_wallets") }
    static var multisigWallets: String { LocalizationManager.shared.localizedString(for: "multisig_wallets") }
    static var lightningWallets: String { LocalizationManager.shared.localizedString(for: "lightning_wallets") }
    static var allWallets: String { LocalizationManager.shared.localizedString(for: "all_wallets") }
    
    // MARK: - Books
    static var essentialBooks: String { LocalizationManager.shared.localizedString(for: "essential_books") }
    static var generalBooks: String { LocalizationManager.shared.localizedString(for: "general_books") }
    static var allBooks: String { LocalizationManager.shared.localizedString(for: "all_books") }
    
    // MARK: - YouTubers
    static var koreanYoutubers: String { LocalizationManager.shared.localizedString(for: "korean_youtubers") }
    static var internationalYoutubers: String { LocalizationManager.shared.localizedString(for: "international_youtubers") }
    static var allChannels: String { LocalizationManager.shared.localizedString(for: "all_channels") }
    
    // MARK: - Common
    static var viewChannel: String { LocalizationManager.shared.localizedString(for: "view_channel") }
    static var subscribers: String { LocalizationManager.shared.localizedString(for: "subscribers") }
    static var priceData: String { LocalizationManager.shared.localizedString(for: "price_data") }
    
    // MARK: - Korean Market
    static var koreanExchanges: String { LocalizationManager.shared.localizedString(for: "korean_exchanges") }
    static var cryptoTaxKorea: String { LocalizationManager.shared.localizedString(for: "crypto_tax_korea") }
    static var travelRule: String { LocalizationManager.shared.localizedString(for: "travel_rule") }
    static var taxDisclaimer: String { LocalizationManager.shared.localizedString(for: "tax_disclaimer") }
    
    // MARK: - Self-Custody Guide
    static var selfCustodyNavTitle: String { LocalizationManager.shared.localizedString(for: "self_custody_nav_title") }
    static var takeControl: String { LocalizationManager.shared.localizedString(for: "take_control") }
    static var selfCustodyIntro: String { LocalizationManager.shared.localizedString(for: "self_custody_intro") }
    static var remember: String { LocalizationManager.shared.localizedString(for: "remember") }
    static var reminderSeedPhrase: String { LocalizationManager.shared.localizedString(for: "reminder_seed_phrase") }
    static var reminderVerifyAddress: String { LocalizationManager.shared.localizedString(for: "reminder_verify_address") }
    static var reminderTestBackup: String { LocalizationManager.shared.localizedString(for: "reminder_test_backup") }
    static var reminderKeepUpdated: String { LocalizationManager.shared.localizedString(for: "reminder_keep_updated") }
    static var keyPoints: String { LocalizationManager.shared.localizedString(for: "key_points") }
    
    // MARK: - Guide Sections
    static var guideWhatIsCustody: String { LocalizationManager.shared.localizedString(for: "guide_what_is_custody") }
    static var guideWhatIsCustodyContent: String { LocalizationManager.shared.localizedString(for: "guide_what_is_custody_content") }
    static var guideCustodyPoint1: String { LocalizationManager.shared.localizedString(for: "guide_custody_point_1") }
    static var guideCustodyPoint2: String { LocalizationManager.shared.localizedString(for: "guide_custody_point_2") }
    static var guideCustodyPoint3: String { LocalizationManager.shared.localizedString(for: "guide_custody_point_3") }
    static var guideCustodyPoint4: String { LocalizationManager.shared.localizedString(for: "guide_custody_point_4") }
    
    static var guideKeys: String { LocalizationManager.shared.localizedString(for: "guide_keys") }
    static var guideKeysContent: String { LocalizationManager.shared.localizedString(for: "guide_keys_content") }
    static var guideKeysPoint1: String { LocalizationManager.shared.localizedString(for: "guide_keys_point_1") }
    static var guideKeysPoint2: String { LocalizationManager.shared.localizedString(for: "guide_keys_point_2") }
    static var guideKeysPoint3: String { LocalizationManager.shared.localizedString(for: "guide_keys_point_3") }
    static var guideKeysPoint4: String { LocalizationManager.shared.localizedString(for: "guide_keys_point_4") }
    
    static var guideSeed: String { LocalizationManager.shared.localizedString(for: "guide_seed") }
    static var guideSeedContent: String { LocalizationManager.shared.localizedString(for: "guide_seed_content") }
    static var guideSeedPoint1: String { LocalizationManager.shared.localizedString(for: "guide_seed_point_1") }
    static var guideSeedPoint2: String { LocalizationManager.shared.localizedString(for: "guide_seed_point_2") }
    static var guideSeedPoint3: String { LocalizationManager.shared.localizedString(for: "guide_seed_point_3") }
    static var guideSeedPoint4: String { LocalizationManager.shared.localizedString(for: "guide_seed_point_4") }
    
    static var guideHotCold: String { LocalizationManager.shared.localizedString(for: "guide_hot_cold") }
    static var guideHotColdContent: String { LocalizationManager.shared.localizedString(for: "guide_hot_cold_content") }
    static var guideHotColdPoint1: String { LocalizationManager.shared.localizedString(for: "guide_hot_cold_point_1") }
    static var guideHotColdPoint2: String { LocalizationManager.shared.localizedString(for: "guide_hot_cold_point_2") }
    static var guideHotColdPoint3: String { LocalizationManager.shared.localizedString(for: "guide_hot_cold_point_3") }
    static var guideHotColdPoint4: String { LocalizationManager.shared.localizedString(for: "guide_hot_cold_point_4") }
    
    static var guideMultisig: String { LocalizationManager.shared.localizedString(for: "guide_multisig") }
    static var guideMultisigContent: String { LocalizationManager.shared.localizedString(for: "guide_multisig_content") }
    static var guideMultisigPoint1: String { LocalizationManager.shared.localizedString(for: "guide_multisig_point_1") }
    static var guideMultisigPoint2: String { LocalizationManager.shared.localizedString(for: "guide_multisig_point_2") }
    static var guideMultisigPoint3: String { LocalizationManager.shared.localizedString(for: "guide_multisig_point_3") }
    static var guideMultisigPoint4: String { LocalizationManager.shared.localizedString(for: "guide_multisig_point_4") }
    
    static var guideMistakes: String { LocalizationManager.shared.localizedString(for: "guide_mistakes") }
    static var guideMistakesContent: String { LocalizationManager.shared.localizedString(for: "guide_mistakes_content") }
    static var guideMistakesPoint1: String { LocalizationManager.shared.localizedString(for: "guide_mistakes_point_1") }
    static var guideMistakesPoint2: String { LocalizationManager.shared.localizedString(for: "guide_mistakes_point_2") }
    static var guideMistakesPoint3: String { LocalizationManager.shared.localizedString(for: "guide_mistakes_point_3") }
    static var guideMistakesPoint4: String { LocalizationManager.shared.localizedString(for: "guide_mistakes_point_4") }
    static var guideMistakesPoint5: String { LocalizationManager.shared.localizedString(for: "guide_mistakes_point_5") }
    
    // MARK: - Security Checklist
    static var securityNavTitle: String { LocalizationManager.shared.localizedString(for: "security_nav_title") }
    static var resetChecklist: String { LocalizationManager.shared.localizedString(for: "reset_checklist") }
    static var yourProgress: String { LocalizationManager.shared.localizedString(for: "your_progress") }
    static var ofCompleted: String { LocalizationManager.shared.localizedString(for: "of_completed") }
    static var statusStart: String { LocalizationManager.shared.localizedString(for: "status_start") }
    static var statusGoodStart: String { LocalizationManager.shared.localizedString(for: "status_good_start") }
    static var statusProgress: String { LocalizationManager.shared.localizedString(for: "status_progress") }
    static var statusGreat: String { LocalizationManager.shared.localizedString(for: "status_great") }
    static var statusExcellent: String { LocalizationManager.shared.localizedString(for: "status_excellent") }
    static var whyThisMatters: String { LocalizationManager.shared.localizedString(for: "why_this_matters") }
    static var tips: String { LocalizationManager.shared.localizedString(for: "tips") }
    static var done: String { LocalizationManager.shared.localizedString(for: "done") }
    
    // MARK: - Security Items
    static var secBackupSeed: String { LocalizationManager.shared.localizedString(for: "sec_backup_seed") }
    static var secBackupSeedDesc: String { LocalizationManager.shared.localizedString(for: "sec_backup_seed_desc") }
    static var secBackupTip1: String { LocalizationManager.shared.localizedString(for: "sec_backup_tip_1") }
    static var secBackupTip2: String { LocalizationManager.shared.localizedString(for: "sec_backup_tip_2") }
    static var secBackupTip3: String { LocalizationManager.shared.localizedString(for: "sec_backup_tip_3") }
    static var secBackupTip4: String { LocalizationManager.shared.localizedString(for: "sec_backup_tip_4") }
    
    static var secNeverShare: String { LocalizationManager.shared.localizedString(for: "sec_never_share") }
    static var secNeverShareDesc: String { LocalizationManager.shared.localizedString(for: "sec_never_share_desc") }
    static var secNeverShareTip1: String { LocalizationManager.shared.localizedString(for: "sec_never_share_tip_1") }
    static var secNeverShareTip2: String { LocalizationManager.shared.localizedString(for: "sec_never_share_tip_2") }
    static var secNeverShareTip3: String { LocalizationManager.shared.localizedString(for: "sec_never_share_tip_3") }
    static var secNeverShareTip4: String { LocalizationManager.shared.localizedString(for: "sec_never_share_tip_4") }
    
    static var secVerifyAddress: String { LocalizationManager.shared.localizedString(for: "sec_verify_address") }
    static var secVerifyAddressDesc: String { LocalizationManager.shared.localizedString(for: "sec_verify_address_desc") }
    static var secVerifyTip1: String { LocalizationManager.shared.localizedString(for: "sec_verify_tip_1") }
    static var secVerifyTip2: String { LocalizationManager.shared.localizedString(for: "sec_verify_tip_2") }
    static var secVerifyTip3: String { LocalizationManager.shared.localizedString(for: "sec_verify_tip_3") }
    static var secVerifyTip4: String { LocalizationManager.shared.localizedString(for: "sec_verify_tip_4") }
    
    static var secPassphrase: String { LocalizationManager.shared.localizedString(for: "sec_passphrase") }
    static var secPassphraseDesc: String { LocalizationManager.shared.localizedString(for: "sec_passphrase_desc") }
    static var secPassphraseTip1: String { LocalizationManager.shared.localizedString(for: "sec_passphrase_tip_1") }
    static var secPassphraseTip2: String { LocalizationManager.shared.localizedString(for: "sec_passphrase_tip_2") }
    static var secPassphraseTip3: String { LocalizationManager.shared.localizedString(for: "sec_passphrase_tip_3") }
    static var secPassphraseTip4: String { LocalizationManager.shared.localizedString(for: "sec_passphrase_tip_4") }
    
    static var secTestRecovery: String { LocalizationManager.shared.localizedString(for: "sec_test_recovery") }
    static var secTestRecoveryDesc: String { LocalizationManager.shared.localizedString(for: "sec_test_recovery_desc") }
    static var secTestRecoveryTip1: String { LocalizationManager.shared.localizedString(for: "sec_test_recovery_tip_1") }
    static var secTestRecoveryTip2: String { LocalizationManager.shared.localizedString(for: "sec_test_recovery_tip_2") }
    static var secTestRecoveryTip3: String { LocalizationManager.shared.localizedString(for: "sec_test_recovery_tip_3") }
    static var secTestRecoveryTip4: String { LocalizationManager.shared.localizedString(for: "sec_test_recovery_tip_4") }
    
    static var secKeepUpdated: String { LocalizationManager.shared.localizedString(for: "sec_keep_updated") }
    static var secKeepUpdatedDesc: String { LocalizationManager.shared.localizedString(for: "sec_keep_updated_desc") }
    static var secKeepUpdatedTip1: String { LocalizationManager.shared.localizedString(for: "sec_keep_updated_tip_1") }
    static var secKeepUpdatedTip2: String { LocalizationManager.shared.localizedString(for: "sec_keep_updated_tip_2") }
    static var secKeepUpdatedTip3: String { LocalizationManager.shared.localizedString(for: "sec_keep_updated_tip_3") }
    static var secKeepUpdatedTip4: String { LocalizationManager.shared.localizedString(for: "sec_keep_updated_tip_4") }
    
    static var secHardwareWallet: String { LocalizationManager.shared.localizedString(for: "sec_hardware_wallet") }
    static var secHardwareWalletDesc: String { LocalizationManager.shared.localizedString(for: "sec_hardware_wallet_desc") }
    static var secHardwareTip1: String { LocalizationManager.shared.localizedString(for: "sec_hardware_tip_1") }
    static var secHardwareTip2: String { LocalizationManager.shared.localizedString(for: "sec_hardware_tip_2") }
    static var secHardwareTip3: String { LocalizationManager.shared.localizedString(for: "sec_hardware_tip_3") }
    static var secHardwareTip4: String { LocalizationManager.shared.localizedString(for: "sec_hardware_tip_4") }
    
    static var secPhishing: String { LocalizationManager.shared.localizedString(for: "sec_phishing") }
    static var secPhishingDesc: String { LocalizationManager.shared.localizedString(for: "sec_phishing_desc") }
    static var secPhishingTip1: String { LocalizationManager.shared.localizedString(for: "sec_phishing_tip_1") }
    static var secPhishingTip2: String { LocalizationManager.shared.localizedString(for: "sec_phishing_tip_2") }
    static var secPhishingTip3: String { LocalizationManager.shared.localizedString(for: "sec_phishing_tip_3") }
    static var secPhishingTip4: String { LocalizationManager.shared.localizedString(for: "sec_phishing_tip_4") }
    
    static var secInheritance: String { LocalizationManager.shared.localizedString(for: "sec_inheritance") }
    static var secInheritanceDesc: String { LocalizationManager.shared.localizedString(for: "sec_inheritance_desc") }
    static var secInheritanceTip1: String { LocalizationManager.shared.localizedString(for: "sec_inheritance_tip_1") }
    static var secInheritanceTip2: String { LocalizationManager.shared.localizedString(for: "sec_inheritance_tip_2") }
    static var secInheritanceTip3: String { LocalizationManager.shared.localizedString(for: "sec_inheritance_tip_3") }
    static var secInheritanceTip4: String { LocalizationManager.shared.localizedString(for: "sec_inheritance_tip_4") }
    
    static var secOpsec: String { LocalizationManager.shared.localizedString(for: "sec_opsec") }
    static var secOpsecDesc: String { LocalizationManager.shared.localizedString(for: "sec_opsec_desc") }
    static var secOpsecTip1: String { LocalizationManager.shared.localizedString(for: "sec_opsec_tip_1") }
    static var secOpsecTip2: String { LocalizationManager.shared.localizedString(for: "sec_opsec_tip_2") }
    static var secOpsecTip3: String { LocalizationManager.shared.localizedString(for: "sec_opsec_tip_3") }
    static var secOpsecTip4: String { LocalizationManager.shared.localizedString(for: "sec_opsec_tip_4") }
    
    static var importanceCritical: String { LocalizationManager.shared.localizedString(for: "importance_critical") }
    static var importanceHigh: String { LocalizationManager.shared.localizedString(for: "importance_high") }
    static var importanceMedium: String { LocalizationManager.shared.localizedString(for: "importance_medium") }
    
    // MARK: - Wallet Types
    static var walletTypeHardware: String { LocalizationManager.shared.localizedString(for: "wallet_type_hardware") }
    static var walletTypeDiy: String { LocalizationManager.shared.localizedString(for: "wallet_type_diy") }
    static var walletTypeSoftware: String { LocalizationManager.shared.localizedString(for: "wallet_type_software") }
    static var walletTypeMultisig: String { LocalizationManager.shared.localizedString(for: "wallet_type_multisig") }
    static var walletTypeHardwareDesc: String { LocalizationManager.shared.localizedString(for: "wallet_type_hardware_desc") }
    static var walletTypeDiyDesc: String { LocalizationManager.shared.localizedString(for: "wallet_type_diy_desc") }
    static var walletTypeSoftwareDesc: String { LocalizationManager.shared.localizedString(for: "wallet_type_software_desc") }
    static var walletTypeMultisigDesc: String { LocalizationManager.shared.localizedString(for: "wallet_type_multisig_desc") }
    
    // MARK: - Wallet List
    static var walletsNavTitle: String { LocalizationManager.shared.localizedString(for: "wallets_nav_title") }
    static var legend: String { LocalizationManager.shared.localizedString(for: "legend") }
    static var openSource: String { LocalizationManager.shared.localizedString(for: "open_source") }
    static var bitcoinOnly: String { LocalizationManager.shared.localizedString(for: "bitcoin_only") }
    static var features: String { LocalizationManager.shared.localizedString(for: "features") }
    static var pros: String { LocalizationManager.shared.localizedString(for: "pros") }
    static var cons: String { LocalizationManager.shared.localizedString(for: "cons") }
    static var visitWebsite: String { LocalizationManager.shared.localizedString(for: "visit_website") }
    
    // MARK: - Quote Card
    static var bitcoinWisdom: String { LocalizationManager.shared.localizedString(for: "bitcoin_wisdom") }
    static var quoteOfTheDay: String { LocalizationManager.shared.localizedString(for: "quote_of_the_day") }
    static var shareQuote: String { LocalizationManager.shared.localizedString(for: "share_quote") }
    
    // MARK: - Hyperinflation Card
    static var fiatGraveyard: String { LocalizationManager.shared.localizedString(for: "fiat_graveyard") }
    static var btcForever: String { LocalizationManager.shared.localizedString(for: "btc_forever") }
    static var tapForDetails: String { LocalizationManager.shared.localizedString(for: "tap_for_details") }
    static var crisis: String { LocalizationManager.shared.localizedString(for: "crisis") }
    static var severe: String { LocalizationManager.shared.localizedString(for: "severe") }
    static var high: String { LocalizationManager.shared.localizedString(for: "high") }
    static var total: String { LocalizationManager.shared.localizedString(for: "total") }
    static var source: String { LocalizationManager.shared.localizedString(for: "source") }
    static var fiatFailures: String { LocalizationManager.shared.localizedString(for: "fiat_failures") }
    static var currencyDestruction: String { LocalizationManager.shared.localizedString(for: "currency_destruction") }
    static var countriesHighInflation: String { LocalizationManager.shared.localizedString(for: "countries_high_inflation") }
    static var crisisLevel: String { LocalizationManager.shared.localizedString(for: "crisis_level") }
    static var severeLevel: String { LocalizationManager.shared.localizedString(for: "severe_level") }
    static var highLevel: String { LocalizationManager.shared.localizedString(for: "high_level") }
    static var countries: String { LocalizationManager.shared.localizedString(for: "countries") }
    static var historicalEvents: String { LocalizationManager.shared.localizedString(for: "historical_events") }
    static var worstHyperinflations: String { LocalizationManager.shared.localizedString(for: "worst_hyperinflations") }
    static var bitcoinTheExit: String { LocalizationManager.shared.localizedString(for: "bitcoin_the_exit") }
    static var fixedSupply: String { LocalizationManager.shared.localizedString(for: "fixed_supply") }
    static var noCentralBank: String { LocalizationManager.shared.localizedString(for: "no_central_bank") }
    static var transparentPolicy: String { LocalizationManager.shared.localizedString(for: "transparent_policy") }
    static var borderlessEscape: String { LocalizationManager.shared.localizedString(for: "borderless_escape") }
    static var selfCustodyBank: String { LocalizationManager.shared.localizedString(for: "self_custody_bank") }
    static var adoptionHighest: String { LocalizationManager.shared.localizedString(for: "adoption_highest") }
    static var highInflation: String { LocalizationManager.shared.localizedString(for: "high_inflation") }
    static var capitalControls: String { LocalizationManager.shared.localizedString(for: "capital_controls") }
    static var currencyCrises: String { LocalizationManager.shared.localizedString(for: "currency_crises") }
    static var dataFrom: String { LocalizationManager.shared.localizedString(for: "data_from") }
    static var consumerPriceInflation: String { LocalizationManager.shared.localizedString(for: "consumer_price_inflation") }
    static var historical: String { LocalizationManager.shared.localizedString(for: "historical") }
    static var current: String { LocalizationManager.shared.localizedString(for: "current") }
}

// MARK: - String Extension for Localization
extension String {
    var localized: String {
        LocalizationManager.shared.localizedString(for: self)
    }
}
