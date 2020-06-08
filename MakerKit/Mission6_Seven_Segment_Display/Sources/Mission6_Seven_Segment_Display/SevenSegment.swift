/*
  Show number 0-9 on a Common Anode 7-segment LED display.
    A
   ---
F |   | B
  | G |
   ---
E |   | C
  |   |
   ---
    D
  This example code is in the public domain.
 */

import SwiftIO

class SevenSegment {
    // Initialize the seven digital pins which are connected to the segment pins.
    static let a = DigitalOut(Id.D8)
    static let b = DigitalOut(Id.D7)
    static let c = DigitalOut(Id.D6)
    static let d = DigitalOut(Id.D5)
    static let e = DigitalOut(Id.D4)
    static let f = DigitalOut(Id.D2)
    static let g = DigitalOut(Id.D3)
    
    let leds = [a, b, c, d, e, f, g]
    // Use a binary data to store the status of each segment for the number from 0 to zero.
	let ledState: [UInt8] = [0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F]
    
    public func print(_ number: Int) {
        let num = number % 10
        let value = ledState[num] 
        
        // Get the value of each bit to determine whether the relevant segment is on or off.
        for i in 0..<7{
            let state = (value >> i) & 0x01
            if state == 0 {
                leds[i].write(true)
            } else {
                leds[i].write(false)
            }   
        }

    }
}
