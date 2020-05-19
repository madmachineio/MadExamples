public struct TinyCanvas {

    public typealias ColorDepth = UInt32

    public enum ColorMode {
        case ARGB, RGB565, MONO
    }

    public let width: Int
    public let height: Int
    public var offsetX: Int = 0
    public var offsetY: Int = 0

    public var cursorX: Int = 0
    public var cursorY: Int = 0
    public var backColor = ColorDepth.zero
    public var foreColor = ColorDepth.max

    public let data: UnsafeRawBufferPointer

    var font: Font.Type
    var wrapString = true
    var stringSize = 1

    private let changeEndian: Bool
    private let buffer32: UnsafeMutableBufferPointer<UInt32>?
    private let buffer16: UnsafeMutableBufferPointer<UInt16>?
    private let buffer8: UnsafeMutableBufferPointer<UInt8>?

    public mutating func setForeColor(_ color: ColorDepth) {
        foreColor = color
    }

    public mutating func setWrapString(_ enable: Bool) {
        wrapString = enable
    }

    public mutating func setCursor(x: Int, y: Int) {
        cursorX = x
        cursorY = y
    }

    public mutating func setFont(_ f: Font.Type) {
        self.font = f
    }

    public mutating func setFontSize(_ s: Int) {
        self.stringSize = s
    }

    public init(width: Int, height: Int, offsetX: Int = 0, offsetY: Int = 0, color: ColorDepth = ColorDepth.zero, colorMode: ColorMode = .RGB565, changeEndian: Bool = true) {

        self.width = width
        self.height = height

        self.offsetX = offsetX
        self.offsetY = offsetY

        self.backColor = color

        self.changeEndian = changeEndian
        font = Roboto12pt.self

        switch colorMode {
        case .ARGB:
            buffer16 = nil
            buffer8 = nil
            buffer32 = UnsafeMutableBufferPointer<UInt32>.allocate(capacity: width * height)
            data = UnsafeRawBufferPointer(buffer32!)
            buffer32!.assign(repeating: color)
        case .RGB565:
            buffer32 = nil
            buffer8 = nil
            buffer16 = UnsafeMutableBufferPointer<UInt16>.allocate(capacity: width * height)
            data = UnsafeRawBufferPointer(buffer16!)
            buffer16!.assign(repeating: colorToRGB565(color))
        case .MONO:
            buffer32 = nil
            buffer16 = nil
            buffer8 = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: width * height)
            data = UnsafeRawBufferPointer(buffer8!)
            buffer8!.assign(repeating: colorToMONO(color))
        }
    }
    
    public func freeCanvas() {
        if buffer32 != nil {
            buffer32!.deallocate()
        }
        if buffer16 != nil {
            buffer16!.deallocate()
        }
        if buffer8 != nil {
            buffer8!.deallocate()
        }
    }

    @inline(__always)
    public mutating func drawPixel(x: Int, y: Int, color: ColorDepth) {
        if x < 0 || y < 0 || x >= width || y >= height {
            return
        }

        if let buffer = buffer32 {
            buffer[x + y * width] = color
        } else if let buffer = buffer16 {
            buffer[x + y * width] = colorToRGB565(color)
        } else if let buffer = buffer8 {
            buffer[x + y * width] = colorToMONO(color)
        }
    }

    @inline(__always)
    public mutating func drawPixel(x: Int, y: Int, color: ColorDepth, brushSize: Int) {
        let offset = (brushSize / 2)
        
        for blubX in 0..<brushSize {
            for blubY in 0..<brushSize {
                drawPixel(x: x + blubX - offset,
                         y: y + blubY - offset,
                         color: color)
            }
        }
    }


    @inline(__always)
    private func colorToRGB565(_ color: ColorDepth) -> UInt16 {
        if changeEndian {
            return UInt16((color & 0xF80000) >> 16) | (UInt16((color & 0x1C00) << 3) | UInt16((color & 0xE000) >> 13)) | UInt16((color & 0xF8) << 5)
        } else {
            return UInt16((color & 0xF80000) >> 8) | UInt16((color & 0xFC00) >> 5) | UInt16((color & 0xF8) >> 3)
        }
    }


    @inline(__always)
    private func colorToMONO(_ color: ColorDepth) -> UInt8 {
        if (color & 0x800000 | color & 0x8000 | color & 0x80) > 0 {
            return 0xFF
        } else {
            return 0x00
        }
    }

    public mutating func clear(color: ColorDepth? = nil) {
        if let c = color {
            backColor = c
        }
        
        if let buffer = buffer32 {
            buffer.assign(repeating: backColor)
        } else if let buffer = buffer16 {
            buffer.assign(repeating: colorToRGB565(backColor))
        } else if let buffer = buffer8 {
            buffer.assign(repeating: colorToMONO(backColor))
        }
    }
}


