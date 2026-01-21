//
//  BitcoinNews.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/22/26.
//

import Foundation

// MARK: - Bitcoin News Model
struct BitcoinNews: Identifiable, Codable {
    let id: String
    let title: String
    let url: String
    let source: String
    let publishedAt: Date
    let imageUrl: String?
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: publishedAt, relativeTo: Date())
    }
}

// MARK: - CryptoCompare API Response
struct CryptoCompareNewsResponse: Codable {
    let Data: [CryptoCompareNewsItem]
    
    struct CryptoCompareNewsItem: Codable {
        let id: String
        let title: String
        let url: String
        let source: String
        let published_on: Int
        let imageurl: String?
        
        func toNews() -> BitcoinNews {
            BitcoinNews(
                id: id,
                title: title,
                url: url,
                source: source,
                publishedAt: Date(timeIntervalSince1970: TimeInterval(published_on)),
                imageUrl: imageurl
            )
        }
    }
}
