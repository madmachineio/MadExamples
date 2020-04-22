/*
  Mission9 “Hello World!” LCD

  What you should see?
  The LCD screen will print "Hello, World!"

  The circuit:
  - Use LCD Module, and connect it to I2C0 Jack.

  created 2019
  by Orange J

  Try adding some code so that the display shows the hours, minutes and seconds.
  This example code is in the public domain. Visit madmachine.io for more.
*/

import SwiftIO

// I2C (I square C) is a two wire protocol to communicate between different devices.    
let i2c = I2C(Id.I2C0)
let lcd = LCD16X02(i2c)

// print a message to the LCD.
lcd.print("Hello World!", x: 0, y: 0)         // set up the LCD's number of columns and rows

