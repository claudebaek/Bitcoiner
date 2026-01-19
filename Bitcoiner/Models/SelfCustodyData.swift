//
//  SelfCustodyData.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import Foundation

// MARK: - Wallet Type
enum WalletType: String, CaseIterable {
    case hardware = "Hardware"
    case hardwareDIY = "DIY/Air-gapped"
    case software = "Software"
    case multisig = "Multi-sig"
    
    var icon: String {
        switch self {
        case .hardware: return "cpu"
        case .hardwareDIY: return "hammer"
        case .software: return "iphone"
        case .multisig: return "lock.shield"
        }
    }
    
    var description: String {
        switch self {
        case .hardware:
            return "Dedicated devices that store your private keys offline"
        case .hardwareDIY:
            return "Open-source, build-your-own hardware wallets for maximum security"
        case .software:
            return "Apps that give you full control of your keys"
        case .multisig:
            return "Multiple keys required for transactions - ultimate security"
        }
    }
}

// MARK: - Wallet
struct Wallet: Identifiable {
    let id = UUID()
    let name: String
    let type: WalletType
    let icon: String
    let description: String
    let features: [String]
    let pros: [String]
    let cons: [String]
    let url: URL
    let isOpenSource: Bool
    let isBitcoinOnly: Bool
    
    static let allWallets: [Wallet] = [
        // Hardware Wallets
        Wallet(
            name: "Ledger",
            type: .hardware,
            icon: "cpu",
            description: "Popular hardware wallet with a secure element chip",
            features: ["Secure Element", "Bluetooth", "Multi-coin", "Mobile App"],
            pros: ["User-friendly", "Wide coin support", "Mobile companion app"],
            cons: ["Closed-source firmware", "Data breach history", "Not Bitcoin-only"],
            url: URL(string: "https://www.ledger.com")!,
            isOpenSource: false,
            isBitcoinOnly: false
        ),
        Wallet(
            name: "Trezor",
            type: .hardware,
            icon: "cpu",
            description: "Pioneer hardware wallet with open-source firmware",
            features: ["Open Source", "Touchscreen (Model T)", "Shamir Backup", "Password Manager"],
            pros: ["Fully open-source", "Trusted brand", "Great UI"],
            cons: ["No secure element", "Multi-coin (not Bitcoin-only)"],
            url: URL(string: "https://trezor.io")!,
            isOpenSource: true,
            isBitcoinOnly: false
        ),
        Wallet(
            name: "Coldcard",
            type: .hardware,
            icon: "cpu",
            description: "Bitcoin-only, air-gapped hardware wallet for maximalists",
            features: ["Bitcoin Only", "Air-gapped", "MicroSD", "Duress PIN", "Secure Element"],
            pros: ["Bitcoin-only focus", "Air-gapped option", "Advanced features", "Duress wallet"],
            cons: ["Steeper learning curve", "No touchscreen"],
            url: URL(string: "https://coldcard.com")!,
            isOpenSource: true,
            isBitcoinOnly: true
        ),
        Wallet(
            name: "BitBox02",
            type: .hardware,
            icon: "cpu",
            description: "Swiss-made minimalist hardware wallet",
            features: ["Dual chip", "Bitcoin-only version", "Touch gestures", "USB-C"],
            pros: ["Simple design", "Bitcoin-only option", "Swiss quality"],
            cons: ["Smaller ecosystem", "Less features than competitors"],
            url: URL(string: "https://shiftcrypto.ch")!,
            isOpenSource: true,
            isBitcoinOnly: true
        ),
        Wallet(
            name: "Jade",
            type: .hardware,
            icon: "cpu",
            description: "Blockstream's affordable Bitcoin hardware wallet",
            features: ["Camera for QR", "Bluetooth", "Open Source", "Liquid Network"],
            pros: ["Affordable", "Open-source", "Camera for air-gap", "Blockstream backing"],
            cons: ["No secure element", "Requires companion app"],
            url: URL(string: "https://blockstream.com/jade")!,
            isOpenSource: true,
            isBitcoinOnly: true
        ),
        Wallet(
            name: "Keystone",
            type: .hardware,
            icon: "cpu",
            description: "Air-gapped hardware wallet with large touchscreen",
            features: ["4-inch Touchscreen", "QR codes only", "Open Source", "Fingerprint"],
            pros: ["100% air-gapped", "Large screen", "QR-based", "Fingerprint option"],
            cons: ["Larger size", "Multi-coin version less focused"],
            url: URL(string: "https://keyst.one")!,
            isOpenSource: true,
            isBitcoinOnly: false
        ),
        
        // DIY / Air-gapped
        Wallet(
            name: "SeedSigner",
            type: .hardwareDIY,
            icon: "hammer",
            description: "Open-source DIY signing device on Raspberry Pi Zero",
            features: ["Stateless", "QR-based", "Air-gapped", "DIY build", "Open Source"],
            pros: ["Very cheap (~$50)", "Fully open-source", "No stored data", "Maximum transparency"],
            cons: ["DIY assembly required", "No screen protection", "Technical knowledge needed"],
            url: URL(string: "https://seedsigner.com")!,
            isOpenSource: true,
            isBitcoinOnly: true
        ),
        
        // Software Wallets
        Wallet(
            name: "Blue Wallet",
            type: .software,
            icon: "iphone",
            description: "Feature-rich mobile Bitcoin and Lightning wallet",
            features: ["Lightning", "Watch-only", "Multisig", "Plausible deniability"],
            pros: ["Great UI", "Lightning support", "Hardware wallet integration"],
            cons: ["Mobile-only", "Default Lightning is custodial"],
            url: URL(string: "https://bluewallet.io")!,
            isOpenSource: true,
            isBitcoinOnly: true
        ),
        Wallet(
            name: "Sparrow",
            type: .software,
            icon: "desktopcomputer",
            description: "Desktop wallet focused on security and privacy",
            features: ["PSBT", "Coin control", "Hardware wallet support", "Tor integration"],
            pros: ["Excellent for power users", "Privacy features", "Full hardware support"],
            cons: ["Desktop only", "Complex for beginners"],
            url: URL(string: "https://sparrowwallet.com")!,
            isOpenSource: true,
            isBitcoinOnly: true
        ),
        Wallet(
            name: "Electrum",
            type: .software,
            icon: "desktopcomputer",
            description: "One of the oldest and most trusted Bitcoin wallets",
            features: ["Hardware support", "Multisig", "Lightning", "Cold storage"],
            pros: ["Battle-tested", "Feature-rich", "Cross-platform"],
            cons: ["Dated UI", "Phishing attacks target it"],
            url: URL(string: "https://electrum.org")!,
            isOpenSource: true,
            isBitcoinOnly: true
        ),
        Wallet(
            name: "Muun",
            type: .software,
            icon: "iphone",
            description: "Self-custodial wallet with unified Bitcoin/Lightning",
            features: ["Unified balance", "2-of-2 multisig", "Emergency kit", "Simple UI"],
            pros: ["Very user-friendly", "Seamless Lightning", "Good recovery system"],
            cons: ["Higher Lightning fees", "Custom backup system"],
            url: URL(string: "https://muun.com")!,
            isOpenSource: true,
            isBitcoinOnly: true
        ),
        Wallet(
            name: "Coconut Wallet",
            type: .software,
            icon: "iphone",
            description: "Korean Bitcoin self-custody wallet with simple UX",
            features: ["Simple UI", "Self-custody", "Korean support", "Bitcoin-only"],
            pros: ["Clean design", "Easy to use", "Korean language", "Self-custody focused"],
            cons: ["Newer wallet", "Smaller community"],
            url: URL(string: "https://www.coconut.onl")!,
            isOpenSource: true,
            isBitcoinOnly: true
        ),
        
        // Multisig
        Wallet(
            name: "Casa",
            type: .multisig,
            icon: "lock.shield",
            description: "Premium multisig with concierge service",
            features: ["2-of-3 or 3-of-5", "Mobile app", "Inheritance planning", "Support team"],
            pros: ["Professional support", "Easy multisig", "Inheritance solution"],
            cons: ["Subscription required", "Not fully open-source"],
            url: URL(string: "https://casa.io")!,
            isOpenSource: false,
            isBitcoinOnly: true
        ),
        Wallet(
            name: "Unchained",
            type: .multisig,
            icon: "lock.shield",
            description: "Collaborative custody with financial services",
            features: ["2-of-3 multisig", "IRA support", "Loans", "Inheritance"],
            pros: ["Bitcoin IRA", "Loans against Bitcoin", "Professional service"],
            cons: ["US-focused", "Subscription for premium"],
            url: URL(string: "https://unchained.com")!,
            isOpenSource: false,
            isBitcoinOnly: true
        ),
        Wallet(
            name: "Nunchuk",
            type: .multisig,
            icon: "lock.shield",
            description: "Free multisig wallet with collaborative features",
            features: ["Free multisig", "Hardware support", "Collaborative", "Inheritance"],
            pros: ["Free tier available", "Great UI", "Team collaboration"],
            cons: ["Premium features cost", "Mobile app less mature"],
            url: URL(string: "https://nunchuk.io")!,
            isOpenSource: true,
            isBitcoinOnly: true
        )
    ]
    
