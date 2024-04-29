//
//  ContentView.swift
//  Asteroids 1D
//
//  Created by Cameron Reese on 4/16/24.
//
import SpriteKit
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @EnvironmentObject() var gameState: GameState
    
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
    
    var scene: SKScene {
        let scene = GameScene(gameState: gameState)
        scene.view?.showsPhysics = true // Show physics debug information
        scene.size = UIScreen.main.bounds.size // Set scene size to match screen size
        scene.scaleMode = .aspectFill // Fill the entire scene with the contents
        return scene
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            // Overlay a Text view
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
                    }
                    Spacer()
                    VStack {
                        Text("\(gameState.ship.currentHealth)")
                            .foregroundColor(.green)
                            .font(.system(size: 72))
                        Text("Ship Health")
                            .foregroundColor(.green)
                            .font(.subheadline)
                            .padding(.horizontal)
                    }
                }

                Spacer()
            }
            
            Text(gameText)
                .foregroundColor(gameTextColor)
                .font(.title)
                .fontWeight(.bold)
                .padding()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameState(ship: Ship(node: SKSpriteNode(imageNamed: "Ship"))))
        .modelContainer(for: Item.self, inMemory: true)
}
