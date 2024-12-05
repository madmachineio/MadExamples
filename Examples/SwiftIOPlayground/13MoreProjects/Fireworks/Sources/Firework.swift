import MadGraphics
import ST7789
import SwiftIO

struct Firework {
    var particle: Particle
    var sparks: [Spark] = []
    
    var exploded = false

    let color: Color
    let size = 2

    // Create a firework at the bottom of the screen.
    init(color: Color, maxWidth: Int) {
        self.color = color

        let x = Array(0..<(maxWidth - 1)).shuffled().randomElement()!
        particle = Particle(pos: Point(x: x, y: maxWidth - 1))
    }

    // Update firework's position.
    // If it explodes, it will return true to indicate it's time to play sound. 
    mutating func update(_ layer: Layer) -> Bool {
        if exploded {
            for spark in sparks {
                layer.draw() { canvas in
                    canvas.fillCircle(at: spark.pos, radius: size, data: Color.black.rawValue) 
                }
            }

            updateSparks()
            
            for spark in sparks {
                let color = Color.blend(foreground: color.rawValue, background: Color.black.rawValue, mask: spark.lifespan)
                layer.draw() { canvas in
                    canvas.fillCircle(at: spark.pos, radius: size, data: color.rawValue)
                }
            }
        } else {
            layer.draw() { canvas in
                canvas.fillCircle(at: particle.pos, radius: size, data: Color.black.rawValue)
            }

            let playSound = updateParticle()

            layer.draw() { canvas in
                canvas.fillCircle(at: particle.pos, radius: size, data: color.rawValue)
            }
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