extension TinyCanvas {
    private mutating func drawChar(x: Int, y: Int, _ c: UInt8, color: ColorDepth, size: Int = 1) {
        let c = Int(c) - font.first
        let glyphDes = font.glyphDescriptions[c]
        var bo = glyphDes.bitmapIndex
        let w = glyphDes.boxWidth
        let h = glyphDes.boxHeight
        let xo = glyphDes.offsetX
        let yo = glyphDes.offsetY

        var bit: UInt8 = 0
        var bits: UInt8 = 0

        for yy in 0..<h {
            for xx in 0..<w {
                if (bit & 7) == 0 {
                    bits = font.bitmap[Int(bo)]
                    bo += 1
                }
                bit = bit &+ 1
                if (bits & 0x80) > 0 {
                    if size == 1 {
                        drawPixel(x: x + xo + xx, y: y + yo + yy, color: color)
                    } else {
                        fillRect(x: x + (xo + xx) * size, y: y + (yo + yy) * size, width: size, height: size, color: color)
                    }
                }
                bits <<= 1;
            }
        }
    }

    private mutating func drawChar(_ c: UInt8, color: ColorDepth, size: Int = 1) {
        if c == 0x0A {
            cursorX = 0
            cursorY += font.advanceY * size
        } else if c != 0x0D {
            let glyph = font.glyphDescriptions[Int(c) - font.first]
            let w = glyph.boxWidth
            let h = glyph.boxHeight

            if w > 0 && h > 0 {
                let xo = glyph.offsetX
                if wrapString && (cursorX + size * (xo + w) > width) {
                    cursorX = 0
                    cursorY += font.advanceY * size
                }
                drawChar(x: cursorX, y: cursorY, c, color: color, size: size)
            }
            cursorX += glyph.advanceX * size
        }
    }

    public mutating func drawString(x: Int, y: Int, _ str: String, color: ColorDepth? = nil, size: Int? = nil) {
        var _color: ColorDepth
        var _size: Int

        if let c = color {
            _color = c
        } else {
            _color = foreColor
        }

        if let s = size {
            _size = s
        } else {
            _size = stringSize
        }

        let data: [UInt8] = Array(str.utf8)

        setCursor(x: x, y: y)

        data.forEach { ch in
            drawChar(ch, color: _color, size: _size)
        } 
    }

    public mutating func drawString(_ str: String, color: ColorDepth? = nil, size: Int? = nil) {
        var _color: ColorDepth
        var _size: Int

        if let c = color {
            _color = c
        } else {
            _color = foreColor
        }

        if let s = size {
            _size = s
        } else {
            _size = stringSize
        }

        let data: [UInt8] = Array(str.utf8)

        data.forEach { c in
            drawChar(c, color: _color, size: _size)
        } 
    }    
}






extension TinyCanvas {

    public mutating func drawLine(x1: Int, y1: Int, x2: Int, y2: Int, color: ColorDepth? = nil) {
        var x1 = x1
        var y1 = y1
        var x2 = x2
        var y2 = y2
        var _color: ColorDepth
        if let c = color {
            _color = c
        } else {
            _color = foreColor
        }

        if x1 == x2 {
            if y1 > y2 {
                swap(&y1, &y2)
            }
            drawFastVLine(x: x1, y: y1, height: y2 - y1 + 1, color: _color)
        } else if y1 == y2 {
            if x1 > x2 {
                swap(&x1, &x2)
            }
            drawFastHLine(x: x1, y: y1, width: x2 - x1 + 1, color: _color)
        } else {
            let steep = abs(y2 - y1) > abs(x2 - x1)

            if steep {
                swap(&x1, &y1)
                swap(&x2, &y2)
            }

            if x1 > x2 {
                swap(&x1, &x2)
                swap(&y1, &y2)
            }

            let dx = x2 - x1
            let dy = abs(y2 - y1)

            var err = dx / 2
            var ystep: Int

            if y1 < y2 {
                ystep = 1
            } else {
                ystep = -1
            }

            (x1...x2).forEach { val in
                if steep {
                    drawPixel(x: y1, y: val, color: _color)
                } else {
                    drawPixel(x: val, y: y1, color: _color)
                }
                err -= dy
                if err < 0 {
                    y1 += ystep
                    err += dx
                }
            }
        }
    }

    private mutating func drawFastHLine(x: Int, y: Int, width: Int, color: ColorDepth) {
        if width > 0 {
            (0..<width).forEach { step in
                drawPixel(x: x + step, y: y, color: color)
            }
        }
    }

