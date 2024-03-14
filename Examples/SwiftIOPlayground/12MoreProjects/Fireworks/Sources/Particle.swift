import MadGraphics 

// The firework before explosion.
struct Particle {
    var pos: Point
    var velocity: (x: Float, y: Float)
    var acceleration: (x: Float, y: Float)
    
    // Create a particle with a random velocity and acceleration.
    init(pos: Point) {
        self.pos = pos
        velocity = (0, Float.random(in: (-14.0)...(-10.0)))
        acceleration = (0, Float.random(in: 0.3..<0.4))
    }

    // Update the particle's position and velocity over time.
    mutating func update() {
        pos.x += Int(velocity.x)
        pos.y += Int(velocity.y)

        velocity.x += acceleration.x
        velocity.y += acceleration.y
    }

    // Whether the particle reaches its maximum height.
    func willExplode() -> Bool {
        return velocity.y > 0
    }
}