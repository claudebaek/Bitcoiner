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
    
    var localizedName: String {
        switch self {
        case .hardware: return L10n.walletTypeHardware
        case .hardwareDIY: return L10n.walletTypeDiy
        case .software: return L10n.walletTypeSoftware
        case .multisig: return L10n.walletTypeMultisig
        }
    }
    
    var description: String {
        switch self {
        case .hardware:
            return L10n.walletTypeHardwareDesc
        case .hardwareDIY:
            return L10n.walletTypeDiyDesc
        case .software:
            return L10n.walletTypeSoftwareDesc
        case .multisig:
            return L10n.walletTypeMultisigDesc
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
    
    var localizedName: String {
        switch self {
        case .critical: return L10n.importanceCritical
        case .high: return L10n.importanceHigh
        case .medium: return L10n.importanceMedium
        }
    }
    
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
    
    static let allItems: [SecurityCheckItem] = localizedItems
    
    static var localizedItems: [SecurityCheckItem] {
        [
            SecurityCheckItem(
                title: L10n.secBackupSeed,
                description: L10n.secBackupSeedDesc,
                importance: .critical,
                tips: [
                    L10n.secBackupTip1,
                    L10n.secBackupTip2,
                    L10n.secBackupTip3,
                    L10n.secBackupTip4
                ]
            ),
            SecurityCheckItem(
                title: L10n.secNeverShare,
                description: L10n.secNeverShareDesc,
                importance: .critical,
                tips: [
                    L10n.secNeverShareTip1,
                    L10n.secNeverShareTip2,
                    L10n.secNeverShareTip3,
                    L10n.secNeverShareTip4
                ]
            ),
            SecurityCheckItem(
                title: L10n.secVerifyAddress,
                description: L10n.secVerifyAddressDesc,
                importance: .critical,
                tips: [
                    L10n.secVerifyTip1,
                    L10n.secVerifyTip2,
                    L10n.secVerifyTip3,
                    L10n.secVerifyTip4
                ]
            ),
            SecurityCheckItem(
                title: L10n.secPassphrase,
                description: L10n.secPassphraseDesc,
                importance: .high,
                tips: [
                    L10n.secPassphraseTip1,
                    L10n.secPassphraseTip2,
                    L10n.secPassphraseTip3,
                    L10n.secPassphraseTip4
                ]
            ),
            SecurityCheckItem(
                title: L10n.secTestRecovery,
                description: L10n.secTestRecoveryDesc,
                importance: .high,
                tips: [
                    L10n.secTestRecoveryTip1,
                    L10n.secTestRecoveryTip2,
                    L10n.secTestRecoveryTip3,
                    L10n.secTestRecoveryTip4
                ]
            ),
            SecurityCheckItem(
                title: L10n.secKeepUpdated,
                description: L10n.secKeepUpdatedDesc,
                importance: .high,
                tips: [
                    L10n.secKeepUpdatedTip1,
                    L10n.secKeepUpdatedTip2,
                    L10n.secKeepUpdatedTip3,
                    L10n.secKeepUpdatedTip4
                ]
            ),
            SecurityCheckItem(
                title: L10n.secHardwareWallet,
                description: L10n.secHardwareWalletDesc,
                importance: .high,
                tips: [
                    L10n.secHardwareTip1,
                    L10n.secHardwareTip2,
                    L10n.secHardwareTip3,
                    L10n.secHardwareTip4
                ]
            ),
            SecurityCheckItem(
                title: L10n.secPhishing,
                description: L10n.secPhishingDesc,
                importance: .high,
                tips: [
                    L10n.secPhishingTip1,
                    L10n.secPhishingTip2,
                    L10n.secPhishingTip3,
                    L10n.secPhishingTip4
                ]
            ),
            SecurityCheckItem(
                title: L10n.secInheritance,
                description: L10n.secInheritanceDesc,
                importance: .medium,
                tips: [
                    L10n.secInheritanceTip1,
                    L10n.secInheritanceTip2,
                    L10n.secInheritanceTip3,
                    L10n.secInheritanceTip4
                ]
            ),
            SecurityCheckItem(
                title: L10n.secOpsec,
                description: L10n.secOpsecDesc,
                importance: .medium,
                tips: [
                    L10n.secOpsecTip1,
                    L10n.secOpsecTip2,
                    L10n.secOpsecTip3,
                    L10n.secOpsecTip4
                ]
            )
        ]
    }
}

// MARK: - Guide Section
struct GuideSection: Identifiable {
    let id: String  // Use stable string ID instead of UUID
    let title: String
    let icon: String
    let content: String
    let keyPoints: [String]
    
    static let allSections: [GuideSection] = localizedSections
    
    static var localizedSections: [GuideSection] {
        [
            GuideSection(
                id: "custody",
                title: L10n.guideWhatIsCustody,
                icon: "key.fill",
                content: L10n.guideWhatIsCustodyContent,
                keyPoints: [
                    L10n.guideCustodyPoint1,
                    L10n.guideCustodyPoint2,
                    L10n.guideCustodyPoint3,
                    L10n.guideCustodyPoint4
                ]
            ),
            GuideSection(
                id: "keys",
                title: L10n.guideKeys,
                icon: "lock.fill",
                content: L10n.guideKeysContent,
                keyPoints: [
                    L10n.guideKeysPoint1,
                    L10n.guideKeysPoint2,
                    L10n.guideKeysPoint3,
                    L10n.guideKeysPoint4
                ]
            ),
            GuideSection(
                id: "seed",
                title: L10n.guideSeed,
                icon: "text.word.spacing",
                content: L10n.guideSeedContent,
                keyPoints: [
                    L10n.guideSeedPoint1,
                    L10n.guideSeedPoint2,
                    L10n.guideSeedPoint3,
                    L10n.guideSeedPoint4
                ]
            ),
            GuideSection(
                id: "hotcold",
                title: L10n.guideHotCold,
                icon: "thermometer.snowflake",
                content: L10n.guideHotColdContent,
                keyPoints: [
                    L10n.guideHotColdPoint1,
                    L10n.guideHotColdPoint2,
                    L10n.guideHotColdPoint3,
                    L10n.guideHotColdPoint4
                ]
            ),
            GuideSection(
                id: "multisig",
                title: L10n.guideMultisig,
                icon: "person.3.fill",
                content: L10n.guideMultisigContent,
                keyPoints: [
                    L10n.guideMultisigPoint1,
                    L10n.guideMultisigPoint2,
                    L10n.guideMultisigPoint3,
                    L10n.guideMultisigPoint4
                ]
            ),
            GuideSection(
                id: "mistakes",
                title: L10n.guideMistakes,
                icon: "exclamationmark.triangle.fill",
                content: L10n.guideMistakesContent,
                keyPoints: [
                    L10n.guideMistakesPoint1,
                    L10n.guideMistakesPoint2,
                    L10n.guideMistakesPoint3,
                    L10n.guideMistakesPoint4,
                    L10n.guideMistakesPoint5
                ]
            )
        ]
    }
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

// MARK: - Book Category
enum BookCategory: String, CaseIterable {
    case essential = "Essential"
    case general = "General"
    
    var localizedTitle: String {
        switch self {
        case .essential: return L10n.essentialBooks
        case .general: return L10n.generalBooks
        }
    }
    
    var icon: String {
        switch self {
        case .essential: return "star.fill"
        case .general: return "book.fill"
        }
    }
}

// MARK: - Bitcoin Book
struct BitcoinBook: Identifiable {
    let id: Int
    let titleKorean: String
    let titleEnglish: String?
    let author: String
    let category: BookCategory
    let description: String
    let hasPdf: Bool
    
    static let allBooks: [BitcoinBook] = [
        // Essential Books (비트코인 필수) - 12권
        BitcoinBook(
            id: 1,
            titleKorean: "왜 그들만 부자가 되는가",
            titleEnglish: "The Price of Tomorrow",
            author: "Jeff Booth",
            category: .essential,
            description: "기술 발전은 본질적으로 디플레이션을 유발하지만, 현대 경제 시스템은 인플레이션과 부채에 기반해 있어 충돌이 불가피하다. 양적완화와 저금리 정책의 한계, 사회적 불평등 심화, 그리고 비트코인을 포함한 새로운 화폐 패러다임의 필요성을 역설한다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 2,
            titleKorean: "달러는 왜 비트코인을 싫어하는가",
            titleEnglish: "The Bitcoin Standard",
            author: "Saifedean Ammous",
            category: .essential,
            description: "화폐의 역사를 원시 화폐부터 금본위제, 법정화폐까지 추적하며 각 시스템의 장단점을 분석한다. 정부/중앙은행의 화폐 발행 조작이 인플레이션과 시간 선호 왜곡을 유발하며, 비트코인이 2100만 개 한정 공급과 탈중앙화로 '건전화폐'의 대안이 될 수 있음을 주장한다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 3,
            titleKorean: "21가지 교훈",
            titleEnglish: "21 Lessons",
            author: "Gigi",
            category: .essential,
            description: "비트코인 래빗홀에 빠지며 배운 21가지 교훈을 철학(불변성, 희소성, 정체성), 경제(인플레이션, 화폐의 역사, 부분지급준비제도), 기술(숫자의 힘, 검증, 프라이버시, 사이퍼펑크) 세 파트로 나눠 설명한다. 비트코인을 통해 돈, 사회, 기술에 대한 근본적 질문을 던진다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 4,
            titleKorean: "비트코인 화폐의 이해 / 더 파이엣 스탠다드",
            titleEnglish: "The Fiat Standard",
            author: "Saifedean Ammous",
            category: .essential,
            description: "법정화폐 시스템의 구조적 문제를 심층 분석한다. 은행 대출을 통한 화폐 창출, 인플레이션으로 인한 저축 파괴, 부채 노예제, 단기주의 문화 촉진 등을 비판하며, 비트코인이 고정 공급량과 탈중앙화로 이러한 문제들의 대안이 될 수 있음을 제시한다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 5,
            titleKorean: "비트코인 낙관론",
            titleEnglish: "The Bullish Case for Bitcoin",
            author: "Vijay Boyapati",
            category: .essential,
            description: "화폐의 진화 단계(수집품→가치저장→교환매개→가치척도)를 설명하고, 비트코인을 내구성, 휴대성, 분할성, 희소성, 검열저항성 측면에서 금과 법정화폐와 비교 분석한다. 변동성은 초기 단계의 자연스러운 현상이며, 장기적으로 글로벌 가치저장 시장을 점유할 것으로 전망한다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 6,
            titleKorean: "레이어드 머니 - 돈이 진화한다",
            titleEnglish: "Layered Money",
            author: "Nik Bhatia",
            category: .essential,
            description: "화폐는 계층 구조를 가진다. 1층은 상대방 위험이 없는 자산(금, 비트코인), 2층 이하는 신뢰가 필요한 자산(은행 예금, 국채 등)이다. 물물교환에서 금본위제, 법정화폐로의 진화 과정을 추적하며, 비트코인이 디지털 시대의 1층 화폐로 세계 기축통화가 될 가능성을 탐구한다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 7,
            titleKorean: "비트코인 디플로이 2025",
            titleEnglish: nil,
            author: "Atomic Bitcoin",
            category: .essential,
            description: "비트코인을 실제로 도입하고 사용하기 위한 전략과 실행 가이드. 개인, 기업, 기관이 비트코인을 어떻게 받아들이고 활용할 수 있는지 구체적인 방법론을 제시한다.",
            hasPdf: true
        ),
        BitcoinBook(
            id: 8,
            titleKorean: "비트코인 백서 해설",
            titleEnglish: "Bitcoin Whitepaper Explained",
            author: "Various",
            category: .essential,
            description: "사토시 나카모토가 2008년 발표한 비트코인 백서 'Bitcoin: A Peer-to-Peer Electronic Cash System'의 각 섹션을 상세히 해설한다. 이중지불 문제 해결, 작업증명, 타임스탬프 서버, 인센티브 구조 등 핵심 개념을 쉽게 풀어 설명한다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 9,
            titleKorean: "비트코인 사용 가이드",
            titleEnglish: nil,
            author: "Various",
            category: .essential,
            description: "비트코인의 실제 사용법을 다룬 실용서. 지갑 생성, 시드구문 백업, 거래소 이용, 온체인/라이트닝 전송, 보안 모범 사례 등 비트코인을 안전하게 구매, 보관, 사용하는 방법을 단계별로 안내한다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 10,
            titleKorean: "리얼 머니 더 비트코인",
            titleEnglish: "Real Money: The Bitcoin",
            author: "Various",
            category: .essential,
            description: "비트코인이 왜 '진짜 돈'인지를 화폐의 본질적 속성(희소성, 내구성, 분할성, 휴대성, 대체성, 검증성)을 기준으로 논증한다. 법정화폐와 금의 한계를 지적하고, 비트코인만이 디지털 시대에 완벽한 화폐가 될 수 있는 이유를 설명한다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 11,
            titleKorean: "비트코인 블록사이즈 전쟁",
            titleEnglish: "The Blocksize War",
            author: "Jonathan Bier",
            category: .essential,
            description: "2015-2017년 비트코인 커뮤니티를 분열시킨 블록 크기 논쟁의 역사. Big Blockers(용량 증가)와 Small Blockers(탈중앙화 보존) 간의 대립, SegWit 활성화, Bitcoin Cash 분리, SegWit2x 실패까지의 과정을 상세히 기록한다. 탈중앙 시스템의 거버넌스와 내러티브의 힘을 보여준다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 12,
            titleKorean: "비트코인 핸드북",
            titleEnglish: "Bitcoin Handbook",
            author: "Various",
            category: .essential,
            description: "비트코인에 대한 종합적인 핸드북. 기술적 원리, 경제적 의미, 투자 관점, 보안 모범 사례, 법적 고려사항 등을 망라한다. 입문자부터 숙련자까지 참고할 수 있는 레퍼런스 가이드.",
            hasPdf: false
        ),
        
        // General Books (비트코인 일반) - 10권
        BitcoinBook(
            id: 13,
            titleKorean: "세상 친절한 비트코인 수업",
            titleEnglish: nil,
            author: "Various",
            category: .general,
            description: "비트코인 입문자를 위한 친절한 가이드. 2018년 출간되어 블록체인 기술의 기초, 비트코인의 작동 원리, 암호화폐 시장의 이해를 쉬운 언어로 설명한다. 기술적 배경 없이도 비트코인을 이해할 수 있도록 구성되어 있다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 14,
            titleKorean: "땡스 갓포 비트코인",
            titleEnglish: "Thank God for Bitcoin",
            author: "Jimmy Song 외",
            category: .general,
            description: "기독교 관점에서 비트코인을 해석한 책. 법정화폐 시스템의 도덕적 문제점(인플레이션을 통한 은밀한 도둑질, 부채 조장)을 성경적 가치관으로 비판하고, 비트코인이 정직하고 건전한 화폐로서 성경적 원칙에 부합함을 논증한다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 15,
            titleKorean: "비트코인 웨이브",
            titleEnglish: nil,
            author: "Various",
            category: .general,
            description: "비트코인의 이념과 실천을 통합한 책. 단순히 투자 자산으로서의 비트코인이 아닌, 화폐 주권, 개인 자유, 탈중앙화 철학 등 비트코인이 추구하는 가치와 이를 일상에서 실천하는 방법을 다룬다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 16,
            titleKorean: "비트코인 미니북",
            titleEnglish: "Bitcoin Mini Book",
            author: "Various",
            category: .general,
            description: "비트코인의 기술적 내용을 간결하게 요약한 책. 블록체인, 채굴, 합의 메커니즘, 암호학 기초 등 핵심 개념을 짧은 분량으로 압축 정리하여 빠르게 학습할 수 있도록 구성되어 있다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 17,
            titleKorean: "비트코인이란 무엇인가",
            titleEnglish: nil,
            author: "Various",
            category: .general,
            description: "비트코인의 역사와 본질을 요약한 책. 2008년 백서 발표부터 현재까지의 발전 과정, 주요 사건들, 그리고 비트코인이 무엇이고 왜 중요한지에 대한 근본적인 질문에 답한다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 18,
            titleKorean: "나는 오늘도 비트코인을 산다",
            titleEnglish: nil,
            author: "Various",
            category: .general,
            description: "DCA(Dollar Cost Averaging, 적립식 투자) 전략의 이점을 설명한 책. 시장 타이밍을 맞추려 하지 않고 정기적으로 일정 금액을 비트코인에 투자하는 전략이 왜 장기적으로 효과적인지, 변동성을 극복하고 평균 매입 단가를 낮추는 원리를 설명한다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 19,
            titleKorean: "비트코인, 초제국의 종말",
            titleEnglish: nil,
            author: "Various",
            category: .general,
            description: "금융 억압과 비트코인의 주권 자유에 대한 책. 중앙은행과 정부가 화폐 통제를 통해 시민의 경제적 자유를 어떻게 제한하는지 분석하고, 비트코인이 개인에게 금융 주권을 되찾아주는 도구가 될 수 있음을 주장한다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 20,
            titleKorean: "사토시의 서",
            titleEnglish: "The Book of Satoshi",
            author: "Phil Champagne",
            category: .general,
            description: "사토시 나카모토의 공개 글 모음집. 2008년 말부터 2010년 말까지의 포럼 글, 이메일, 백서를 시간순으로 정리했다. 탈중앙화 철학, 작업증명, 이중지불 방지, 2100만 개 공급 한정, 프라이버시 등 비트코인 설계의 '왜'를 창시자의 말로 직접 이해할 수 있다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 21,
            titleKorean: "프로그래밍 비트코인",
            titleEnglish: "Programming Bitcoin",
            author: "Jimmy Song",
            category: .general,
            description: "파이썬으로 비트코인을 처음부터 구현하는 실습서. 유한체, 타원곡선 암호, 트랜잭션, 스크립트, 블록, 네트워킹, SPV, SegWit까지 14개 챕터로 구성된다. 수학적 기초부터 시작해 직접 코드를 작성하며 비트코인의 내부 작동을 깊이 이해할 수 있다.",
            hasPdf: false
        ),
        BitcoinBook(
            id: 22,
            titleKorean: "비트코인, 공개 블록체인 프로그래밍",
            titleEnglish: nil,
            author: "Various",
            category: .general,
            description: "비트코인 코드의 이론과 실습을 다루는 책. 블록체인 데이터 구조, 합의 알고리즘, 스마트 컨트랙트 기초, 노드 운영 등 비트코인 프로토콜을 직접 다루고 싶은 개발자를 위한 기술서.",
            hasPdf: false
        )
    ]
    
    static func books(for category: BookCategory) -> [BitcoinBook] {
        allBooks.filter { $0.category == category }
    }
}

// MARK: - YouTuber Region
enum YouTuberRegion: String, CaseIterable {
    case korean = "Korean"
    case international = "International"
    
    var localizedTitle: String {
        switch self {
        case .korean: return L10n.koreanYoutubers
        case .international: return L10n.internationalYoutubers
        }
    }
    
    var icon: String {
        switch self {
        case .korean: return "flag.fill"
        case .international: return "globe"
        }
    }
}

// MARK: - Bitcoin YouTuber
struct BitcoinYouTuber: Identifiable {
    let id = UUID()
    let name: String
    let channelUrl: URL
    let region: YouTuberRegion
    let description: String
    let focus: [String]
    
    static let allYouTubers: [BitcoinYouTuber] = [
        // Korean YouTubers (국내) - Atomic Bitcoin 추천 리스트 (트윗에서 핸들 확인된 채널만)
        BitcoinYouTuber(
            name: "아토믹⚡️비트코인",
            channelUrl: URL(string: "https://www.youtube.com/@atomicBTC")!,
            region: .korean,
            description: "비트코인 온라인 교육, 커뮤니티, BTC 결제 매장 지도",
            focus: ["Education", "Community", "Self-Custody"]
        ),
        BitcoinYouTuber(
            name: "신박한 신박사",
            channelUrl: URL(string: "https://www.youtube.com/@AmazingDrShin")!,
            region: .korean,
            description: "비트코인 교양채널 - 경제, 철학, 사상, 정치, 역사, 과학, 종교 주제",
            focus: ["Philosophy", "Education", "Culture"]
        ),
        BitcoinYouTuber(
            name: "네딸바 NL daughter's daddy",
            channelUrl: URL(string: "https://www.youtube.com/@네딸바")!,
            region: .korean,
            description: "비트코인에 대한 제대로된 이해를 돕는 채널",
            focus: ["Education", "Understanding"]
        ),
        BitcoinYouTuber(
            name: "1분 비트코인",
            channelUrl: URL(string: "https://www.youtube.com/@1min_bitcoin")!,
            region: .korean,
            description: "한국인들의 올바른 비트코인 인식을 위한 영상",
            focus: ["Education", "Quick Learn"]
        ),
        BitcoinYouTuber(
            name: "리스펙 투자플랜",
            channelUrl: URL(string: "https://www.youtube.com/channel/UC1f_j9wOASvYAvADpwTXT0Q")!,
            region: .korean,
            description: "장기적 우상향 자산 투자, 경제적 자립과 시공간의 자유",
            focus: ["Investment", "Strategy", "Long-term"]
        ),
        BitcoinYouTuber(
            name: "오리지널 마인드",
            channelUrl: URL(string: "https://www.youtube.com/channel/UCp_rNzCrqgK_n6pNLJ9f0VA")!,
            region: .korean,
            description: "남다른 생각을 갖고있는 사람들의 이야기",
            focus: ["Interviews", "Ideas"]
        ),
        BitcoinYouTuber(
            name: "사운드머니TV",
            channelUrl: URL(string: "https://www.youtube.com/@thesoundmoney")!,
            region: .korean,
            description: "건전화폐의 팬으로서 비트코인 맥시멀리즘의 유혹을 받는 채널",
            focus: ["Sound Money", "Savings"]
        ),
        BitcoinYouTuber(
            name: "지분전쟁⚡️상원수",
            channelUrl: URL(string: "https://www.youtube.com/@btc5000k")!,
            region: .korean,
            description: "비트코인 투자 및 분석",
            focus: ["Investment", "Analysis"]
        ),
        BitcoinYouTuber(
            name: "하워드의 투자생각",
            channelUrl: URL(string: "https://www.youtube.com/@invest_think")!,
            region: .korean,
            description: "투자에 대한 생각과 비트코인 분석",
            focus: ["Investment", "Thinking"]
        ),
        BitcoinYouTuber(
            name: "유노나띵옛",
            channelUrl: URL(string: "https://www.youtube.com/@mr.W.Investor")!,
            region: .korean,
            description: "비트코인 투자 전략",
            focus: ["Investment", "Strategy"]
        ),
        BitcoinYouTuber(
            name: "리버스온 ReBirth:ON",
            channelUrl: URL(string: "https://www.youtube.com/@ReBirth_ON")!,
            region: .korean,
            description: "비트코인 교육 및 분석",
            focus: ["Education", "Analysis"]
        ),
        
        // International YouTubers (해외)
        BitcoinYouTuber(
            name: "Patryk Denari",
            channelUrl: URL(string: "https://www.youtube.com/@PatrykDenari")!,
            region: .international,
            description: "Bitcoin education and analysis",
            focus: ["Education", "Analysis"]
        ),
        BitcoinYouTuber(
            name: "aantonop",
            channelUrl: URL(string: "https://www.youtube.com/@aantonop")!,
            region: .international,
            description: "비트코인 철학, 탈중앙화, 기술적 기반 및 안전성 심층 설명",
            focus: ["Philosophy", "Technical", "Education"]
        ),
        BitcoinYouTuber(
            name: "Coin Bureau",
            channelUrl: URL(string: "https://www.youtube.com/@CoinBureau")!,
            region: .international,
            description: "깊이 있는 연구, 펀더멘털 중심 분석, 시장 전체 흐름",
            focus: ["Fundamentals", "Research", "Analysis"]
        ),
        BitcoinYouTuber(
            name: "Benjamin Cowen",
            channelUrl: URL(string: "https://www.youtube.com/@intothecryptoverse")!,
            region: .international,
            description: "가격 사이클, 역사적 패턴, 수학적 모델 기반 분석",
            focus: ["Data Analysis", "Cycles", "Long-term"]
        ),
        BitcoinYouTuber(
            name: "99Bitcoins",
            channelUrl: URL(string: "https://www.youtube.com/@99Bitcoins")!,
            region: .international,
            description: "초보자에게 친숙하고 이해하기 쉬운 비트코인 설명",
            focus: ["Beginners", "Tutorials", "Basics"]
        ),
        BitcoinYouTuber(
            name: "The Moon Show",
            channelUrl: URL(string: "https://www.youtube.com/@TheMoon")!,
            region: .international,
            description: "비트코인 가격 분석, 트렌드, 매크로 요인 분석",
            focus: ["Price Analysis", "Trends", "Macro"]
        ),
        BitcoinYouTuber(
            name: "DataDash",
            channelUrl: URL(string: "https://www.youtube.com/@DataDash")!,
            region: .international,
            description: "암호화폐와 전통 금융/경제 테마를 연결한 분석",
            focus: ["Macro", "Traditional Finance", "Analysis"]
        )
    ]
    
    static func youtubers(for region: YouTuberRegion) -> [BitcoinYouTuber] {
        allYouTubers.filter { $0.region == region }
    }
}
