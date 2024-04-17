//
//  GameState.swift
//  Asteroids 1D
//
//  Created by Cameron Reese on 4/16/24.
//

import SwiftUI
import SpriteKit

struct GameState {
    let ship: Ship
    var currentAsteroid: Asteroid? = nil
    var numberOfAsteroidsDestroyed: Int = 0
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
