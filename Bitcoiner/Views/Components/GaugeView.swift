//
//  GaugeView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

// MARK: - Fear & Greed Gauge
struct FearGreedGauge: View {
    let value: Int
    let classification: FearGreedClassification
    @State private var animatedValue: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background arc
                Circle()
                    .trim(from: 0.15, to: 0.85)
                    .stroke(
                        AppColors.secondaryBackground,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(90))
                
                // Gradient arc
                Circle()
                    .trim(from: 0.15, to: 0.15 + (0.7 * animatedValue / 100))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: AppColors.fearGreedGradient),
                            center: .center,
                            startAngle: .degrees(126),
                            endAngle: .degrees(414)
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(90))
                
                // Center content
                VStack(spacing: 4) {
                    Text("\(value)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(classification.color)
                    
                    Text(classification.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(classification.emoji)
                        .font(.system(size: 24))
                }
            }
            .frame(width: 200, height: 200)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedValue = Double(value)
            }
        }
        .onChange(of: value) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedValue = Double(newValue)
            }
        }
    }
}

// MARK: - Long/Short Ratio Gauge
struct LongShortGauge: View {
    let longPercentage: Double
    let shortPercentage: Double
    @State private var animatedLong: Double = 50
    
    var body: some View {
        VStack(spacing: 12) {
            // Bar gauge
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.shortColor)
                    
                    // Long portion
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.longColor)
                        .frame(width: geometry.size.width * (animatedLong / 100))
                }
            }
            .frame(height: 24)
            
            // Labels
            HStack {
                VStack(alignment: .leading) {
                    Text("LONG")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.longColor)
                    Text(String(format: "%.1f%%", longPercentage))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("SHORT")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.shortColor)
                    Text(String(format: "%.1f%%", shortPercentage))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedLong = longPercentage
            }
        }
        .onChange(of: longPercentage) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedLong = newValue
            }
        }
    }
}

// MARK: - Circular Progress Gauge
struct CircularProgressGauge: View {
    let progress: Double
    let title: String
    let color: Color
    let lineWidth: CGFloat
    
    init(progress: Double, title: String, color: Color = AppColors.bitcoinOrange, lineWidth: CGFloat = 8) {
        self.progress = progress
        self.title = title
        self.color = color
        self.lineWidth = lineWidth
    }
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(AppColors.secondaryBackground, lineWidth: lineWidth)
                
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Text(String(format: "%.0f%%", animatedProgress * 100))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
            }
            .frame(width: 60, height: 60)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
                .lineLimit(1)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = min(progress, 1.0)
            }
        }
    }
}

// MARK: - Mini Fear Greed Gauge (for dashboard)
struct MiniFearGreedGauge: View {
    let value: Int
    let classification: FearGreedClassification
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(AppColors.secondaryBackground, lineWidth: 6)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: Double(value) / 100)
                    .stroke(classification.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Text("\(value)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(classification.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Fear & Greed")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                
                Text(classification.rawValue)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(classification.color)
            }
            
            Spacer()
            
            Text(classification.emoji)
                .font(.system(size: 28))
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            FearGreedGauge(value: 72, classification: .greed)
            
            LongShortGauge(longPercentage: 62.5, shortPercentage: 37.5)
                .padding(.horizontal)
            
            HStack {
                CircularProgressGauge(progress: 0.65, title: "Long", color: AppColors.longColor)
                CircularProgressGauge(progress: 0.35, title: "Short", color: AppColors.shortColor)
            }
            
            MiniFearGreedGauge(value: 72, classification: .greed)
                .padding(.horizontal)
        }
        .padding()
    }
    .background(AppColors.primaryBackground)
}
