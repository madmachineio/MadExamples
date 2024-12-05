import MadGraphics

// Define the character matrix and the positions of characters to form words.
// The words describing the time consist of hour, preposition, and minute, for example, "half past one".
struct Words {
    enum HourWord: Int {
        case twelve = 0, one, two, three, 
        four, five, six, seven, 
        eight, nine, ten, eleven 
    }

    enum PrepositionWord: Int {
        case past = 12
        case to = 13
    }

    enum MinuteWord: Int {
        case five = 14, ten, quarter,
        twenty, half
    }
    
    var hourWord: HourWord
    var prepWord: PrepositionWord?
    var minuteWord: [MinuteWord]

    static let column = characters[0].count
    static let row = characters.count

    static let characters: [[String]] = [
        ["A", "T", "W", "E", "N", "T", "Y", "D"],
        ["Q", "U", "A", "R", "T", "E", "R", "Y"],
        ["F", "I", "V", "E", "H", "A", "L", "F"],
        ["D", "P", "A", "S", "T", "O", "R", "O"],
        ["F", "I", "V", "E", "I", "G", "H", "T"],
        ["S", "I", "X", "T", "H", "R", "E", "E"],
        ["T", "W", "E", "L", "E", "V", "E", "N"],
        ["F", "O", "U", "R", "N", "I", "N", "E"]
    ]

    static let wordCompositions: [[Point]] = [
        // TWELVE
        [Point(0, 6), Point(1, 6), Point(2, 6), Point(3, 6), Point(5, 6), Point(6, 6)], 
        // ONE
        [Point(1, 7), Point(4, 7), Point(7, 7)],
        // TWO
        [Point(0, 6), Point(1, 6), Point(1, 7)],
        // THREE
        [Point(3, 5), Point(4, 5), Point(5, 5), Point(6, 5), Point(7, 5)],
        // FOUR
        [Point(0, 7), Point(1, 7), Point(2, 7), Point(3, 7)],
        // FIVE
        [Point(0, 4), Point(1, 4), Point(2, 4), Point(3, 4)],
        // SIX
        [Point(0, 5), Point(1, 5), Point(2, 5)],
        // SEVEN
        [Point(0, 5), Point(4, 6), Point(5, 6), Point(6, 6), Point(7, 6)],
        // EIGHT
        [Point(3, 4), Point(4, 4), Point(5, 4), Point(6, 4), Point(7, 4)],
        // NINE
        [Point(4, 7), Point(5, 7), Point(6, 7), Point(7, 7)],
        // TEN
        [Point(7, 4), Point(7, 5), Point(7, 6)],
        // ELEVEN
        [Point(2, 6), Point(3, 6), Point(4, 6), Point(5, 6), Point(6, 6), Point(7, 6)],
        // PAST
        [Point(1, 3), Point(2, 3), Point(3, 3), Point(4, 3)],
        // TO
        [Point(4, 3), Point(5, 3)],
        // FIVE
        [Point(0, 2), Point(1, 2), Point(2, 2), Point(3, 2)],
        // TEN
        [Point(1, 0), Point(3, 0), Point(4, 0)],
        // QUARTER
        [Point(0, 1), Point(1, 1), Point(2, 1), Point(3, 1), Point(4, 1), Point(5, 1), Point(6, 1)],
        // TWENTY
        [Point(1, 0), Point(2, 0), Point(3, 0), Point(4, 0), Point(5, 0), Point(6, 0)],
        // HALF
        [Point(4, 2), Point(5, 2), Point(6, 2), Point(7, 2)]
    ]

    // Get the words used to describe the current time and minute.
    //static func getWords(time: (hour: Int, minute: Int)) -> (minute: [Minute], prep: Preposition?, hour: Hour) {
    static func getWords(hourNumber: Int, minuteNumber: Int) -> Words {
        var minuteWord: [MinuteWord] = []
        var hourWord = HourWord(rawValue: hourNumber < 12 ? hourNumber : hourNumber % 12)!
        var prepWord: PrepositionWord? = nil

        switch minuteNumber {
        case 5..<10:
            minuteWord.append(.five)
            prepWord = .past
        case 10..<15:
            minuteWord.append(.ten)
            prepWord = .past
        case 15..<20:
            minuteWord.append(.quarter)
            prepWord = .past
        case 20..<25:
            minuteWord.append(.twenty)
            prepWord = .past
        case 25..<30:
            minuteWord.append(.twenty)
            minuteWord.append(.five)
            prepWord = .past
        case 30..<35:
            minuteWord.append(.half)
            prepWord = .past
        case 35..<40:
            //minuteWord.append(contentsOf: [.twenty, .five])
            minuteWord.append(.twenty)
            minuteWord.append(.five)
            prepWord = .to
            hourWord = HourWord(rawValue: hourNumber + 1 < 12 ? (hourNumber + 1) : (hourNumber + 1) % 12)!
        case 40..<45:
            minuteWord.append(.twenty)
            prepWord = .to
            hourWord = HourWord(rawValue: hourNumber + 1 < 12 ? (hourNumber + 1) : (hourNumber + 1) % 12)!
        case 45..<50:
            minuteWord.append(.quarter)
            prepWord = .to
            hourWord = HourWord(rawValue: hourNumber + 1 < 12 ? (hourNumber + 1) : (hourNumber + 1) % 12)!
        case 50..<55:
            minuteWord.append(.ten)
            prepWord = .to
            hourWord = HourWord(rawValue: hourNumber + 1 < 12 ? (hourNumber + 1) : (hourNumber + 1) % 12)!
        case 55..<60:
            minuteWord.append(.five)
            prepWord = .to
            hourWord = HourWord(rawValue: hourNumber + 1 < 12 ? (hourNumber + 1) : (hourNumber + 1) % 12)!
        default: break
        }

        return Words(hourWord: hourWord, prepWord: prepWord, minuteWord: minuteWord)
    }
}