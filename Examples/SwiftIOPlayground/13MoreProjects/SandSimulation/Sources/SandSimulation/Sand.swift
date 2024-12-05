import MadGraphics

struct Particle {
    var x: Int
    var y: Int
    var xSpeed: Float
    var ySpeed: Float
    let color: Color
}

struct Sand {
    let count = 1000
    let size = 3
    var particles: [Particle] = []

    let colors: [Color] = [.red, .orange, .yellow, .lime, .cyan, .blue, .purple, .magenta]
    var grid: [Bool]

    let column: Int
    let row: Int

    init(layer: Layer, _ acceleration: (x: Float, y: Float, z: Float)) {
        column = layer.bounds.width / size
        row = layer.bounds.height / size
        grid = [Bool](repeating: false, count: column * row)
        
        // Draw the particles on the top of the layer.
        var index = 0

        while index < count {
            let x = index % column
            let y = index / column

            particles.append(Particle(x: x, y: y, xSpeed: 0, ySpeed: 0, color: colors.randomElement()!))
            layer.draw() { canvas in
                canvas.fillRectangle(at: Point(x * size, y * size), width: size, height: size, data: particles[y * column + x].color.rawValue)
            }
            grid[y * column + x] = true

            index += 1
        }
    }

    mutating func update(layer: Layer, _ acceleration: (x: Float, y: Float, z: Float)) {
        updateSpeed(acceleration)

        for i in particles.indices {
            var xSpeed = particles[i].xSpeed
            var ySpeed = particles[i].ySpeed

            let lastX = particles[i].x
            let lastY = particles[i].y

            var newX = particles[i].x + Int(xSpeed)
            var newY = particles[i].y + Int(ySpeed)

            // If the particle collides with a wall, bounce it.
            if newX > column - 1 {
                newX = column - 1
                xSpeed /= -2
            } else if newX < 0 {
                newX = 0
                xSpeed /= -2
            }

            if newY > row - 1 {
                newY = row - 1
                ySpeed /= -2
            } else if newY < 0 {
                newY = 0
                ySpeed /= -2
            }

            let lastIndex = lastY * column + lastX
            let newIndex = newY * column + newX

            // The particle moves and collide with other particle.
            if lastIndex != newIndex && grid[newIndex] {
                if abs(lastIndex - newIndex) == 1 {
                    // The particle moves horizontally.
                    xSpeed /= -2
                    newX = lastX
                } else if abs(lastIndex - newIndex) == column {
                    // The particle moves vertically.
                    ySpeed /= -2
                    newY = lastY
                } else {
                    // If the particle moves diagonally, find an available position adjacent to the particle to place it.
                    if abs(xSpeed) >= abs(ySpeed) {
                        // The speed on the x-axis is greater than the speed on the y-axis.
                        if !grid[lastY * column + newX] {
                            // Suppress movement along the y-axis.
                            newY = lastY
                            ySpeed /= -2
                        } else if !grid[newY * column + lastX] {
                            // Suppress movement along the x-axis.
                            newX = lastX
                            xSpeed /= -2
                        } else {
                            // Remain still.
                            newX = lastX
                            newY = lastY
                            xSpeed /= -2
                            ySpeed /= -2
                        }
                    } else {
                        // The speed on the x-axis is less than the speed on the y-axis.
                        if !grid[newY * column + lastX] {
                            // Suppress movement along the x-axis.
                            newX = lastX
                            xSpeed /= -2
                        } else if !grid[lastY * column + newX] {
                            // Suppress movement along the y-axis.
                            newY = lastY
                            ySpeed /= -2
                        } else {
                            // Remain still.
                            newX = lastX
                            newY = lastY
                            xSpeed /= -2
                            ySpeed /= -2
                        }
                    }
                }
            }

            particles[i].x = newX
            particles[i].y = newY
            particles[i].xSpeed = xSpeed
            particles[i].ySpeed = ySpeed
            grid[lastY * column + lastX] = false
            grid[newY * column + newX] = true
            layer.draw() { canvas in
                canvas.fillRectangle(at: Point(lastX * size, lastY * size), width: size, height: size, data: Color.black.rawValue)
            }
            layer.draw() { canvas in
                canvas.fillRectangle(at: Point(newX * size, newY * size), width: size, height: size, data: particles[i].color.rawValue)
            }
        }
    }

    mutating func updateSpeed(_ acceleration: (x: Float, y: Float, z: Float)) {
        var xAccel = -acceleration.x
        var yAccel = acceleration.y
        var zAccel = min(abs(acceleration.z), 1)

        if abs(xAccel) <= 0.1 && abs(yAccel) <= 0.1 {
            // Prevent the particles from moving when the board is lying on the table not completely level.
            for i in particles.indices {
                particles[i].xSpeed = 0
                particles[i].ySpeed = 0
            }
        } else {
            // Acceleration on z-axis simulates the effect of gravitational on the motion of the particles. 
            // When z-axis acceleration is close to 1, sensor is flat, and gravity barely affects xy movement. 
            // Lower z-axis acceleration means more gravity influence on xy motion. 
            zAccel = 0.5 - zAccel / 2
            xAccel -= zAccel
            yAccel -= zAccel

            //A slight random motion is added to each particle according to the z-axis acceleration.
            // Their speed stays below 1 to avoid overlap. 
            // However, the rapid iteration speed creates the illusion of smooth particle movement.
            for i in particles.indices {
                var xSpeed = particles[i].xSpeed + xAccel + Float.random(in: 0...zAccel)
                if abs(xSpeed) > 1 {
                    xSpeed /= abs(xSpeed) 
                }

                var ySpeed = particles[i].ySpeed + yAccel + Float.random(in: 0...zAccel)
                if abs(ySpeed) > 1 {
                    ySpeed /= abs(ySpeed) 
                }

                particles[i].xSpeed = xSpeed
                particles[i].ySpeed = ySpeed 
            }
        }
    }
}