    static func wallets(for type: WalletType) -> [Wallet] {
        allWallets.filter { $0.type == type }
    }
}

// MARK: - Security Check Item
enum SecurityImportance: String {
    case critical = "Critical"
    case high = "High"
    case medium = "Medium"
    
    var color: String {
        switch self {
        case .critical: return "lossRed"
        case .high: return "bitcoinOrange"
        case .medium: return "neutralYellow"
        }
    }
}

struct SecurityCheckItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let importance: SecurityImportance
    let tips: [String]
    var isCompleted: Bool = false
    
    static let allItems: [SecurityCheckItem] = [
        SecurityCheckItem(
            title: "Backup your seed phrase",
            description: "Write down your 12 or 24 words on paper or metal. Never store digitally.",
            importance: .critical,
            tips: [
                "Use metal backup for fire/water resistance",
                "Store in multiple secure locations",
                "Never take a photo or screenshot",
                "Consider splitting with Shamir backup"
            ]
        ),
        SecurityCheckItem(
            title: "Never share your seed phrase",
            description: "No legitimate service will ever ask for your seed phrase. Anyone who asks is a scammer.",
            importance: .critical,
            tips: [
                "Support will NEVER ask for your seed",
                "No 'verification' requires your seed",
                "Beware of phishing websites",
                "Don't enter seed on any website"
            ]
        ),
        SecurityCheckItem(
            title: "Verify receive addresses",
            description: "Always verify the address on your hardware wallet screen before receiving.",
            importance: .critical,
            tips: [
                "Check first and last 6 characters",
                "Verify on hardware wallet display",
                "Beware of clipboard malware",
                "Send small test transaction first"
            ]
        ),
        SecurityCheckItem(
            title: "Use a passphrase (25th word)",
            description: "Add an extra word to your seed for additional security layer.",
            importance: .high,
            tips: [
                "Creates a hidden wallet",
                "Provides plausible deniability",
                "Memorize or store separately from seed",
                "Test recovery before storing funds"
            ]
        ),
        SecurityCheckItem(
            title: "Test your recovery process",
            description: "Practice recovering your wallet before storing significant funds.",
            importance: .high,
            tips: [
                "Use small amount first",
                "Wipe and restore your device",
                "Verify you can access funds",
                "Document the process for yourself"
            ]
        ),
        SecurityCheckItem(
            title: "Keep software updated",
            description: "Regularly update your wallet software and firmware for security patches.",
            importance: .high,
            tips: [
                "Enable update notifications",
                "Verify updates from official sources",
                "Read release notes for changes",
                "Backup before major updates"
            ]
        ),
        SecurityCheckItem(
            title: "Use hardware wallet for large amounts",
            description: "Keep significant funds on a hardware wallet, not on exchanges or hot wallets.",
            importance: .high,
            tips: [
                "Only keep spending money in hot wallet",
                "Use 'Not your keys, not your coins' rule",
                "Consider multisig for large amounts",
                "Diversify across multiple devices"
            ]
        ),
        SecurityCheckItem(
            title: "Beware of phishing attacks",
            description: "Always verify you're on the correct website and downloading from official sources.",
            importance: .high,
            tips: [
                "Bookmark official sites",
                "Verify SSL certificates",
                "Don't click links from emails",
                "Download only from official sources"
            ]
        ),
        SecurityCheckItem(
            title: "Set up inheritance plan",
            description: "Ensure your loved ones can access your Bitcoin if something happens to you.",
            importance: .medium,
            tips: [
                "Consider multisig with family member",
                "Use services like Casa or Unchained",
                "Write clear instructions",
                "Store information securely"
            ]
        ),
        SecurityCheckItem(
            title: "Practice operational security",
            description: "Don't reveal your holdings publicly. Be cautious about who knows you own Bitcoin.",
            importance: .medium,
            tips: [
                "Don't post about holdings online",
                "Be vague about amounts",
                "Use different addresses for privacy",
                "Consider running your own node"
            ]
        )
    ]
}

