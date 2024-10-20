//
//  OverlayView.swift
//  Asteroids 1D
//
//  Created by Cameron Reese on 10/19/24.
//
import SwiftUI
import SpriteKit

struct OverlayView: View {
    @ObservedObject var gameState: GameState
    
    var gameText: String {
        switch gameState.gameSequence {
        case .start:
            return "Tap to start"
        case .gameInProgress:
            return ""
        case .gameOver:
            return "Game Over"
        }
    }
    
    var gameTextColor: Color {
        switch gameState.gameSequence {
        case .start:
            return .gray
        case .gameInProgress:
            return .clear
        case .gameOver:
            return .red
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("\(gameState.numberOfAsteroidsDestroyed)")
                        .foregroundColor(.blue)
                        .font(.system(size: 72))
                    Text("Asteroids")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                        .padding(.horizontal)
                    Text("Destroyed")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                        .padding(.horizontal)
                    Text("Asteroid Health: \(gameState.currentAsteroid?.currentHealth ?? 0)%")
                        .foregroundColor(.blue)
                        .font(.body)
                        .padding()
                    Spacer()
                }
                Spacer()
                VStack {
                    Text("Ship Health")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.headline)
                        .padding(.horizontal)
                    VerticalHealthBarView(currentHealth: $gameState.ship.currentHealth.animation(.easeOut(duration: 1)), maxHealth: gameState.ship.maxHealth, barHeight: 120)
                    Spacer()
                }
            }
            Spacer()
            if gameState.numberOfEvasiveManeuvers > 0 && gameState.gameSequence == .gameInProgress {
                Text("Evasive Maneuvers: \(gameState.numberOfEvasiveManeuvers) of \(maxNumberOfEnvasiveManeuvers) allowed")
                    .foregroundStyle(.red)
                    .font(.subheadline)
                    .padding(.horizontal)
            }
        }
                    
        Text(gameText)
            .foregroundColor(gameTextColor)
            .font(.title)
            .fontWeight(.bold)
            .padding()
        }
}


#Preview {
    ZStack {
        OverlayView(gameState: GameState(ship: Ship(node: SKSpriteNode(imageNamed: "Ship"))))
    }
        .background(Color.black.opacity(0.8).ignoresSafeArea(.all))
}

