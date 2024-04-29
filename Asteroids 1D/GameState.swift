//
//  GameState.swift
//  Asteroids 1D
//
//  Created by Cameron Reese on 4/16/24.
//

import SwiftUI
import SpriteKit

let defaultHealth = 100

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
    @Published var gameSequence: GameSequence = .start
    let difficultyLevel: DifficultyLevel = .medium
}

protocol GameItem {
    var node: SKSpriteNode { get }
    var maxHealth: Int { get }
    var currentHealth: Int { get set }
}

struct Ship: GameItem  {
    let node: SKSpriteNode
    let maxHealth: Int = defaultHealth
    var currentHealth: Int = defaultHealth
    
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
    var maxHealth: Int = defaultHealth
    
    var node: SKSpriteNode
    
    var currentHealth: Int = defaultHealth
}

struct Explosive: GameItem {
    var maxHealth: Int = 1
    
    var node: SKSpriteNode
    
    var currentHealth: Int = 1
}

struct Missile: GameItem {
    var maxHealth: Int = 1
    
    var node: SKSpriteNode
    
    var currentHealth: Int = 1
}

enum Projectile {
    case explosive,
         missile
}

enum GameSequence {
    case start,
         gameInProgress,
         gameOver
}

enum DifficultyLevel: Double {
    case easy = 2.5,
         medium = 2.0,
         hard = 1.5,
         insane = 1.0
}