// MARK: - Guide Section
struct GuideSection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let content: String
    let keyPoints: [String]
    
    static let allSections: [GuideSection] = [
        GuideSection(
            title: "What is Self-Custody?",
            icon: "key.fill",
            content: "Self-custody means you hold your own private keys, giving you complete control over your Bitcoin. Unlike keeping funds on an exchange, no third party can freeze, seize, or lose your Bitcoin.",
            keyPoints: [
                "You control your private keys",
                "No third party can freeze your funds",
                "You are responsible for security",
                "\"Not your keys, not your coins\""
            ]
        ),
        GuideSection(
            title: "Private Keys & Public Keys",
            icon: "lock.fill",
            content: "Your private key is a secret number that proves ownership and allows you to spend your Bitcoin. Your public key (and address) can be shared with anyone to receive Bitcoin. Never share your private key!",
            keyPoints: [
                "Private key = Your secret, never share",
                "Public key/address = Safe to share",
                "Private key signs transactions",
                "Anyone with private key controls the Bitcoin"
            ]
        ),
        GuideSection(
            title: "Seed Phrases (BIP39)",
            icon: "text.word.spacing",
            content: "A seed phrase is a human-readable backup of your private keys. It's typically 12 or 24 words that can restore your entire wallet. This is the most critical piece of information to protect.",
            keyPoints: [
                "12 or 24 words from a standard list",
                "Can restore all your wallets",
                "Write on paper or metal, never digital",
                "Store in multiple secure locations"
            ]
        ),
        GuideSection(
            title: "Hot vs Cold Wallets",
            icon: "thermometer.snowflake",
            content: "Hot wallets are connected to the internet (mobile/desktop apps). Cold wallets are offline (hardware wallets, paper). Cold storage is more secure but less convenient for frequent transactions.",
            keyPoints: [
                "Hot = Internet connected, convenient",
                "Cold = Offline, more secure",
                "Keep large amounts in cold storage",
                "Use hot wallet for daily spending"
            ]
        ),
        GuideSection(
            title: "Single-sig vs Multi-sig",
            icon: "person.3.fill",
            content: "Single-signature requires one key to spend. Multi-signature (multisig) requires multiple keys (e.g., 2-of-3). Multisig provides better security against theft and single points of failure.",
            keyPoints: [
                "Single-sig = One key needed",
                "Multi-sig = Multiple keys needed",
                "2-of-3 is popular setup",
                "Eliminates single point of failure"
            ]
        ),
        GuideSection(
            title: "Common Mistakes to Avoid",
            icon: "exclamationmark.triangle.fill",
            content: "Many people lose Bitcoin due to preventable mistakes. Learn from others' errors to protect your stack.",
            keyPoints: [
                "Storing seed phrase digitally",
                "Using weak or reused passwords",
                "Falling for phishing scams",
                "Not testing backup recovery",
                "Leaving funds on exchanges long-term"
            ]
        )
    ]
}

// MARK: - Korean Market Info
struct KoreanMarketInfo {
    static let exchangeInfo = """
    Korean exchanges (Upbit, Bithumb, Coinone, Korbit) require:
    • Real-name verification (실명인증)
    • Travel Rule compliance for withdrawals over ₩1,000,000
    • Bank account linked to verified identity
    """
    
    static let taxInfo = """
    Korean Crypto Tax (as of 2025):
    • Tax on gains over ₩2,500,000 (250만원) per year
    • 20% tax rate on gains above threshold
    • Keep records of all purchases and sales
    • Consider tax implications before selling
    """
    
    static let travelRuleInfo = """
    Travel Rule in Korea:
    • Required for transfers over ₩1,000,000
    • Must provide recipient information
    • Applies to transfers between exchanges
    • Self-custody withdrawals may require verification
    """
}
