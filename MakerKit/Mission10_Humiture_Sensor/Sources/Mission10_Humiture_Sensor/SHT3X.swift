/*
SHT3x-DIS is the next generation of Sensirion’s temperature and humidity sensors. It builds on a new sensor chip that is at the heart of Sensirion’s new humidity and temperature platform.The SHT3x-DIS has increased intelligence, reliability and improved accuracy specifications compared to its predecessor.Its functionality includes enhanced signal processing, two distinctive and user selectable I2C addresses and communication speeds of up to 1 MHz.
*/

import SwiftIO

class SHT3X{
        
      private enum Address{
        static let SHT3X_ADDRESS_A: UInt8 = 0x44
        static let SHT3X_ADDRESS_B: UInt8 = 0x45
        static let SHT3X_GENERALL_CALL_ADDRESS: UInt16 = 0x0006
    }
    
    private enum Comman{
        static let Mode_Set_A:UInt16 = 0x2C0D 		// set as Single Shot Mode
        static let Mode_Set_B:UInt16 = 0x2322		// set shot four times per second
        static let Fetch_Data:UInt16 = 0xE000		// get the data
        static let ART_ON:UInt16 = 0x2B32
        static let Break_Periodoc_mode:UInt16 = 0x3093
        static let Soft_Reset:UInt16 = 0x30A2 		// soft reset
        static let Heater_Enable:UInt16 = 0x306D
        static let Heater_Disable:UInt16 = 0x3066
        static let Read_Status:UInt16 = 0xF32D
        static let Clear_status:UInt16 = 0x3041
    }
    
    private enum Flag{
        static let R_H:Int = 0
        static let T_C:Int = 1
        static let T_F:Int = 2
        
        static let CRC_ON:Int = 1
        static let CRC_OFF:Int = 0
        
        static let ACK:Int = 1
        static let NACK:Int = 0
        
        static let write:Int = 0
        static let read:Int = 1
        
        static let Repeatability_Low:Int = 0
        static let Repeatability_Medium:Int = 1
        static let Repeatability_High:Int = 2
        
        static let MPS_0_5:Int = 0
        static let MPS_1:Int = 1
        static let MPS_2:Int = 2
        static let MPS_4:Int = 3
        static let MPS_10:Int = 4
        
        static let CRC_Statues:Int = 0
        static let Command_statues:Int = 1
    }
        
   /* private enum Data_Process{
        static let SHT3X_TC(date) = (175 * (float)date / 65535 -45)
        static let SHT3X_TC(date) = (315 * (float)date / 65535 -49)
        static let SHT3X_TC(date) = (100 * (float)date / 65535)
    }*/
    
    private enum etI2cAck{
        static let ACK:Int = 0
        static let NACK:Int = 1
    }
    
  	let i2c: I2C
  	let address: UInt8 = 0x44
  	
  	init(_ i2c: I2C) {
      	self.i2c = i2c
    }
  
  	func writeCommand(_ cmd: UInt16) {
      	let array: [UInt8] = [UInt8(cmd >> 8), UInt8(cmd & 0xFF)]
      	i2c.write(array, to: address)
    }
  
  	func readStatus() -> UInt32 {
      	writeCommand(0x3780)
      	let array = i2c.read(count: 2, from: address)
      	let value: UInt32 = UInt32(array[0] << 16) | UInt32(array[1])
      	return value
    }
    
	func Init(){
        writeCommand(0x44)
        sleep(ms: 1)
   		writeCommand(0x2322)
   		sleep(ms: 1)
   		writeCommand(0x89)
   		sleep(ms: 1)
     	writeCommand(0xE000)
    }
}
