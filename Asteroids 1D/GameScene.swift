//
//  GameScene.swift
//  Asteroids 1D
//
//  Created by Cameron Reese on 4/16/24.
//

import SwiftUI
import SpriteKit

let asteroidCategory: UInt32 = 0x1 << 1
let shipCategory: UInt32 = 0x1 << 2

class GameScene: SKScene, SKPhysicsContactDelegate {
        
    var gameState: GameState = GameState(ship: Ship(node: SKSpriteNode(imageNamed: "Ship")))
    let shipScale: CGFloat = 3.0
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        // Set the scale of the ship sprite to make it larger
        self.gameState.ship.node.setScale(self.shipScale)
        
        // Set the ship's position to be centered horizontally and 100 points from the top
        self.gameState.ship.node.position = CGPoint(x: self.size.width / 2, y: self.size.height / 4)
        
        // Setup the ship's physics body
        self.gameState.ship.node.physicsBody = SKPhysicsBody(rectangleOf: self.gameState.ship.node.size)
        self.gameState.ship.node.physicsBody?.isDynamic = false
        self.gameState.ship.node.physicsBody?.categoryBitMask = shipCategory
//        self.gameState.ship.node.physicsBody?.contactTestBitMask = 0
        self.gameState.ship.node.physicsBody?.collisionBitMask = 0
        
        addChild(self.gameState.ship.node)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let asteroid = self.gameState.currentAsteroid {
            if asteroid.node.position.y < 0 - asteroid.node.size.height {
                asteroid.node.removeFromParent()
                self.gameState.currentAsteroid = nil
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("Contact detected")
        if var asteroid = self.gameState.currentAsteroid, asteroid.node == contact.bodyA.node {
            asteroid.health = 0
            if asteroid.health <= 0 {
                asteroid.node.removeFromParent()
                self.gameState.numberOfAsteroidsDestroyed += 1
                self.gameState.currentAsteroid = nil
            }
        }
        
        if self.gameState.ship.node == contact.bodyA.node {
            self.gameState.ship.health -= 1
            if self.gameState.ship.health <= 0 {
                self.gameState.ship.node.removeFromParent()
            }
        }
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        print(location)
        if self.gameState.currentAsteroid == nil {
            self.createAsteroid()
        }
    }
    
    private func createAsteroid() {
        // Load the textures from the sprite atlas
        let atlas = SKTextureAtlas(named: "Asteroid")
        var textures: [SKTexture] = []
        for index in 1...atlas.textureNames.count {
            let textureName = String(format: "Asteroid-frame%02d", index)
            textures.append(atlas.textureNamed(textureName))
        }
        
        
        // Create a sprite node with the first texture as the initial texture
        let asteroidSprite = SKSpriteNode(texture: textures.first)
        asteroidSprite.zRotation = -CGFloat.pi / 2
        asteroidSprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Set up the asteroid's physics body
        asteroidSprite.physicsBody = SKPhysicsBody(rectangleOf: asteroidSprite.size)
        asteroidSprite.physicsBody?.isDynamic = false
        asteroidSprite.physicsBody?.categoryBitMask = asteroidCategory
//        asteroidSprite.physicsBody?.contactTestBitMask = 1
        asteroidSprite.physicsBody?.collisionBitMask = 0
        
        addChild(asteroidSprite)
        
        // Define the movement action
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: -size.height * 2), duration: TimeInterval(arc4random_uniform(13) + 4)) // Move from top to bottom anywhere between 4 and 16 seconds
        
        // Create an action to animate through the textures
        let animationAction = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.1))
                
        // Repeat the animation forever
        asteroidSprite.run(SKAction.group([animationAction, moveAction]))
        
        self.gameState.currentAsteroid = Asteroid(node: asteroidSprite, health: 3)
        self.gameState.currentAsteroid?.node.position = CGPoint(x: self.size.width / 2, y: self.size.height + asteroidSprite.size.height / 2)
    }
}

