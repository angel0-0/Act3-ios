import SpriteKit
import CoreHaptics

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Propiedades del juego
    var ball: SKShapeNode!
    var leftFlipper: SKShapeNode!
    var rightFlipper: SKShapeNode!
    var bumpers: [SKShapeNode] = []
    var scoreLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Puntos: \(score)"
        }
    }
    
    var lives: Int = 3 {
        didSet {
            livesLabel.text = "Vidas: \(lives)"
            if lives <= 0 {
                gameOver()
            }
        }
    }
    
    // Motor háptico
    var hapticEngine: CHHapticEngine?
    
    // Categorías de colisión
    let ballCategory: UInt32 = 0x1 << 0
    let bumperCategory: UInt32 = 0x1 << 1
    let flipperCategory: UInt32 = 0x1 << 2
    let bottomCategory: UInt32 = 0x1 << 3
    
    // MARK: - Configuración inicial
    override func didMove(to view: SKView) {
        setupBackground()
        setupPhysics()
        setupHaptics()
        setupUI()
        setupBall()
        setupFlippers()
        setupBumpers()
    }
    
    func setupBackground() {
        backgroundColor = .black  // Fondo negro puro
    }
    
    
    // MARK: - Configurar física
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -1.8)
        physicsWorld.contactDelegate = self
        
        let border = SKPhysicsBody(edgeLoopFrom: frame)
        border.friction = 0.2
        border.restitution = 0.8
        physicsBody = border
    }
    
    // MARK: - Configurar hápticos
    func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Error al iniciar motor háptico: \(error)")
        }
    }
    
    // MARK: - Configurar UI
    func setupUI() {
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Puntos: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .cyan
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        addChild(scoreLabel)
        
        livesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        livesLabel.text = "Vidas: 3"
        livesLabel.fontSize = 24
        livesLabel.fontColor = .cyan
        livesLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 140)
        addChild(livesLabel)
    }
    
    // MARK: - Crear bola
    func setupBall() {
        ball = SKShapeNode(circleOfRadius: 12)
        ball.fillColor = .cyan
        ball.strokeColor = .cyan
        ball.glowWidth = 5.0
        
        let randomX = CGFloat.random(in: frame.minX + 50...frame.maxX - 50)
        ball.position = CGPoint(x: randomX, y: frame.maxY - 150)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        ball.physicsBody?.restitution = 0.9
        ball.physicsBody?.friction = 0.3
        ball.physicsBody?.linearDamping = 0.1
        ball.physicsBody?.categoryBitMask = ballCategory
        ball.physicsBody?.contactTestBitMask = bumperCategory | bottomCategory
        ball.physicsBody?.collisionBitMask = bumperCategory | flipperCategory | 0xFFFFFFFF
        ball.physicsBody?.allowsRotation = true
        ball.physicsBody?.angularDamping = 0.2
        
        addChild(ball)
    }
    
    // MARK: - Crear paletas
    func setupFlippers() {
        let flipperWidth: CGFloat = 150
        let flipperHeight: CGFloat = 15
        let flipperY: CGFloat = frame.minY + 100
        
        leftFlipper = SKShapeNode(rectOf: CGSize(width: flipperWidth, height: flipperHeight), cornerRadius: 5)
        leftFlipper.fillColor = .lightGray
        leftFlipper.strokeColor = .white
        leftFlipper.position = CGPoint(x: frame.minX + flipperWidth/2 + 10, y: flipperY)
        
        leftFlipper.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: flipperWidth, height: flipperHeight))
        leftFlipper.physicsBody?.isDynamic = false
        leftFlipper.physicsBody?.restitution = 1.5
        leftFlipper.physicsBody?.categoryBitMask = flipperCategory
        
        addChild(leftFlipper)
        
        rightFlipper = SKShapeNode(rectOf: CGSize(width: flipperWidth, height: flipperHeight), cornerRadius: 5)
        rightFlipper.fillColor = .lightGray
        rightFlipper.strokeColor = .white
        rightFlipper.position = CGPoint(x: frame.maxX - flipperWidth/2 - 10, y: flipperY)
        
        rightFlipper.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: flipperWidth, height: flipperHeight))
        rightFlipper.physicsBody?.isDynamic = false
        rightFlipper.physicsBody?.restitution = 1.5
        rightFlipper.physicsBody?.categoryBitMask = flipperCategory
        
        addChild(rightFlipper)
    }
    
    // MARK: - Crear bumpers
    func setupBumpers() {
        let bumperRadius: CGFloat = 25
        
        let bumperPositions = [
            CGPoint(x: frame.minX + 60, y: frame.maxY - 200),
            CGPoint(x: frame.maxX - 60, y: frame.maxY - 200),
            CGPoint(x: frame.midX, y: frame.maxY - 350),
            CGPoint(x: frame.minX + 60, y: frame.maxY - 500),
            CGPoint(x: frame.maxX - 60, y: frame.maxY - 500)
        ]
        
        for position in bumperPositions {
            let bumper = SKShapeNode(circleOfRadius: bumperRadius)
            bumper.fillColor = UIColor(red: 0.7, green: 0.5, blue: 1.0, alpha: 1.0)
            bumper.strokeColor = UIColor(red: 0.7, green: 0.5, blue: 1.0, alpha: 1.0)
            bumper.glowWidth = 8.0
            bumper.position = position
            
            bumper.physicsBody = SKPhysicsBody(circleOfRadius: bumperRadius)
            bumper.physicsBody?.isDynamic = false
            bumper.physicsBody?.restitution = 1.5
            bumper.physicsBody?.categoryBitMask = bumperCategory
            
            addChild(bumper)
            bumpers.append(bumper)
        }
    }
    
    // MARK: - Detección de toques
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if location.x < frame.midX {
            activateFlipper(leftFlipper, isLeft: true)
        } else {
            activateFlipper(rightFlipper, isLeft: false)
        }
    }
    
    // MARK: - Activar paletas
    func activateFlipper(_ flipper: SKShapeNode, isLeft: Bool) {
        let angle: CGFloat = isLeft ? .pi / 6 : -.pi / 6
        let rotate = SKAction.rotate(toAngle: angle, duration: 0.1)
        let reset = SKAction.rotate(toAngle: 0, duration: 0.1)
        let sequence = SKAction.sequence([rotate, SKAction.wait(forDuration: 0.1), reset])
        
        flipper.run(sequence)
    }
    
    // MARK: - Detección de colisiones
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == (ballCategory | bumperCategory) {
            score += 10
            triggerHaptic()
            
            if let bumper = (contact.bodyA.node as? SKShapeNode) ?? (contact.bodyB.node as? SKShapeNode) {
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.3, duration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.1)
                ])
                bumper.run(pulse)
            }
        }
        
        if ball.position.y < frame.minY + 50 {
            lives -= 1
            if lives > 0 {
                resetBall()
            }
        }
    }
    
    // MARK: - Vibración háptica
    func triggerHaptic() {
        guard let engine = hapticEngine else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Error al reproducir háptico: \(error)")
        }
    }
    
    // MARK: - Reiniciar bola
    func resetBall() {
        let randomX = CGFloat.random(in: frame.minX + 50...frame.maxX - 50)
        ball.position = CGPoint(x: randomX, y: frame.maxY - 150)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ball.physicsBody?.angularVelocity = 0
    }
    
    // MARK: - Game Over
    func gameOver() {
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameOverLabel)
        
        ball.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if let view = self.view {
                let newScene = GameScene(size: self.size)
                newScene.scaleMode = .aspectFill
                view.presentScene(newScene)
            }
        }
    }
    
    // MARK: - Limitar velocidad
    override func update(_ currentTime: TimeInterval) {
        if let velocity = ball.physicsBody?.velocity {
            let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
            let maxSpeed: CGFloat = 800
            
            if speed > maxSpeed {
                let factor = maxSpeed / speed
                ball.physicsBody?.velocity = CGVector(dx: velocity.dx * factor, dy: velocity.dy * factor)
            }
        }
    }
}
