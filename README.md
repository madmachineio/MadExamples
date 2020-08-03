# Examples

## GettingStarted

* [Blink](https://github.com/madmachineio/Examples/tree/master/GettingStarted/Blink) - output 3.3 volts and 0 volt on a digital pin alternatively to blink the onboard led.

* [PWMBrightnessControl](https://github.com/madmachineio/Examples/tree/master/GettingStarted/PWMBrightnessControl) - brighten and dim the led continuously by increasing and decreasing the duty cycle of the PWM output.

* [ReadDigitalInput](https://github.com/madmachineio/Examples/tree/master/GettingStarted/ReadDigitalInput) - read and print the input value of digital pin D0, either true or false.

* [ReadAnalogInput](https://github.com/madmachineio/Examples/tree/master/GettingStarted/ReadAnalogInput) - read and print the input voltage of analog pin A0. The value is a float number between 0.0 and 3.3.


## SimpleIO

* [ButtoncontrolLED](https://github.com/madmachineio/Examples/tree/master/SimpleIO/ButtoncontrolLED) - when the button is pressed, the input value will be changed. If it is detected, turn on the led.

* [Debounce](https://github.com/madmachineio/Examples/tree/master/SimpleIO/Debounce) - when the button is pressed, check the input signal in a certain period to ensure the exact status of the button and then turn on the onboard led.

* [BlinkTimer](https://github.com/madmachineio/Examples/tree/master/SimpleIO/BlinkTimer) - use the timer to set intereupt and every second the led will be toggled.

* [LEDsBrightnessControl](https://github.com/madmachineio/Examples/tree/master/SimpleIO/LEDsBrightnessControl) - brighten and dim three LEDs alternatively by increasing and decreasing the duty cycle of the PWM output.

* [BrightnessAnalogIn](https://github.com/madmachineio/Examples/tree/master/SimpleIO/BrightnessAnalogIn) - set the duty cycle of the PWM output with the float number between 0.0 and 1.0 read from the analog pin.

* [BlinkAnalogIn](https://github.com/madmachineio/Examples/tree/master/SimpleIO/BlinkAnalogIn) - change the sleep time with the raw value read from analog pin to change the blink frequency.

* [PWMSoundOutput](https://github.com/madmachineio/Examples/tree/master/SimpleIO/PWMSoundOutput) - change the frequency of the PWM output to generate different notes.

* [PWMMelody](https://github.com/madmachineio/Examples/tree/master/SimpleIO/PWMMelody) - list a combination of the frequencies of different pitches to generate a harmonious melody.


## AdvancedIO

* [ILI9341](https://github.com/madmachineio/Examples/tree/master/AdvancedIO/ILI9341) - use SPI protocol to communicate with the screen to display the element.

* [LCD1602](https://github.com/madmachineio/Examples/tree/master/AdvancedIO/LCD1602) - use I2C protocol to communicate with the LCD to display the string or number.

* [MidiPlayer](https://github.com/madmachineio/Examples/tree/master/AdvancedIO/MidiPlayer) - export the data from midi file and play the music by using four PWM signal.

* [PCA9685](https://github.com/madmachineio/Examples/tree/master/AdvancedIO/PCA9685) - use I2C protocol and PWM signal to activate the servo.

* [SHT3x](https://github.com/madmachineio/Examples/tree/master/AdvancedIO/SHT3x) - use I2C protocol to communicate with the sensor to get the current temperature and humidity.

* [SSD1315](https://github.com/madmachineio/Examples/tree/master/AdvancedIO/SSD1315) - use SPI protocol to communicate with the screen to display the element.


## MakerKit

* [Mission1_Blink](https://github.com/madmachineio/Examples/tree/master/MakerKit/Mission1_Blink) - blink the onboard blue LED every second by changing the output voltage.

* [Mission2_RGB_LED](https://github.com/madmachineio/Examples/tree/master/MakerKit/Mission2_RGB_LED) - turn on and off red, green and blue LED alternatively every second.

* [Mission3_Push_Button](https://github.com/madmachineio/Examples/tree/master/MakerKit/Mission3_Push_Button) - the digital value will change from low to high when the button is pressed. Read the value to determine LED state.

* [Mission4_Potentiometer_RGB](https://github.com/madmachineio/Examples/tree/master/MakerKit/Mission4_Potentiometer_RGB) - the input value will change as we turn the potentiometer. Set the LED blink rate according to the value.

* [Mission5_Buzzer](https://github.com/madmachineio/Examples/tree/master/MakerKit/Mission5_Buzzer) - read the input value to set the PWM signal in order to play different notes.

* [Mission6_Seven_Segment_Display](https://github.com/madmachineio/Examples/tree/master/MakerKit/Mission6_Seven_Segment_Display) - use seven digital input siganl to print a number on 7-segment display.

* [Mission7_DC_Motors](https://github.com/madmachineio/Examples/tree/master/MakerKit/Mission7_DC_Motors) - turn the potentiometer and read the input value. Set the duty cycle of PWM output to set the speed of the motor.

* [Mission8_Servo_Motor](https://github.com/madmachineio/Examples/tree/master/MakerKit/Mission8_Servo_Motor) - turn the potentiometer and read the input value. Set the PWM output to change the angle of the servo between 0 and 180 degree.

* [Mission9_LCD](https://github.com/madmachineio/Examples/tree/master/MakerKit/Mission9_LCD) - use I2C protocol to communicate with LCD to display a string.

* [Mission10_Humiture_Sensor](https://github.com/madmachineio/Examples/tree/master/MakerKit/Mission10_Humiture_Sensor) - use I2C protocol to read current temperaturn and communicate with LCD to display the temperature.
