import MadGraphics

class WordView {
    let width: Int
    let height: Int
    let characterMasks: [[Mask]]
    let layer: Layer

    // Draw the character matrix on the screen.
    init(layer: Layer, characterMasks: [[Mask]]) {
        self.layer = layer
        self.characterMasks = characterMasks

        width = layer.bounds.width / Words.column
        height = layer.bounds.height / Words.row

        for y in 0..<Words.row {
            for x in 0..<Words.column {
                let textMask = characterMasks[y][x]
                layer.draw() { canvas in
                    canvas.blend(from: textMask, foregroundColor: Color.gray, to: Point(x: x * width + (width - textMask.width) / 2, y: y * height + (height - textMask.height) / 2))
                }
            }
        }
    }

    // Display the words representing the current hour and minute.
    func showTime(hour: Int, minute: Int, color: Color) {
        let words = Words.getWords(hourNumber: hour, minuteNumber: minute)

        for word in words.minuteWord {
            showWord(points: Words.wordCompositions[word.rawValue], color: color)
        }
        if let prep = words.prepWord {
            showWord(points: Words.wordCompositions[prep.rawValue], color: color)
        }
        showWord(points: Words.wordCompositions[words.hourWord.rawValue], color: color)
    }

    // Display a single word by defining the positions of its characters on the display.
    func showWord(points: [Point], color: Color) {
        for point in points {
            showCharacter(point: point, color: color)
        }
    }

    // Display a character by specifying its position on the display.
    func showCharacter(point: Point, color: Color) {
        let text = characterMasks[point.y][point.x]
        let point = Point(x: point.x * width + (width - text.width) / 2, y: point.y * height + (height - text.height) / 2)
        layer.draw() { canvas in
            canvas.fillRectangle(at: point, width: text.width, height: text.height, data: Color.black.rawValue)
            canvas.blend(from: text, foregroundColor: color, to: point)
        }
    }
}