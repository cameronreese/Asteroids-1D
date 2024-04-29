//
//  GameScene.swift
//  Asteroids 1D
//
//  Created by Cameron Reese on 4/16/24.
//

import SwiftUI
import SpriteKit

class GameScene: SKScene {
    
    init(gameState: GameState) {
        self.gameState = gameState
        super.init(size: UIScreen.main.bounds.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var gameState: GameState
    let shipScale: CGFloat = 0.4

    let explosiveSpeed: TimeInterval = 5 // Smaller is faster
    let missileSpeed: TimeInterval = 1.5 // Smaller is faster
    
    var starsParticles: SKEmitterNode? = nil
    
    override func didMove(to view: SKView) {
        // Create the stars background
        if let stars = SKEmitterNode(fileNamed: "Stars.sks") {
            stars.position = CGPoint(x: self.size.width / 2, y: self.size.height)
            stars.zPosition = -1
            stars.particlePositionRange = CGVector(dx: self.size.width * 2, dy: self.size.height)
            stars.advanceSimulationTime(stars.particleLifetime + stars.particleLifetimeRange) // Pre-fill the screen with stars
            
            starsParticles = stars
            addChild(starsParticles ?? SKEmitterNode())
        }
        
        let movementRange: CGFloat = 2.5 // Adjust as needed
        let tiltAngle: CGFloat = 0.01 // Adjust as needed

        // Set the scale of the ship sprite to make it larger
        gameState.ship.node.setScale(self.shipScale)
        
        gameState.ship.node.zPosition = 1
        
        // Set the ship's position to be centered horizontally and 100 points from the top
        gameState.ship.node.position = CGPoint(x: self.size.width / 2 + movementRange / 2, y: self.size.height / 6)
        gameState.ship.node.zRotation = (tiltAngle / 2) * -1
        
        addChild(gameState.ship.node)
        
        // Set the anchor point of the ship sprite to its center
        gameState.ship.node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Define the movement range and duration for side-to-side movement
        let movementDuration: TimeInterval = 0.8

        // Create the side-to-side movement action
        let moveLeft = SKAction.moveBy(x: -movementRange, y: 0, duration: movementDuration / 2)
        let moveRight = SKAction.moveBy(x: movementRange, y: 0, duration: movementDuration / 2)
        let moveSequence = SKAction.sequence([moveLeft, moveRight])

        // Define the rotation angle and duration for the tilt animation
        let tiltDuration: TimeInterval = movementDuration / 2

        // Create the rotation actions for tilting left and right
        let tiltLeft = SKAction.rotate(byAngle: tiltAngle, duration: tiltDuration)
        let tiltRight = SKAction.rotate(byAngle: -tiltAngle, duration: tiltDuration)
        let tiltSequence = SKAction.sequence([tiltLeft, tiltRight])

        // Combine the movement and rotation actions into a group action
        let groupAction = SKAction.group([moveSequence, tiltSequence])

        // Repeat the group action forever to create continuous animation
        gameState.ship.node.run(SKAction.repeatForever(groupAction))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // If the asteroid comes into contact with the ship, remove the asteroid from the scene
        if let asteroid = gameState.currentAsteroid, gameState.ship.node.intersects(asteroid.node) {
            // Display a temporary label indicating the ship took evasive manuever and diverted away from the asteroid
            let label = SKLabelNode(text: "Evasive Manuever!")
            label.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            label.fontSize = 30
            label.fontColor = .white
            addChild(label)
            
            // Remove the asteroid from the scene
            removeAsteroid()
            
            // Reset the ship's chamber
            resetShipChamber()
            
            // Wait for a short duration before removing the label
            label.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.removeFromParent()]))
            
            // Increment the number of evasive manuevers taken
            gameState.numberOfEvasiveManeuvers += 1
            
            spawnAsteroid()
        }
        
        // If the explosive comes into contact with the asteroid, remove the explosive from the scene
        if let explosive = gameState.currentExplosive, let asteroid = gameState.currentAsteroid, explosive.node.intersects(asteroid.node) {
            // Remove the explosive from the scene
            explosive.node.removeFromParent()
            gameState.currentExplosive = nil
        }
        
