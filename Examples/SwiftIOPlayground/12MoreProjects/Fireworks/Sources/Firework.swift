import MadGraphics
import ST7789
import SwiftIO

struct Firework {
    var particle: Particle
    var sparks: [Spark] = []
    
    var exploded = false

    let canvas: Canvas
    let color: Color
    let size = 2

    // Create a firework at the bottom of the screen.
    init(color: Color, canvas: Canvas) {
        self.color = color
        self.canvas = canvas

        let x = Array(0..<canvas.width-1).shuffled().randomElement()!
        particle = Particle(pos: Point(x: x, y: canvas.width-1))
    }

    // Update firework's position.
    // If it explodes, it will return true to indicate it's time to play sound. 
    mutating func update() -> Bool {
        if exploded {
            sparks.forEach { 
                canvas.fillCircle(at: $0.pos, radius: size, color: Color.black) 
            }

            updateSparks()
            
            sparks.forEach {
                let color = Color.blend(foreground: color.value, background: Color.black.value, mask:$0.lifespan)
                canvas.fillCircle(at: $0.pos, radius: size, color: color)
            }
        } else {
            canvas.fillCircle(at: particle.pos, radius: size, color: Color.black)
            let playSound = updateParticle()
            canvas.fillCircle(at: particle.pos, radius: size, color: color)
            return playSound
        }

        return false
    }

    // Update sparks' position and speed over time.
    mutating func updateSparks() {
        for i in sparks.indices.reversed() {
            sparks[i].update()
            // If 
            if sparks[i].done() {
                sparks.remove(at: i)
            }
        } 
    }

    // Update particle's position and speed over time.
    mutating func updateParticle() -> Bool {
        particle.update()
        if particle.willExplode() {  
            exploded = true
            explode()
            return true
        }

        return false
    }

    // Generate firework sparks after explosion.
    mutating func explode() {
        for _ in 0..<100 {
            sparks.append(Spark(pos: particle.pos))
        } 
    }

    func done() -> Bool {
        return exploded && sparks.count == 0
    }
}