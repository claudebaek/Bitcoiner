//
//  LaunchScreenView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.8
    @State private var ringRotation: Double = 0
    @State private var quoteOpacity: Double = 0
    
    private let quote = BitcoinQuote.random
    
    var body: some View {
        ZStack {
            // Background gradient
            RadialGradient(
                colors: [
                    Color(hex: "1A1A1A"),
                    AppColors.primaryBackground
                ],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Logo with glow effect
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppColors.bitcoinOrange.opacity(0.6),
                                    AppColors.bitcoinOrange.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(ringScale)
                        .opacity(glowOpacity)
                        .rotationEffect(.degrees(ringRotation))
                    
                    // Inner glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.bitcoinOrange.opacity(0.3),
                                    AppColors.bitcoinOrange.opacity(0)
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .opacity(glowOpacity)
                    
                    // Bitcoin logo circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFB347"),
                                    AppColors.bitcoinOrange,
                                    Color(hex: "D47800")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: AppColors.bitcoinOrange.opacity(0.5), radius: 20)
                    
                    // Bitcoin symbol
                    BitcoinSymbol()
                        .fill(.white)
                        .frame(width: 60, height: 80)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // App name
                VStack(spacing: 8) {
                    Text("Bitcoiner")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Real-time Bitcoin Dashboard")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                }
                .opacity(textOpacity)
                
                Spacer()
                
                // Bitcoin Quote
                VStack(spacing: 8) {
                    Text("\"\(quote.quote)\"")
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundColor(AppColors.primaryText)
                        .multilineTextAlignment(.center)
                        .italic()
                    
                    Text("— \(quote.author)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppColors.bitcoinOrange)
                }
                .padding(.horizontal, 40)
                .opacity(quoteOpacity)
                
                Spacer()
                
                // Loading indicator
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(AppColors.bitcoinOrange)
                            .frame(width: 8, height: 8)
                            .scaleEffect(loadingDotScale(for: index))
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: textOpacity
                            )
                    }
                }
                .opacity(textOpacity)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func loadingDotScale(for index: Int) -> CGFloat {
        textOpacity > 0 ? 1.0 : 0.5
    }
    
    private func startAnimations() {
        // Logo scale and fade in
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Glow effect
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            glowOpacity = 1.0
            ringScale = 1.0
        }
        
        // Ring rotation
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
        
        // Text fade in
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            textOpacity = 1.0
        }
        
        // Quote fade in
        withAnimation(.easeOut(duration: 0.8).delay(0.8)) {
            quoteOpacity = 1.0
        }
    }
}

// MARK: - Bitcoin Symbol Shape
struct BitcoinSymbol: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let centerX = rect.midX
        let centerY = rect.midY
        
        let thickness = width * 0.15
        let halfHeight = height * 0.38
        let barExtend = height * 0.12
        
        // Left vertical bar (extending above and below)
        let leftBarX = centerX - width * 0.15
        path.addRect(CGRect(
            x: leftBarX - thickness/2,
            y: centerY - halfHeight - barExtend,
            width: thickness,
            height: halfHeight * 2 + barExtend * 2
        ))
        
        // Right vertical bar
        let rightBarX = centerX + width * 0.1
        path.addRect(CGRect(
            x: rightBarX - thickness/2,
            y: centerY - halfHeight - barExtend,
            width: thickness,
            height: halfHeight * 2 + barExtend * 2
        ))
        
        // B shape - left vertical
        let leftEdge = centerX - width * 0.35
        path.addRect(CGRect(
            x: leftEdge,
            y: centerY - halfHeight,
            width: thickness,
            height: halfHeight * 2
        ))
        
        // Horizontal bars
        let rightExtent = centerX + width * 0.1
        
        // Top bar
        path.addRect(CGRect(
            x: leftEdge,
            y: centerY - halfHeight,
            width: rightExtent - leftEdge,
            height: thickness
        ))
        
        // Middle bar
        path.addRect(CGRect(
            x: leftEdge,
            y: centerY - thickness/2,
            width: rightExtent - leftEdge + width * 0.08,
            height: thickness
        ))
        
        // Bottom bar
        path.addRect(CGRect(
            x: leftEdge,
            y: centerY + halfHeight - thickness,
            width: rightExtent - leftEdge,
            height: thickness
        ))
        
        // Top arc of B
        let topArcCenterY = centerY - halfHeight * 0.45
        let topArcRadius = halfHeight * 0.48
        path.addArc(
            center: CGPoint(x: rightExtent, y: topArcCenterY),
            radius: topArcRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: rightExtent, y: topArcCenterY),
            radius: topArcRadius - thickness,
            startAngle: .degrees(90),
            endAngle: .degrees(-90),
            clockwise: true
        )
        
        // Bottom arc of B (slightly larger)
        let bottomArcCenterY = centerY + halfHeight * 0.45
        let bottomArcRadius = halfHeight * 0.52
        path.addArc(
            center: CGPoint(x: rightExtent + width * 0.03, y: bottomArcCenterY),
            radius: bottomArcRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: rightExtent + width * 0.03, y: bottomArcCenterY),
            radius: bottomArcRadius - thickness,
            startAngle: .degrees(90),
            endAngle: .degrees(-90),
            clockwise: true
        )
        
        return path
    }
}

// MARK: - Preview
#Preview {
    LaunchScreenView()
}
