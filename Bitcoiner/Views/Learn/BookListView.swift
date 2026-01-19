//
//  BookListView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import SwiftUI

struct BookListView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedCategory: BookCategory = .essential
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Category Picker
                categoryPicker
                
                // Books List
                LazyVStack(spacing: 12) {
                    ForEach(BitcoinBook.books(for: selectedCategory)) { book in
                        BookCard(book: book)
                    }
                }
            }
            .padding()
        }
        .background(AppColors.primaryBackground)
        .navigationTitle(L10n.bitcoinBooks)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var categoryPicker: some View {
        HStack(spacing: 12) {
            ForEach(BookCategory.allCases, id: \.self) { category in
                CategoryButton(
                    title: category.localizedTitle,
                    icon: category.icon,
                    isSelected: selectedCategory == category,
                    count: BitcoinBook.books(for: category).count
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
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
            .background(isSelected ? AppColors.bitcoinOrange : AppColors.cardBackground)
            .cornerRadius(20)
        }
    }
}

// MARK: - Book Card
struct BookCard: View {
    let book: BitcoinBook
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top, spacing: 12) {
                // Book Number
                Text("\(book.id)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(book.category == .essential ? AppColors.bitcoinOrange : AppColors.profitGreen)
                    .cornerRadius(8)
                
                // Book Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.titleKorean)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                        .lineLimit(2)
                    
                    if let englishTitle = book.titleEnglish {
                        Text(englishTitle)
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.tertiaryText)
                            .italic()
                    }
                    
                    Text(book.author)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                // Badges
                VStack(spacing: 4) {
                    if book.hasPdf {
                        Text("PDF")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.profitGreen)
                            .cornerRadius(6)
                    }
                    
                    // Expand Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                }
            }
            
            // Description (Expanded)
            if isExpanded {
                Text(book.description)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
                    .padding(.leading, 40)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
}

#Preview {
    NavigationStack {
        BookListView()
    }
    .preferredColorScheme(.dark)
}
