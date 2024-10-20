//
//  VerticalHealthBar.swift
//  Asteroids 1D
//
//  Created by Cameron Reese on 10/19/24.
//
import SwiftUI

struct VerticalHealthBarView: View {
    @Binding var currentHealth: Int
    var maxHealth: Int
    var barHeight: CGFloat = 100
    
    // Make barWidth a computed property that is a ratio of the barHeight
    var barWidth: CGFloat {
        barHeight / 6
    }
    
    
    // Computed property to calculate the bar color based on the current health
    var barColor: Color {
        if currentHealth <= maxHealth / 4 {
            return .red
        } else if currentHealth <= maxHealth / 2 {
            return .yellow
        } else {
            return .green
        }
    }
    
    // animate the change in health when it changes
    var animation: Animation {
        Animation.easeInOut(duration: 0.5)
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Capsule() // Background capsule
                    .frame(width: barWidth, height: barHeight)
                    .foregroundColor(.gray)
                    .opacity(0.4)
                Capsule() // Outline for background capsule
                    .stroke(lineWidth: 2)
                    .frame(width: barWidth, height: barHeight)
                    .foregroundColor(barColor)
                Capsule() // Foreground capsule
                    .frame(width: barWidth, height: barHeight * CGFloat(currentHealth) / CGFloat(maxHealth))
                    .foregroundColor(barColor)
                    .opacity(0.8)
                    .animation(.easeOut(duration: 0.5), value: currentHealth)
                Capsule() // Foreground capsule glow
                    .frame(width: barWidth, height: barHeight * CGFloat(currentHealth) / CGFloat(maxHealth))                    .foregroundColor(barColor)
                    .blur(radius: 10)
                    .animation(.easeOut(duration: 0.5), value: currentHealth)
            }
        }
    }
}

#Preview {
    HStack {
        Spacer()
        VerticalHealthBarView(currentHealth: Binding(get: { 100 }, set: { _ in }), maxHealth: 100)
        Spacer()
        VerticalHealthBarView(currentHealth: Binding(get: { 50 }, set: { _ in }), maxHealth: 100)
        Spacer()
        VerticalHealthBarView(currentHealth: Binding(get: { 20 }, set: { _ in }), maxHealth: 100)
        Spacer()
    }
    .padding()
    .background(Color.black.opacity(0.8))
    
}
