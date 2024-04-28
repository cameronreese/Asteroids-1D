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
    
    let explosionRadius: Int = 6 // TODO: compute this to be a value equal to the size of the asteroid, and change the size of the asteroid to be scaled to the size of the screen
    
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
                
        if gameState.currentAsteroid == nil {
            self.spawnAsteroid()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // If the asteroid comes into contact with the ship, remove the asteroid from the scene
        if let asteroid = gameState.currentAsteroid, gameState.ship.node.intersects(asteroid.node) {
            // Decrement the ship's health
            gameState.ship.health -= 1
            
            // If the ship's health reaches 0, end the game
            if gameState.ship.health == 0 {
                print("Game Over")
            } else {
                removeAsteroid()
                resetShipChamber()
            }
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
            
            if asteroid.health == 1 {
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
                let distance = asteroid.node.position.y - explosion.position.y
                // TODO: use the explosionRadius to compute a damage based on "rings" of how close it is and decriment the asteroid accordingly. 
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
        
        if gameState.currentAsteroid == nil {
            // Create a new asteroid if there isn't one already
            resetShipChamber()
            spawnAsteroid()
            return
        }
        
        switch gameState.ship.fire() {
        case .explosive:
            print("Explosive shot fired")
            gameState.currentExplosive = Explosive(node: spawnExplosive(), health: 1)
        case .missile:
            print("Missile fired")
            gameState.currentMissile = Missile(node: spawnMissile(), health: 1)
        }
    }
    
    private func removeAsteroid() {
        if let asteroid = gameState.currentAsteroid {
            asteroid.node.removeFromParent()
            gameState.currentAsteroid = nil
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
        
        gameState.currentAsteroid = Asteroid(node: asteroidSprite, health: 3)
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
        
        let animationAction = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.1))
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
        
        let animationAction = SKAction.animate(with: textures, timePerFrame: 0.1)
        explosion.run(animationAction)
        
        return explosion
    }
}

