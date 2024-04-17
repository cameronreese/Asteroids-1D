//
//  GameScene.swift
//  Asteroids 1D
//
//  Created by Cameron Reese on 4/16/24.
//

import SwiftUI
import SpriteKit

class GameScene: SKScene {
    
    var gameState: GameState = GameState(ship: Ship(node: SKSpriteNode(imageNamed: "Ship")))
    
    override func didMove(to view: SKView) {
        // Set the scale of the ship sprite to make it larger
        let scale: CGFloat = 3
        self.gameState.ship.node.setScale(scale)
        
        // Set the ship's position to be centered horizontally and 100 points from the top
        self.gameState.ship.node.position = CGPoint(x: self.size.width / 2, y: self.size.height / 4)
        addChild(self.gameState.ship.node)
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
        addChild(asteroidSprite)
        
        // Define the movement action
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: TimeInterval(arc4random_uniform(13) + 4)) // Move from top to bottom anywhere between 4 and 16 seconds
        
        // Create an action to animate through the textures
        let animationAction = SKAction.animate(with: textures, timePerFrame: 0.1)
                
        // Repeat the animation forever
        asteroidSprite.run(SKAction.repeatForever(SKAction.group([animationAction, moveAction])))
        
        self.gameState.currentAsteroid = Asteroid(node: asteroidSprite, health: 3)
        self.gameState.currentAsteroid?.node.position = CGPoint(x: self.size.width / 2, y: self.size.height + asteroidSprite.size.height / 2)
    }
}

