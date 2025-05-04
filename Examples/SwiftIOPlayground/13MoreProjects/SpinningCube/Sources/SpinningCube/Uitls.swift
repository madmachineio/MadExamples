// Calculate the projection of a point onto a 2D plane using perspective projection. 
// `distance` refers to the distance from the viewer. 
func project(distance: Float, point: [[Float]]) -> [[Float]] {
    let z = 1 / (distance - point[2][0])
    let projectionMatrix: [[Float]] = [
        [z, 0, 0], 
        [0, z, 0]
    ]

    return matrixMultiply(projectionMatrix, point)
}

// Rotate a point around the x, y, and z axes by a given angle.
func rotate(_ point: [[Float]], angle: Float) -> [[Float]] {
    var rotated = matrixMultiply(rotateX(angle), point)
    rotated = matrixMultiply(rotateY(angle), rotated)
    rotated = matrixMultiply(rotateZ(angle), rotated)
    return rotated
}

// Rotate around x-axis.
func rotateX(_ angle: Float) -> [[Float]] {
    return [[1, 0, 0],
    [0, cosf(angle), -sinf(angle)],
    [0, sinf(angle), cosf(angle)]]
}

// Rotate around y-axis.
func rotateY(_ angle: Float) -> [[Float]] {
    return [[cosf(angle), 0, sinf(angle)],
    [0, 1, 0],
    [-sinf(angle), 0, cosf(angle)]]
}

// Rotate around z-axis.
func rotateZ(_ angle: Float) -> [[Float]] {
    return [[cosf(angle), -sinf(angle), 0],
    [sinf(angle), cosf(angle), 0],
    [0, 0, 1]]
}

func matrixMultiply(_ matrix1: [[Float]], _ matrix2: [[Float]]) -> [[Float]] {
    // Check if matrices are compatible for multiplication
    guard matrix1[0].count == matrix2.count else {
        return [[]]
    }

    // Initialize result matrix with zeros
    var result = Array(repeating: Array(repeating: Float(0), count: matrix2[0].count), count: matrix1.count)

    // Perform matrix multiplication
    for i in 0..<matrix1.count {
        for j in 0..<matrix2[0].count {
            for k in 0..<matrix2.count {
                result[i][j] += matrix1[i][k] * matrix2[k][j]
            }
        }
    }

    return result
}


@_extern(c, "cosf")
func cosf(_: Float) -> Float

@_extern(c, "sinf")
func sinf(_: Float) -> Float