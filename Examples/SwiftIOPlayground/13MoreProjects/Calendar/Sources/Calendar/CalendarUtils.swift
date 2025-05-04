let daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
let months = [
    "January", "February", "March", "April", "May", "June", 
    "July", "August", "September", "October", "November", "December"
]

// Generate a 7x6 array representing the days of the month, 
// starting from Sunday and ending on Saturday.
func generateCalendar(year: Int, month: Int) -> [[Int]] {
    var calendarGrid = [[Int]](repeating: [Int](repeating: 0, count: 7), count: 6)

    var totalDays = daysInMonth[month - 1]

    if month == 2 && isLeapYear(year: year) {
        totalDays = 29
    }

    var currentDay = 1

    // Calculate the day of the week for the first day of the month
    let firstDayOfWeek = getDayOfWeek(year: year, month: month, day: 1)

    // Determine the starting position in the grid
    var row = 0
    var column = firstDayOfWeek

    // Place the days of the month in the grid.
    while currentDay <= totalDays {
        calendarGrid[row][column] = currentDay
        currentDay += 1
        column += 1

        // Move to the next row if necessary
        if column == 7 {
            column = 0
            row += 1
        }
    }

    return calendarGrid
}

func isLeapYear(year: Int) -> Bool {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
}

// Determine which day of the week corresponds to the given date. 
// Sunday is represented as 0.
func getDayOfWeek(year: Int, month: Int, day: Int) -> Int {
    // Calculate days until this year.
    var days = year * 365

    // Count leap days until this year.
    for i in stride(from: 4, to: year, by: 4) {
        if isLeapYear(year: i) {
            days += 1
        }
    }

    // If this year is a leap year and the month is after february, add 1 day.
    if month > 2 && isLeapYear(year: year) {
        days += 1
    }

    // Add the days of this year.
    days += daysInMonth[0..<month-1].reduce(0) { $0 + $1 }
    days += day

    // Make Sunday 0
    days -= 1
    if days < 0 {
        days += 7
    }

    return days % 7
}