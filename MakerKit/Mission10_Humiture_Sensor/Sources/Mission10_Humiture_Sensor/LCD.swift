import SwiftIO

class LCD16X02 {

	private enum Command {
		static let clearDisplay: UInt8 = 0x01
    	static let returnHome: UInt8 = 0x02
    	static let entryModeSet: UInt8 = 0x04
    	static let displayControl: UInt8 = 0x08
    	static let cursorShift: UInt8 = 0x10
    	static let functionSet: UInt8 = 0x20
    	static let setCGRAMAddr: UInt8 = 0x40
    	static let setDDRAMAddr: UInt8 = 0x80
	}

	private enum EntryMode {
    	static let entryRight: UInt8 = 0x00
    	static let entryLeft: UInt8 = 0x02
    	static let entryShiftIncrement: UInt8 = 0x01
    	static let entryShiftDecrement: UInt8 = 0x00
	}

	private enum Control {
    	static let displayOn: UInt8 = 0x04
    	static let displayOff: UInt8 = 0x00
    	static let cursorOn: UInt8 = 0x02
    	static let cursorOff: UInt8 = 0x00
    	static let blinkOn: UInt8 = 0x01
    	static let blinkOff: UInt8 = 0x00
	}

	private enum Shift {
    	static let displayMove: UInt8 = 0x08
    	static let cursorMove: UInt8 = 0x00
    	static let moveRight: UInt8 = 0x04
    	static let moveLeft: UInt8 = 0x00
	}

	private enum Mode {
    	static let _8BitMode: UInt8 = 0x10
    	static let _4BitMode: UInt8 = 0x00
    	static let _2Line: UInt8 = 0x08
    	static let _1Line: UInt8 = 0x00
    	static let _5x10Dots: UInt8 = 0x04
    	static let _5x8Dots: UInt8 = 0x00
	}
    
  	let address: UInt8 = 0x3E
  

  	let i2c: I2C
  
  	var displayFunctionState: UInt8
  	var displayControlState: UInt8
  	var displayModeState: UInt8
  	var numLines: UInt8
  	var currLine: UInt8
  	
    
  	convenience init(_ i2c: I2C) {
      	self.init(i2c, 16, 2, 0)
    }
    
  	init(_ i2c: I2C, _ cols: UInt8, _ rows: UInt8, _ dotSize: UInt8) {
      	self.i2c = i2c
      
      	displayFunctionState = 0
      	displayControlState = 0
      	displayModeState = 0
      	
      	if rows > 1 {
          	displayFunctionState |= Mode._2Line
        }

      	numLines = rows
      	currLine = 0
      	
      	if dotSize != 0 && rows == 1 {
          	displayFunctionState |= Mode._5x10Dots
        }
      
      	command(Command.functionSet | displayFunctionState)
      	wait(us: 4500)
    
      	command(Command.functionSet | displayFunctionState)
      	wait(us: 150)
      
      	command(Command.functionSet | displayFunctionState)
      	command(Command.functionSet | displayFunctionState)
      
      	displayControlState = 	Control.displayOn | Control.cursorOff | Control.blinkOff
      	turnOn()
      	
      	clear()
      	
      	displayModeState = EntryMode.entryLeft | EntryMode.entryShiftDecrement
      	command(Command.entryModeSet | displayModeState)
    }
  

  
  	func turnOn() {
      	displayControlState |= Control.displayOn
      	command(Command.displayControl | displayControlState)
    }

  	func turnOff() {
      	displayControlState &= ~Control.displayOn;
      	command(Command.displayControl | displayControlState)
    }
  
  	func clear() {
      	command(Command.clearDisplay)
      	wait(us: 2000)
    }

	func home() {
		command(Command.returnHome)
		wait(us: 2000)
	}
  


  	func setCursor(_ x: UInt8, _ y: UInt8) {
      	let val: UInt8 = y == 0 ? x | 0x80 : x | 0xc0
      	command(val)
    }

	func noCursor() {
		displayControlState &= ~Control.cursorOn
		command(Command.displayControl | displayControlState)
	}

	func cursor() {
		displayControlState |= Control.cursorOn
		command(Command.displayControl | displayControlState)
	}

	func noBlink() {
		displayControlState &= ~Control.blinkOn
		command(Command.displayControl | displayControlState)
	}

	func blink() {
		displayControlState |= Control.blinkOn
		command(Command.displayControl | displayControlState)
	}
	
	func scrollLeft() {
      	command(Command.cursorShift | Shift.displayMove | Shift.moveLeft)
    }
  
  	func scrollRight() {
      	command(Command.cursorShift | Shift.displayMove | Shift.moveRight)
    }

	func leftToRight() {
		displayModeState |= EntryMode.entryLeft
		command(Command.entryModeSet | displayModeState)
	}

	func rightToLeft() {
		displayModeState &= ~EntryMode.entryLeft
		command(Command.entryModeSet | displayModeState)
	}

	func autoScroll() {
		displayModeState |= EntryMode.entryShiftIncrement
		command(Command.entryModeSet | displayModeState)
	}

	func noAutoScroll() {
		displayModeState &= ~EntryMode.entryShiftIncrement
		command(Command.entryModeSet | displayModeState)
	}

  	func command(_ value: UInt8) {
    	let data: [UInt8] = [0x80, value]
      	i2c.write(data, to: address)
    }

	func clear(_ count: UInt8, x: UInt8, y: UInt8) {
		let data: [UInt8] = [0x40, 0x20]

		setCursor(x, y)
		for _ in 1...count {
			i2c.write(data, to: address)
		}
		setCursor(x, y)
	}

    
  	func print(_ str: String) {
      	let array: [UInt8] = Array(str.utf8)
      	var data: [UInt8] = [0x40, 0]	
      
      	for item in array {
          	data[1] = UInt8(item)
          	i2c.write(data, to: address)
        }
    }

    func print(_ num: Int, x: UInt8, y: UInt8) {
        print(String(num), x: x, y: y)
    }
    
  	func print(_ str: String, x: UInt8, y: UInt8) {
      	setCursor(x, y)
      	print(str)
    }
    

}