        // If the missile comes into contact with the asteroid, remove the missile from the scene and destroy the asteroid if the health is 1
        if let missile = gameState.currentMissile, let asteroid = gameState.currentAsteroid, missile.node.intersects(asteroid.node) {
            // Remove the missile from the scene
            missile.node.removeFromParent()
            gameState.currentMissile = nil
            
            if asteroid.currentHealth == 1 {
                removeAsteroid()
                resetShipChamber()
            }
        }
        
        // If the missile and explosive collide, remove both from the scene and produce an area damage explosion
        if let missile = gameState.currentMissile, let explosive = gameState.currentExplosive, missile.node.intersects(explosive.node) {
            // Remove the missile and explosive from the scene
            missile.node.removeFromParent()
            explosive.node.removeFromParent()
            gameState.currentMissile = nil
            gameState.currentExplosive = nil
            
            // Produce an area damage explosion
            let explosion = spawnExplosion(at: explosive.node.position)
            explosion.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.removeFromParent()]))
            
            // Check to see how close the explosion is to the asteroid
            if let asteroid = gameState.currentAsteroid {
                let distance = abs(asteroid.node.position.y - explosion.position.y)
                
                let percentDamage = computeDamage(distanceFromDamage: distance / gameState.difficultyLevel.rawValue, sizeOfEntity: (asteroid.node.size.width + asteroid.node.size.height) / 2)
                
                if percentDamage > 0 {
                    gameState.currentAsteroid?.currentHealth -= Int(percentDamage * Double(asteroid.maxHealth))
                }
                
                if gameState.currentAsteroid?.currentHealth ?? defaultHealth <= 0 {
                    removeAsteroid()
                    resetShipChamber()
                    gameState.numberOfAsteroidsDestroyed += 1
                }
            }
            
            // Check to see how close the explosion is to the ship
            let distance = abs(gameState.ship.node.position.y - explosion.position.y)
            
            let percentDamage = computeDamage(distanceFromDamage: distance, sizeOfEntity: (gameState.ship.node.size.width + gameState.ship.node.size.height) / 2)
            
            if percentDamage > 0 {
                gameState.ship.currentHealth -= Int(percentDamage * Double(gameState.ship.maxHealth))
            }
            
            if gameState.ship.currentHealth <= 0 {
                gameOver()
            }
        }
                
        // If the asteroid goes below the screen, remove it from the scene
        if let asteroid = gameState.currentAsteroid {
            if asteroid.node.position.y < 0 - asteroid.node.size.height {
                removeAsteroid()
                resetShipChamber()
            }
        }
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        print(location)
        
        switch gameState.gameSequence {
        case .start:
            gameState.gameSequence = .gameInProgress
            startGame()
        case .gameOver:
            resetGameState()
            gameState.gameSequence = .start
        case .gameInProgress:
            fallthrough
        default:
            break
        }
        
        if gameState.currentAsteroid == nil {
            // Create a new asteroid if there isn't one already
            resetShipChamber()
            spawnAsteroid()
            return
        }
        
        switch gameState.ship.fire() {
        case .explosive:
            gameState.currentExplosive = Explosive(node: spawnExplosive())
        case .missile:
            gameState.currentMissile = Missile(node: spawnMissile())
        }
    }
    
    private func computeDamage(distanceFromDamage: CGFloat, sizeOfEntity: CGFloat) -> Double {
        if sizeOfEntity <= 0 {
            return 0
        }
        
        if distanceFromDamage <= 0 {
            return 1
        }
        
        switch distanceFromDamage / sizeOfEntity {
        case 0.0..<0.25:
            return 1.0
        case 0.25..<0.5:
            return 0.75
        case 0.5..<0.75:
            return 0.5
        case 0.75...1.0:
            return 0.25
        default:
            return 0.0
        }
    }
    
    private func removeAsteroid() {
        if let asteroid = gameState.currentAsteroid {
            asteroid.node.removeFromParent()
            gameState.currentAsteroid = nil
        }
        
    }
    
    private func removeExplosive() {
        if let explosive = gameState.currentExplosive {
            explosive.node.removeFromParent()
            gameState.currentExplosive = nil
        }
    }
    
    private func removeMissile() {
        if let missile = gameState.currentMissile {
            missile.node.removeFromParent()
            gameState.currentMissile = nil
        }
    }
    
    private func resetShipChamber() {
        gameState.ship.chamber = .explosive
    }
    
    private func spawnAsteroid() {
        // Load the textures from the sprite atlas
        let atlas = SKTextureAtlas(named: "Asteroid-00")
        var textures: [SKTexture] = []
        for index in 0...atlas.textureNames.count - 1 {
            let textureName = String(format: "spin-%02d", index)
            textures.append(atlas.textureNamed(textureName))
        }
                
        // Create a sprite node with the first texture as the initial texture
        let asteroidSprite = SKSpriteNode(texture: textures.first)
        asteroidSprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        addChild(asteroidSprite)
                
        // Define the movement action
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: TimeInterval(arc4random_uniform(6) + 6)) // Move from top to bottom anywhere between 6 and 12 seconds
        
        // Create an action to animate through the textures
        let animationAction = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.1))
                
        // Repeat the animation forever
        asteroidSprite.run(SKAction.group([animationAction, moveAction]))
        
        gameState.currentAsteroid = Asteroid(node: asteroidSprite)
        gameState.currentAsteroid?.node.position = CGPoint(x: self.size.width / 2, y: self.size.height + asteroidSprite.size.height / 2)
    }
    
    private func spawnExplosive() -> SKSpriteNode {
        let atlas = SKTextureAtlas(named: "Explosive")
        var textures: [SKTexture] = []
        for index in 0...atlas.textureNames.count - 1 {
            let textureName = String(format: "box-%01d", index)
            textures.append(atlas.textureNamed(textureName))
        }
        
        let explosive = SKSpriteNode(texture: textures.first)
        explosive.position = gameState.ship.node.position
        addChild(explosive)
        
        let animationAction = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.1))
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: self.size.height), duration: explosiveSpeed)
        
        let removeAction = SKAction.removeFromParent()
        explosive.run(SKAction.sequence([SKAction.group([animationAction, moveAction]), removeAction]))
        
        return explosive
    }
    
    private func spawnMissile() -> SKSpriteNode {
        let atlas = SKTextureAtlas(named: "Missile-01")
        var textures: [SKTexture] = []
        for index in 0...atlas.textureNames.count - 1 {
            let textureName = String(format: "sidewinder-%01d", index)
            textures.append(atlas.textureNamed(textureName))
        }
        
        let missile = SKSpriteNode(texture: textures.first)
        missile.position = gameState.ship.node.position
        missile.setScale(0.75)
        
        addChild(missile)
        
        let animationAction = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.25))
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: self.size.height), duration: missileSpeed)
        
        let removeAction = SKAction.removeFromParent()
        missile.run(SKAction.sequence([SKAction.group([animationAction, moveAction]), removeAction]))
        
        return missile
    }
    
    private func spawnExplosion(at position: CGPoint) -> SKSpriteNode {
        let atlas = SKTextureAtlas(named: "MediumExplosion")
        var textures: [SKTexture] = []
        for index in 0...atlas.textureNames.count - 1 {
            let textureName = String(format: "medium-%02d", index)
            textures.append(atlas.textureNamed(textureName))
        }
        
        let explosion = SKSpriteNode(texture: textures.first)
        explosion.position = position
        addChild(explosion)
        
        let animationAction = SKAction.animate(with: textures, timePerFrame: 0.07)
        explosion.run(animationAction)
        
        return explosion
    }
    
    private func gameOver() {
        removeAsteroid()
        removeMissile()
        removeExplosive()
        gameState.gameSequence = .gameOver
    }
    
    private func startGame() {
        gameState.gameSequence = .gameInProgress
                
        if gameState.currentAsteroid == nil {
            self.spawnAsteroid()
        }
    }
    
    private func resetGameState() {
        gameState.ship.currentHealth = gameState.ship.maxHealth
        resetShipChamber()
        gameState.numberOfAsteroidsDestroyed = 0
        gameState.numberOfAsteroidsSpawned = 0
        gameState.numberOfMissilesFired = 0
        gameState.numberOfExplosivesFired = 0
        gameState.numberOfEvasiveManeuvers = 0
    }
}

