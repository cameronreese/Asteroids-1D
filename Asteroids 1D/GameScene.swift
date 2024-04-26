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
    let shipScale: CGFloat = 0.5
    
    override func didMove(to view: SKView) {
        let movementRange: CGFloat = 2.5 // Adjust as needed
        let tiltAngle: CGFloat = 0.01 // Adjust as needed

        // Set the scale of the ship sprite to make it larger
        self.gameState.ship.node.setScale(self.shipScale)
        
        // Set the ship's position to be centered horizontally and 100 points from the top
        self.gameState.ship.node.position = CGPoint(x: self.size.width / 2 + movementRange / 2, y: self.size.height / 5)
        self.gameState.ship.node.zRotation = (tiltAngle / 2) * -1
        
        addChild(self.gameState.ship.node)
        
        // Set the anchor point of the ship sprite to its center
        self.gameState.ship.node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
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
        self.gameState.ship.node.run(SKAction.repeatForever(groupAction))
                
        if self.gameState.currentAsteroid == nil {
            self.createAsteroid()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // If the asteroid comes into contact with the ship, remove the asteroid from the scene
        if let asteroid = self.gameState.currentAsteroid, self.gameState.ship.node.intersects(asteroid.node) {
            // Decrement the ship's health
            self.gameState.ship.health -= 1
            
            // If the ship's health reaches 0, end the game
            if self.gameState.ship.health == 0 {
                print("Game Over")
            } else {
                destroyAndResetAsteroid()
            }
        }
        
        // If the asteroid goes below the screen, remove it from the scene
        if let asteroid = self.gameState.currentAsteroid {
            if asteroid.node.position.y < 0 - asteroid.node.size.height {
                destroyAndResetAsteroid()
            }
        }
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        print(location)

    }
    
    private func destroyAndResetAsteroid() {
        if let asteroid = self.gameState.currentAsteroid {
            asteroid.node.removeFromParent()
            self.gameState.currentAsteroid = nil
        }
        
        // Reset the asteroid after a delay
        let waitAction = SKAction.wait(forDuration: 3.0)
        let completionAction = SKAction.run {
            self.createAsteroid()
        }
        let sequence = SKAction.sequence([waitAction, completionAction])
        self.gameState.ship.node.run(sequence)
    }
    
    private func createAsteroid() {
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
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: -size.height * 2), duration: TimeInterval(arc4random_uniform(13) + 4)) // Move from top to bottom anywhere between 4 and 16 seconds
        
        // Create an action to animate through the textures
        let animationAction = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.1))
                
        // Repeat the animation forever
        asteroidSprite.run(SKAction.group([animationAction, moveAction]))
        
        self.gameState.currentAsteroid = Asteroid(node: asteroidSprite, health: 3)
        self.gameState.currentAsteroid?.node.position = CGPoint(x: self.size.width / 2, y: self.size.height + asteroidSprite.size.height / 2)
    }
}

