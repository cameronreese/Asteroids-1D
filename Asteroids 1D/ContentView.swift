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
    
    var scene: SKScene {
        let scene = GameScene()
        scene.view?.showsPhysics = true // Show physics debug information
        scene.size = UIScreen.main.bounds.size // Set scene size to match screen size
        scene.scaleMode = .aspectFill // Fill the entire scene with the contents
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
