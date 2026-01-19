//
//  SelfCustodyGuideView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import SwiftUI

struct SelfCustodyGuideView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var expandedSection: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Introduction
                introSection
                
                // Guide Sections
                ForEach(GuideSection.localizedSections) { section in
                    GuideSectionCard(
                        section: section,
                        isExpanded: expandedSection == section.id,
                        onTap: {
                            withAnimation(.spring(response: 0.3)) {
                                if expandedSection == section.id {
                                    expandedSection = nil
                                } else {
                                    expandedSection = section.id
                                }
                            }
                        }
                    )
                }
                
                // Important reminder
                reminderSection
            }
            .padding()
        }
        .background(AppColors.primaryBackground)
        .navigationTitle(L10n.selfCustodyNavTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var introSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "key.fill")
                .font(.system(size: 40))
                .foregroundColor(AppColors.bitcoinOrange)
            
            Text(L10n.takeControl)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            Text(L10n.selfCustodyIntro)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var reminderSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(AppColors.neutralYellow)
                Text(L10n.remember)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ReminderBullet(text: L10n.reminderSeedPhrase)
                ReminderBullet(text: L10n.reminderVerifyAddress)
                ReminderBullet(text: L10n.reminderTestBackup)
                ReminderBullet(text: L10n.reminderKeepUpdated)
            }
        }
        .padding()
        .background(AppColors.lossRed.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .stroke(AppColors.lossRed.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(AppLayout.cornerRadius)
    }
}

// MARK: - Guide Section Card
struct GuideSectionCard: View {
    let section: GuideSection
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header (always visible)
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Image(systemName: section.icon)
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.bitcoinOrange)
                        .frame(width: 40, height: 40)
                        .background(AppColors.bitcoinOrange.opacity(0.15))
                        .cornerRadius(10)
                    
                    Text(section.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.tertiaryText)
                }
                .padding()
            }
            
            // Expandable content
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider()
                        .background(AppColors.secondaryText.opacity(0.3))
                    
                    Text(section.content)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Key Points
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.keyPoints)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                        
                        ForEach(section.keyPoints, id: \.self) { point in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.profitGreen)
                                    .padding(.top, 2)
                                
                                Text(point)
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.secondaryText)
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.profitGreen.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding([.horizontal, .bottom])
            }
        }
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
}

// MARK: - Reminder Bullet
struct ReminderBullet: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(AppColors.neutralYellow)
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppColors.primaryText)
        }
    }
}

#Preview {
    NavigationStack {
        SelfCustodyGuideView()
    }
    .preferredColorScheme(.dark)
}
