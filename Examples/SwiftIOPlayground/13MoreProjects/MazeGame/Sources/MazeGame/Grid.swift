struct Wall {
    var top: Bool
    var right: Bool
    var bottom: Bool
    var left: Bool
}

struct Grid {
    let x: Int
    let y: Int
    var walls = Wall(top: true, right: true, bottom: true, left: true)
    var visited = false
}