    private mutating func drawFastVLine(x: Int, y: Int, height: Int, color: ColorDepth) {
        if height > 0 {
            (0..<height).forEach { step in
                drawPixel(x: x, y: y + step, color: color)
            }
        }
    }
}



extension TinyCanvas {
    public mutating func drawCircle(x x0: Int, y y0: Int, r: Int, color: ColorDepth? = nil, corners: Corners = .all) {
        var f = 1 - r
        var ddF_x = 1
        var ddF_y = -2 * r
        var x = 0
        var y = r
        var _color: ColorDepth
        if let c = color {
            _color = c
        } else {
            _color = foreColor
        }

        if corners.contains(.top) {
            drawPixel(x: x0, y: y0 + r, color: _color)
        }
        if corners.contains(.right) {
            drawPixel(x: x0 + r, y: y0, color: _color)
        }
        if corners.contains(.bottom) {
            drawPixel(x: x0, y: y0 - r, color: _color)
        }
        if corners.contains(.left) {
            drawPixel(x: x0 - r, y: y0, color: _color)
        }

        while (x < y) {
            if (f >= 0) {
                y -= 1
                ddF_y += 2
                f += ddF_y
            }
            x += 1
            ddF_x += 2
            f += ddF_x

            if corners.contains(.topLeft) {
                drawPixel(x: x0 - y, y: y0 - x, color: _color)
                drawPixel(x: x0 - x, y: y0 - y, color: _color)
            }
            if corners.contains(.topRight) {
                drawPixel(x: x0 + x, y: y0 - y, color: _color)
                drawPixel(x: x0 + y, y: y0 - x, color: _color)
            }
            if corners.contains(.bottomLeft) {
                drawPixel(x: x0 - y, y: y0 + x, color: _color)
                drawPixel(x: x0 - x, y: y0 + y, color: _color)
            }
            if corners.contains(.bottomRight) {
                drawPixel(x: x0 + x, y: y0 + y, color: _color)
                drawPixel(x: x0 + y, y: y0 + x, color: _color)
            }
        }
    }

    public mutating func fillCircle(x x0: Int, y y0: Int, r: Int, color: ColorDepth? = nil, corners: Corners = .all, delta: Int = 0) {
        var delta = delta
        var f = 1 - r
        var ddF_x = 1
        var ddF_y = -2 * r
        var x = 0
        var y = r
        var px = x
        var py = y
        var _color: ColorDepth
        if let c = color {
            _color = c
        } else {
            _color = foreColor
        }

        if delta == 0 {
            drawFastVLine(x: x0, y: y0 - r, height: 2 * r + 1, color: _color)
        }

        delta += 1

        while (x < y) {
            if (f >= 0) {
                y -= 1
                ddF_y += 2
                f += ddF_y
            }
            x += 1
            ddF_x += 2
            f += ddF_x

            if x < y + 1 {
                if corners.contains(.right) {
                    drawFastVLine(x: x0 + x, y: y0 - y, height: 2 * y + delta, color: _color)
                }
                if corners.contains(.left) {
                    drawFastVLine(x: x0 - x, y: y0 - y, height: 2 * y + delta, color: _color)
                }
            }

            if y != py {
                if corners.contains(.right) {
                    drawFastVLine(x: x0 + py, y: y0 - px, height: 2 * px + delta, color: _color)
                }
                if corners.contains(.left) {
                    drawFastVLine(x: x0 - py, y: y0 - px, height: 2 * px + delta, color: _color)
                }
                py = y
            }
            px = x
        }
    }
}



extension TinyCanvas {
    public mutating func drawBitmap(x: Int, y: Int, width: Int, height: Int, data: [ColorDepth]) {
        guard data.count >= width * height else { return }
        var index = 0

        for cY in y..<y + height {
            for cX in x..<x + width {
                drawPixel(x: cX, y: cY, color: data[index])
                index += 1
            }
        }
    }

    public mutating func drawBitmap(x: Int, y: Int, width: Int, height: Int, data: UnsafeBufferPointer<UInt32>) {
        guard data.count >= width * height else { return }
        var index = 0

        for cY in y..<y + height {
            for cX in x..<x + width {
                drawPixel(x: cX, y: cY, color: data[index])
                index += 1
            }
        }
    }
}


extension TinyCanvas {
    public mutating func drawRect(x: Int, y: Int, width w: Int, height h: Int, color: ColorDepth? = nil) {
        var _color: ColorDepth
        if let c = color {
            _color = c
        } else {
            _color = foreColor
        }

        drawFastHLine(x: x, y: y, width: w, color: _color)
        drawFastHLine(x: x, y: y + h - 1, width: w, color: _color)
        drawFastVLine(x: x, y: y, height: h, color: _color)
        drawFastVLine(x: x + w - 1, y: y, height: h, color: _color)
    }

