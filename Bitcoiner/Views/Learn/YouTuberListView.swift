//
//  YouTuberListView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import SwiftUI

struct YouTuberListView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedRegion: YouTuberRegion = .korean
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Region Picker
                regionPicker
                
                // YouTubers List
                LazyVStack(spacing: 12) {
                    ForEach(BitcoinYouTuber.youtubers(for: selectedRegion)) { youtuber in
                        YouTuberCard(youtuber: youtuber)
                    }
                }
            }
            .padding()
        }
        .background(AppColors.primaryBackground)
        .navigationTitle(L10n.youtubeChannels)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var regionPicker: some View {
        HStack(spacing: 12) {
            ForEach(YouTuberRegion.allCases, id: \.self) { region in
                RegionButton(
                    title: region.localizedTitle,
                    icon: region.icon,
                    isSelected: selectedRegion == region,
                    count: BitcoinYouTuber.youtubers(for: region).count
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedRegion = region
                    }
                }
            }
        }
    }
}

// MARK: - Region Button
struct RegionButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                
                Text("\(count)")
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.2) : AppColors.tertiaryText.opacity(0.3))
                    .cornerRadius(8)
            }
            .foregroundColor(isSelected ? .white : AppColors.secondaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? AppColors.lossRed : AppColors.cardBackground)
            .cornerRadius(20)
        }
    }
}

// MARK: - YouTuber Card
struct YouTuberCard: View {
    let youtuber: BitcoinYouTuber
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Button(action: {
            openURL(youtuber.channelUrl)
        }) {
            HStack(spacing: 16) {
                // YouTube Icon
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppColors.lossRed)
                    .frame(width: 56, height: 56)
                    .background(AppColors.lossRed.opacity(0.15))
                    .cornerRadius(12)
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(youtuber.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(youtuber.description)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(2)
                    
                    // Focus Tags
                    HStack(spacing: 6) {
                        ForEach(youtuber.focus.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppColors.bitcoinOrange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppColors.bitcoinOrange.opacity(0.15))
                                .cornerRadius(6)
                        }
                    }
                }
                
                Spacer()
                
                // Open Link Icon
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.tertiaryText)
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(AppLayout.cornerRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        YouTuberListView()
    }
    .preferredColorScheme(.dark)
}
