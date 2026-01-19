//
//  SecurityChecklistView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import SwiftUI

struct SecurityChecklistView: View {
    @State private var checkItems: [SecurityCheckItem] = SecurityCheckItem.allItems
    @State private var selectedItem: SecurityCheckItem?
    
    private var completedCount: Int {
        checkItems.filter { $0.isCompleted }.count
    }
    
    private var progress: Double {
        Double(completedCount) / Double(checkItems.count)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Progress Card
                progressCard
                
                // Checklist Items
                ForEach(Array(checkItems.enumerated()), id: \.element.id) { index, item in
                    SecurityCheckCard(
                        item: item,
                        onToggle: {
                            withAnimation(.spring(response: 0.3)) {
                                checkItems[index].isCompleted.toggle()
                            }
                        },
                        onTap: {
                            selectedItem = item
                        }
                    )
                }
                
                // Reset Button
                if completedCount > 0 {
                    Button(action: resetChecklist) {
                        Text("Reset Checklist")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.lossRed)
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
        .background(AppColors.primaryBackground)
        .navigationTitle("Security Checklist")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedItem) { item in
            SecurityItemDetailSheet(item: item)
        }
    }
    
    private var progressCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Progress")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("\(completedCount) of \(checkItems.count) completed")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                // Circular Progress
                ZStack {
                    Circle()
                        .stroke(AppColors.secondaryText.opacity(0.2), lineWidth: 6)
                        .frame(width: 56, height: 56)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(progressColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.5), value: progress)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(progressColor)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.secondaryText.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.spring(response: 0.5), value: progress)
                }
            }
            .frame(height: 8)
            
            // Status Message
            Text(statusMessage)
                .font(.system(size: 13))
                .foregroundColor(progressColor)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var progressColor: Color {
        switch progress {
        case 0..<0.33: return AppColors.lossRed
        case 0.33..<0.66: return AppColors.neutralYellow
        case 0.66..<1.0: return AppColors.profitGreen
        default: return AppColors.profitGreen
        }
    }
    
    private var statusMessage: String {
        switch progress {
        case 0: return "Start securing your Bitcoin!"
        case 0..<0.33: return "Good start! Keep going."
        case 0.33..<0.66: return "Making progress! Almost there."
        case 0.66..<1.0: return "Great job! Just a few more steps."
        default: return "Excellent! Your Bitcoin is well secured!"
        }
    }
    
    private func resetChecklist() {
        withAnimation(.spring(response: 0.3)) {
            for index in checkItems.indices {
                checkItems[index].isCompleted = false
            }
        }
    }
}

// MARK: - Security Check Card
struct SecurityCheckCard: View {
    let item: SecurityCheckItem
    let onToggle: () -> Void
    let onTap: () -> Void
    
    private var importanceColor: Color {
        switch item.importance {
        case .critical: return AppColors.lossRed
        case .high: return AppColors.bitcoinOrange
        case .medium: return AppColors.neutralYellow
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(item.isCompleted ? AppColors.profitGreen : AppColors.secondaryText)
            }
            
            // Content
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(item.title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(item.isCompleted ? AppColors.secondaryText : AppColors.primaryText)
                            .strikethrough(item.isCompleted)
                        
                        Text(item.importance.rawValue)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(importanceColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(importanceColor.opacity(0.15))
                            .cornerRadius(4)
                    }
                    
                    Text(item.description)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.tertiaryText)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "info.circle")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.tertiaryText)
            }
        }
        .padding()
        .background(item.isCompleted ? AppColors.cardBackground.opacity(0.5) : AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .stroke(item.isCompleted ? AppColors.profitGreen.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Security Item Detail Sheet
struct SecurityItemDetailSheet: View {
    let item: SecurityCheckItem
    @Environment(\.dismiss) private var dismiss
    
    private var importanceColor: Color {
        switch item.importance {
        case .critical: return AppColors.lossRed
        case .high: return AppColors.bitcoinOrange
        case .medium: return AppColors.neutralYellow
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 48))
                            .foregroundColor(importanceColor)
                        
                        Text(item.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppColors.primaryText)
                            .multilineTextAlignment(.center)
                        
                        Text(item.importance.rawValue)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(importanceColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(importanceColor.opacity(0.15))
                            .cornerRadius(12)
                    }
                    .padding()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Why This Matters")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                        
                        Text(item.description)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppLayout.cornerRadius)
                    .padding(.horizontal)
                    
                    // Tips
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tips")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                        
                        ForEach(item.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.neutralYellow)
                                    .padding(.top, 2)
                                
                                Text(tip)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.secondaryText)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppLayout.cornerRadius)
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

#Preview {
    NavigationStack {
        SecurityChecklistView()
    }
    .preferredColorScheme(.dark)
}
