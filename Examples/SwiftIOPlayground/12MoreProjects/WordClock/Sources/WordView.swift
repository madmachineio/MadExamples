import MadGraphics

struct WordView {
    let canvas: Canvas
    let width: Int
    let height: Int
    let characterMasks: [[Mask]]

    // Draw the character matrix on the screen.
    init(canvas: Canvas, characterMasks: [[Mask]]) {
        self.canvas = canvas
        self.characterMasks = characterMasks

        width = canvas.width / Words.column
        height = canvas.height / Words.row

        for y in 0..<Words.row {
            for x in 0..<Words.column {
                let textMask = characterMasks[y][x]
                canvas.blend(from: textMask, foreground: Color.gray, to: Point(x: x * width + (width - textMask.width) / 2, y: y * height + (height - textMask.height) / 2))
            }
        }
    }

    // Display the words representing the current hour and minute.
    func showTime(hour: Int, minute: Int, color: Color) {
        let words = Words.getWords(time: (hour: hour, minute: minute))

        for word in words.minute {
            showWord(points: Words.wordCompositions[word.rawValue], color: color)
        }
        if let prep = words.prep {
            showWord(points: Words.wordCompositions[prep.rawValue], color: color)
        }
        showWord(points: Words.wordCompositions[words.hour.rawValue], color: color)
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
        canvas.fillRectangle(at: point, width: text.width, height: text.height, color: Color.black)
        canvas.blend(from: text, foreground: color, to: point)
    }
}