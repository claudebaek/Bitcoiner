//
//  WalletListView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import SwiftUI

struct WalletListView: View {
    @State private var selectedType: WalletType = .hardware
    @State private var selectedWallet: Wallet?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Type Selector
                walletTypeSelector
                
                // Type Description
                typeDescription
                
                // Wallet List
                ForEach(Wallet.wallets(for: selectedType)) { wallet in
                    WalletCard(wallet: wallet) {
                        selectedWallet = wallet
                    }
                }
                
                // Legend
                legendSection
            }
            .padding()
        }
        .background(AppColors.primaryBackground)
        .navigationTitle("Wallets")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedWallet) { wallet in
            WalletDetailSheet(wallet: wallet)
        }
    }
    
    private var walletTypeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(WalletType.allCases, id: \.self) { type in
                    WalletTypeButton(
                        type: type,
                        isSelected: selectedType == type,
                        onTap: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedType = type
                            }
                        }
                    )
                }
            }
        }
    }
    
    private var typeDescription: some View {
        HStack(spacing: 12) {
            Image(systemName: selectedType.icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.bitcoinOrange)
            
            Text(selectedType.description)
                .font(.system(size: 13))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var legendSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Legend")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            HStack(spacing: 16) {
                WalletLegendItem(icon: "lock.open.fill", text: "Open Source", color: AppColors.profitGreen)
                WalletLegendItem(icon: "bitcoinsign.circle.fill", text: "Bitcoin Only", color: AppColors.bitcoinOrange)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
}

// MARK: - Wallet Type Button
struct WalletTypeButton: View {
    let type: WalletType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.system(size: 12))
                
                Text(type.rawValue)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .black : AppColors.primaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? AppColors.bitcoinOrange : AppColors.cardBackground)
            .cornerRadius(20)
        }
    }
}

// MARK: - Wallet Card
struct WalletCard: View {
    let wallet: Wallet
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                Image(systemName: wallet.icon)
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.bitcoinOrange)
                    .frame(width: 50, height: 50)
                    .background(AppColors.bitcoinOrange.opacity(0.15))
                    .cornerRadius(12)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(wallet.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                        
                        if wallet.isOpenSource {
                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 10))
                                .foregroundColor(AppColors.profitGreen)
                        }
                        
                        if wallet.isBitcoinOnly {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(AppColors.bitcoinOrange)
                        }
                    }
                    
                    Text(wallet.description)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.tertiaryText)
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(AppLayout.cornerRadius)
        }
    }
}

// MARK: - Wallet Legend Item
struct WalletLegendItem: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(AppColors.secondaryText)
        }
    }
}

// MARK: - Wallet Detail Sheet
struct WalletDetailSheet: View {
    let wallet: Wallet
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: wallet.icon)
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.bitcoinOrange)
                        
                        Text(wallet.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.primaryText)
                        
                        HStack(spacing: 8) {
                            TypeBadge(text: wallet.type.rawValue, color: AppColors.bitcoinOrange)
                            
                            if wallet.isOpenSource {
                                TypeBadge(text: "Open Source", color: AppColors.profitGreen)
                            }
                            
                            if wallet.isBitcoinOnly {
                                TypeBadge(text: "Bitcoin Only", color: AppColors.neutralYellow)
                            }
                        }
                        
                        Text(wallet.description)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Features
                    DetailSection(title: "Features", items: wallet.features, icon: "star.fill", color: AppColors.bitcoinOrange)
                    
                    // Pros
                    DetailSection(title: "Pros", items: wallet.pros, icon: "checkmark.circle.fill", color: AppColors.profitGreen)
                    
                    // Cons
                    DetailSection(title: "Cons", items: wallet.cons, icon: "xmark.circle.fill", color: AppColors.lossRed)
                    
                    // Website Button
                    Link(destination: wallet.url) {
                        HStack {
                            Image(systemName: "globe")
                            Text("Visit Official Website")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.bitcoinOrange)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 32)
            }
            .background(AppColors.primaryBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.bitcoinOrange)
                }
            }
        }
    }
}

// MARK: - Type Badge
struct TypeBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .cornerRadius(12)
    }
}

// MARK: - Detail Section
struct DetailSection: View {
    let title: String
    let items: [String]
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: icon)
                            .font(.system(size: 12))
                            .foregroundColor(color)
                            .padding(.top, 2)
                        
                        Text(item)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        WalletListView()
    }
    .preferredColorScheme(.dark)
}
