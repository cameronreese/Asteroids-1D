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
    @Published var currentExplosive: Explosive? = nil
    @Published var currentMissile: Missile? = nil
    @Published var numberOfAsteroidsDestroyed: Int = 0
    @Published var numberOfEvasiveManeuvers: Int = 0
    @Published var numberOfMissilesFired: Int = 0
    @Published var numberOfExplosivesFired: Int = 0
    @Published var numberOfAsteroidsSpawned: Int = 0
    
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
            self.chamber = .missile
            return .explosive
        case .missile:
            self.chamber = .explosive
            return .missile
        }
    }
}

struct Asteroid: GameItem {
    var node: SKSpriteNode
    
    var health: Int
}

struct Explosive: GameItem {
    var node: SKSpriteNode
    
    var health: Int
}

struct Missile: GameItem {
    var node: SKSpriteNode
    
    var health: Int
}

enum Projectile {
    case explosive,
         missile
}
