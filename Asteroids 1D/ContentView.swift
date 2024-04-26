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
                        Text("42")
                            .foregroundColor(.blue)
                            .font(.system(size: 72))
                        Text("Asteroids Destroyed")
                            .foregroundColor(.blue)
                            .font(.subheadline)
                            .padding(.horizontal)
                    }
                    Spacer()
                    VStack {
                        Text("10")
                            .foregroundColor(.green)
                            .font(.system(size: 72))
                        Text("Ship Health")
                            .foregroundColor(.green)
                            .font(.subheadline)
                            .padding(.horizontal)
                    }

                    Spacer()
                }

                Spacer()
            }
        }
        .onAppear {
            self.gameState = GameState(ship: Ship(node: SKSpriteNode(imageNamed: "Ship")))
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
