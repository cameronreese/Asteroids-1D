//
//  GameState.swift
//  Asteroids 1D
//
//  Created by Cameron Reese on 4/16/24.
//

import SwiftUI
import SpriteKit

class GameState: ObservableObject {
    
    init(ship: Ship) {
        self.ship = ship
    }
    
    @Published var ship: Ship
    @Published var currentAsteroid: Asteroid? = nil
    @Published var numberOfAsteroidsDestroyed: Int = 0
}

protocol GameItem {
    var node: SKSpriteNode { get }
    var health: Int { get set }
}

struct Ship: GameItem  {
    let node: SKSpriteNode
    
    var health: Int = 10
    
    var chamber: Projectile = .explosive
    
    mutating func fire() -> Projectile {
        switch self.chamber {
        case .explosive:
            self.chamber = .charge
            return .explosive
        case .charge:
            self.chamber = .explosive
            return .charge
        }
    }
}

struct Asteroid: GameItem {
    var node: SKSpriteNode
    
    var health: Int
}

enum Projectile {
    case explosive,
         charge
}
