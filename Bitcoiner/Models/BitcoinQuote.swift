//
//  BitcoinQuote.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/18/26.
//

import Foundation

struct BitcoinQuote: Identifiable, Codable {
    let id: UUID
    let quote: String
    let author: String
    let role: String?
    let year: Int?
    
    init(id: UUID = UUID(), quote: String, author: String, role: String? = nil, year: Int? = nil) {
        self.id = id
        self.quote = quote
        self.author = author
        self.role = role
        self.year = year
    }
}

// MARK: - Curated Bitcoin Quotes
extension BitcoinQuote {
    static let allQuotes: [BitcoinQuote] = [
        // Satoshi Nakamoto
        BitcoinQuote(
            quote: "If you don't believe it or don't get it, I don't have the time to try to convince you, sorry.",
            author: "Satoshi Nakamoto",
            role: "Bitcoin Creator",
            year: 2010
        ),
        BitcoinQuote(
            quote: "The root problem with conventional currency is all the trust that's required to make it work.",
            author: "Satoshi Nakamoto",
            role: "Bitcoin Creator",
            year: 2009
        ),
        BitcoinQuote(
            quote: "Lost coins only make everyone else's coins worth slightly more. Think of it as a donation to everyone.",
            author: "Satoshi Nakamoto",
            role: "Bitcoin Creator",
            year: 2010
        ),
        
        // Hal Finney
        BitcoinQuote(
            quote: "Running Bitcoin.",
            author: "Hal Finney",
            role: "Bitcoin Pioneer",
            year: 2009
        ),
        BitcoinQuote(
            quote: "Bitcoin seems to be a very promising idea. I like the idea of basing security on the assumption that the CPU power of honest participants outweighs that of the attacker.",
            author: "Hal Finney",
            role: "Bitcoin Pioneer",
            year: 2008
        ),
        
        // Andreas Antonopoulos
        BitcoinQuote(
            quote: "Bitcoin is the internet of money.",
            author: "Andreas Antonopoulos",
            role: "Bitcoin Educator",
            year: 2014
        ),
        BitcoinQuote(
            quote: "Your keys, your bitcoin. Not your keys, not your bitcoin.",
            author: "Andreas Antonopoulos",
            role: "Bitcoin Educator",
            year: 2017
        ),
        BitcoinQuote(
            quote: "Bitcoin is not just money for the internet. It's the internet of money.",
            author: "Andreas Antonopoulos",
            role: "Bitcoin Educator",
            year: 2016
        ),
        BitcoinQuote(
            quote: "In the future, everyone will have their own bank in their pocket.",
            author: "Andreas Antonopoulos",
            role: "Bitcoin Educator",
            year: 2015
        ),
        
        // Michael Saylor
        BitcoinQuote(
            quote: "Bitcoin is a swarm of cyber hornets serving the goddess of wisdom, feeding on the fire of truth, exponentially growing ever smarter, faster, and stronger behind a wall of encrypted energy.",
            author: "Michael Saylor",
            role: "MicroStrategy CEO",
            year: 2020
        ),
        BitcoinQuote(
            quote: "Bitcoin is the most certain thing in an uncertain world.",
            author: "Michael Saylor",
            role: "MicroStrategy CEO",
            year: 2021
        ),
        BitcoinQuote(
            quote: "Bitcoin is digital gold. It's harder, stronger, faster, and smarter than any money that has preceded it.",
            author: "Michael Saylor",
            role: "MicroStrategy CEO",
            year: 2020
        ),
        BitcoinQuote(
            quote: "There is no second best.",
            author: "Michael Saylor",
            role: "MicroStrategy CEO",
            year: 2021
        ),
        
        // Wences Casares
        BitcoinQuote(
            quote: "Right now Bitcoin feels like the Internet before the browser.",
            author: "Wences Casares",
            role: "Xapo CEO",
            year: 2014
        ),
        BitcoinQuote(
            quote: "I have seen the future of money, and it is Bitcoin.",
            author: "Wences Casares",
            role: "Xapo CEO",
            year: 2015
        ),
        
        // Jack Dorsey
        BitcoinQuote(
            quote: "Bitcoin changes absolutely everything.",
            author: "Jack Dorsey",
            role: "Twitter/Block CEO",
            year: 2021
        ),
        BitcoinQuote(
            quote: "Bitcoin will unite a deeply divided country and eventually the world.",
            author: "Jack Dorsey",
            role: "Twitter/Block CEO",
            year: 2021
        ),
        
        // Elon Musk
        BitcoinQuote(
            quote: "Bitcoin is a remarkable cryptographic achievement, and the ability to create something that is not duplicable in the digital world has enormous value.",
            author: "Eric Schmidt",
            role: "Former Google CEO",
            year: 2014
        ),
        
        // Naval Ravikant
        BitcoinQuote(
            quote: "Bitcoin is a tool for freeing humanity from oligarchs and tyrants, dressed up as a get-rich-quick scheme.",
            author: "Naval Ravikant",
            role: "AngelList Co-founder",
            year: 2018
        ),
        BitcoinQuote(
            quote: "Money is the oldest and largest computer network. Bitcoin is the next upgrade.",
            author: "Naval Ravikant",
            role: "AngelList Co-founder",
            year: 2019
        ),
        
        // Nassim Taleb (early supporter)
        BitcoinQuote(
            quote: "Bitcoin is an excellent idea. It fulfills the needs of the complex system, not because it is a cryptocurrency, but precisely because it has no owner, no authority that can decide on its fate.",
            author: "Nassim Taleb",
            role: "Author",
            year: 2018
        ),
        
        // Max Keiser
        BitcoinQuote(
            quote: "Bitcoin is the currency of resistance.",
            author: "Max Keiser",
            role: "Bitcoin Advocate",
            year: 2019
        ),
        
        // Cathie Wood
        BitcoinQuote(
            quote: "Bitcoin is the first global, decentralized, scarce digital asset, and it's a big deal.",
            author: "Cathie Wood",
            role: "ARK Invest CEO",
            year: 2021
        ),
        
        // Ray Dalio
        BitcoinQuote(
            quote: "I think Bitcoin is one hell of an invention.",
            author: "Ray Dalio",
            role: "Bridgewater Associates",
            year: 2021
        ),
        
        // Classic Bitcoin Sayings
        BitcoinQuote(
            quote: "Stay humble, stack sats.",
            author: "Bitcoin Community",
            role: nil,
            year: nil
        ),
        BitcoinQuote(
            quote: "When in doubt, zoom out.",
            author: "Bitcoin Community",
            role: nil,
            year: nil
        ),
        BitcoinQuote(
            quote: "HODL.",
            author: "GameKyuubi",
            role: "Bitcoin Forum User",
            year: 2013
        ),
        BitcoinQuote(
            quote: "The best time to buy Bitcoin was 10 years ago. The second best time is now.",
            author: "Bitcoin Community",
            role: nil,
            year: nil
        ),
        BitcoinQuote(
            quote: "Bitcoin: Be your own bank.",
            author: "Bitcoin Community",
            role: nil,
            year: nil
        ),
        BitcoinQuote(
            quote: "One does not simply sell Bitcoin.",
            author: "Bitcoin Community",
            role: nil,
            year: nil
        ),
        
        // Educational
        BitcoinQuote(
            quote: "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks.",
            author: "Satoshi Nakamoto",
            role: "Genesis Block Message",
            year: 2009
        ),
        BitcoinQuote(
            quote: "Bitcoin is the first money that's engineered to be resistant to political interference.",
            author: "Saifedean Ammous",
            role: "The Bitcoin Standard Author",
            year: 2018
        ),
        BitcoinQuote(
            quote: "Bitcoin is not a company, not an organization, not a stock. It's a protocol, like TCP/IP or the internet.",
            author: "Vijay Boyapati",
            role: "Bitcoin Educator",
            year: 2019
        )
    ]
    
    /// Returns a random quote
    static var random: BitcoinQuote {
        allQuotes.randomElement() ?? allQuotes[0]
    }
    
    /// Returns the quote of the day (consistent for the entire day)
    static var quoteOfTheDay: BitcoinQuote {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % allQuotes.count
        return allQuotes[index]
    }
}
