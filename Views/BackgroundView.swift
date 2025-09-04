//
//  BackgroundView.swift
//  PantryPal
//
//  Created by sanjay kumar Bairi on 9/3/25.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            // Main gradient background
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.1),
                    Color.yellow.opacity(0.05),
                    Color.green.opacity(0.05),
                    Color.blue.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Floating geometric shapes
            GeometryReader { geometry in
                ZStack {
                    // Large circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.orange.opacity(0.1), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .offset(x: -100, y: -150)
                        .blur(radius: 20)
                    
                    // Medium circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.blue.opacity(0.08), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .offset(x: geometry.size.width - 100, y: geometry.size.height - 200)
                        .blur(radius: 15)
                    
                    // Small circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.green.opacity(0.08), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .offset(x: geometry.size.width - 50, y: 100)
                        .blur(radius: 10)
                    
                    // Decorative dots pattern
                    ForEach(0..<20, id: \.self) { index in
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: CGFloat.random(in: 2...6), height: CGFloat.random(in: 2...6))
                            .offset(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                    }
                }
            }
            
            // Subtle texture overlay
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.02),
                            Color.clear,
                            Color.white.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .ignoresSafeArea()
    }
}

struct GlassmorphismCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

struct AnimatedGradientButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    let isPrimary: Bool
    
    @State private var isPressed = false
    
    init(title: String, icon: String, isPrimary: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isPrimary = isPrimary
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isPrimary ? .white : .orange)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if isPrimary {
                        LinearGradient(
                            colors: [.orange, .orange.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isPrimary ? Color.clear : Color.orange, lineWidth: 2)
            )
            .cornerRadius(20)
            .shadow(
                color: isPrimary ? .orange.opacity(0.3) : .clear,
                radius: isPressed ? 5 : 15,
                x: 0,
                y: isPressed ? 2 : 8
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [.orange, .orange.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(
                    color: .orange.opacity(0.4),
                    radius: isPressed ? 8 : 20,
                    x: 0,
                    y: isPressed ? 4 : 10
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        BackgroundView()
        
        VStack(spacing: 20) {
            GlassmorphismCard {
                Text("Glassmorphism Card")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            AnimatedGradientButton(title: "Primary Button", icon: "plus.circle.fill") {
                print("Primary button tapped")
            }
            
            AnimatedGradientButton(title: "Secondary Button", icon: "gear", isPrimary: false) {
                print("Secondary button tapped")
            }
            
            FloatingActionButton(icon: "plus") {
                print("FAB tapped")
            }
        }
        .padding()
    }
}