    public mutating func fillRect(x: Int, y: Int, width w: Int, height h: Int, color: ColorDepth? = nil) {
        var _color: ColorDepth
        if let c = color {
            _color = c
        } else {
            _color = foreColor
        }

        (x..<x + w).forEach { val in
            drawFastVLine(x: val, y: y, height: h, color: _color)
        }
    }

    public mutating func drawRoundRect(x: Int, y: Int, width w: Int, height h: Int, r: Int, color: ColorDepth? = nil) {
        var r = r
        var _color: ColorDepth
        if let c = color {
            _color = c
        } else {
            _color = foreColor
        }
        let maxRadius = ((w < h) ? w : h) / 2
        if r > maxRadius {
            r = maxRadius
        }
        drawFastHLine(x: x + r, y: y, width: w - 2 * r, color: _color)
        drawFastHLine(x: x + r, y: y + h - 1, width: w - 2 * r, color: _color)
        drawFastVLine(x: x, y: y + r, height: h - 2 * r, color: _color)
        drawFastVLine(x: x + w - 1, y: y + r, height: h - 2 * r, color: _color)

        drawCircle(x: x + r, y: y + r, r: r, color: _color, corners: .topLeft) 
        drawCircle(x: x + w - r - 1, y: y + r, r: r, color: _color, corners: .topRight) 
        drawCircle(x: x + w - r - 1, y: y + h - r - 1, r: r, color: _color, corners: .bottomRight) 
        drawCircle(x: x + r, y: y + h - r - 1, r: r, color: _color, corners: .bottomLeft) 
    }

    public mutating func fillRoundRect(x: Int, y: Int, width w: Int, height h: Int, r: Int, color: ColorDepth? = nil) {
        var r = r
        var _color: ColorDepth
        if let c = color {
            _color = c
        } else {
            _color = foreColor
        }
        let maxRadius = ((w < h) ? w : h) / 2
        if r > maxRadius {
            r = maxRadius
        }
        fillRect(x: x + r, y: y, width: w - 2 * r, height: h, color: _color)

        fillCircle(x: x + w - r - 1, y: y + r, r: r, color: _color, corners: .right, delta: h - 2 * r - 1) 
        fillCircle(x: x + r, y: y + r, r: r, color: _color, corners: .left, delta: h - 2 * r - 1) 
    }

}

public struct Corners: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let topLeft      = Corners(rawValue: 1 << 0)
    public static let topRight     = Corners(rawValue: 1 << 1)
    public static let bottomLeft   = Corners(rawValue: 1 << 2)
    public static let bottomRight  = Corners(rawValue: 1 << 3)
    
    public static let all: Corners      = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    public static let top: Corners      = [.topLeft, .topRight]
    public static let bottom: Corners   = [.bottomLeft, .bottomRight]
    public static let left: Corners     = [.topLeft, .bottomLeft]
    public static let right: Corners    = [.topRight, .bottomRight]
}

public enum Color {
    static let white: UInt32  = 0xFFFFFF
    static let black: UInt32  = 0x000000
    static let gray: UInt32   = 0x808080
    static let silver: UInt32 = 0xc0c0c0
    static let red: UInt32    = 0xff0000
    static let maroon: UInt32 = 0x800000
    static let lime: UInt32   = 0x00ff00
    static let green: UInt32  = 0x008000
    static let olive: UInt32  = 0x808000
    static let blue: UInt32   = 0x0000ff
    static let navy: UInt32   = 0x000080
    static let teal: UInt32   = 0x008080
    static let cyan: UInt32   = 0x00ffff
    static let aqua: UInt32   = 0x00ffff
    static let purple: UInt32 = 0x800080
    static let magenta: UInt32 = 0xff00ff
    static let orange: UInt32 = 0xffa500
    static let yellow: UInt32 = 0xffff00
}

public struct GlyphDescription {
    let bitmapIndex: Int
    let boxWidth: Int
    let boxHeight: Int
    let advanceX: Int
    let offsetX: Int
    let offsetY: Int

    init(_ bitmapIndex: Int,
         _ boxWidth: Int,
         _ boxHeight: Int,
         _ advanceX: Int,
         _ offsetX: Int,
         _ offsetY: Int) {
             self.bitmapIndex = bitmapIndex
             self.boxWidth = boxWidth
             self.boxHeight = boxHeight
             self.advanceX = advanceX
             self.offsetX = offsetX
             self.offsetY = offsetY
         }
}

public protocol Font {
    static var bitmap: ContiguousArray<UInt8> { get }
    static var glyphDescriptions: ContiguousArray<GlyphDescription> { get } 
    static var first: Int { get }
    static var last: Int { get }
    static var advanceY: Int { get }
}