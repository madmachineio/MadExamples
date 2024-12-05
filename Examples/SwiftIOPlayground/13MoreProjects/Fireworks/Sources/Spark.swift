import MadGraphics 

// The firework after explosion.
struct Spark {
    var pos: Point
    var velocity: (x: Float, y: Float)
    var acceleration: (x: Float, y: Float)
    // How long the spark shows on the screen.
    var lifespan: UInt8 = 255
    
    // Create a particle with a random velocity and acceleration.
    // Its initial position is the maximum height of the firework particle.
    init(pos: Point) {
        self.pos = pos

        // The speed of the spark at a random direction.
        velocity.x = Float(Array(-100..<100).shuffled().randomElement()!) / 50
        velocity.y = Float(Array(-100..<100).shuffled().randomElement()!) / 50
        velocity.x *= Float.random(in: 1...4)
        velocity.y *= Float.random(in: 1...4)

        acceleration = (0, Float.random(in: 0.3..<0.4))
    }

    // Update the particle's position and velocity over time.
    mutating func update() {
        velocity.x *= 0.8
        velocity.y *= 0.8
        lifespan -= 5
        
        pos.x += Int(velocity.x)
        pos.y += Int(velocity.y)

        velocity.x += acceleration.x
        velocity.y += acceleration.y
    }

    // Whether the spark will disappear.
    func done() -> Bool {
        return lifespan <= 0
    }
}