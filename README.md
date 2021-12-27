# Examples

![build](https://github.com/madmachineio/MadExamples/actions/workflows/build.yml/badge.svg)
[![Discord](https://img.shields.io/discord/592743353049808899?&logo=Discord&colorB=7289da)](https://madmachine.io/discord)
[![twitter](https://img.shields.io/twitter/follow/madmachineio?label=%40madmachineio&style=social)](https://twitter.com/madmachineio)

## GettingStarted

* [Blink](./Examples/GettingStarted/Blink) - output 3.3 volts and 0 volt on a digital pin alternatively to blink the onboard led.

* [PWMBrightnessControl](./Examples/GettingStarted/PWMBrightnessControl) - brighten and dim the led continuously by increasing and decreasing the duty cycle of the PWM output.

* [ReadDigitalInput](./Examples/GettingStarted/ReadDigitalInput) - read and print the input value of digital pin D0, either true or false.

* [ReadAnalogInput](./Examples/GettingStarted/ReadAnalogInput) - read and print the input voltage of analog pin A0. The value is a float number between 0.0 and 3.3.


## SimpleIO

* [ButtoncontrolLED](./Examples/SimpleIO/ButtoncontrolLED) - when the button is pressed, the input value will be changed. If it is detected, turn on the led.

* [Debounce](./Examples/SimpleIO/Debounce) - when the button is pressed, check the input signal in a certain period to ensure the exact status of the button and then turn on the onboard led.

* [BlinkTimer](./Examples/SimpleIO/BlinkTimer) - use the timer to set intereupt and every second the led will be toggled.

* [LEDsBrightnessControl](./Examples/SimpleIO/LEDsBrightnessControl) - brighten and dim three LEDs alternatively by increasing and decreasing the duty cycle of the PWM output.

* [BrightnessAnalogIn](./Examples/SimpleIO/BrightnessAnalogIn) - set the duty cycle of the PWM output with the float number between 0.0 and 1.0 read from the analog pin.

* [BlinkAnalogIn](./Examples/SimpleIO/BlinkAnalogIn) - change the sleep time with the raw value read from analog pin to change the blink frequency.

* [PWMSoundOutput](./Examples/SimpleIO/PWMSoundOutput) - change the frequency of the PWM output to generate different notes.

* [PWMMelody](./Examples/SimpleIO/PWMMelody) - list a combination of the frequencies of different pitches to generate a harmonious melody.


## MakerKit

* [Mission1_Blink](./Examples/MakerKit/Mission1_Blink) - blink the onboard blue LED every second by changing the output voltage.

* [Mission2_RGB_LED](./Examples/MakerKit/Mission2_RGB_LED) - turn on and off red, green and blue LED alternatively every second.

* [Mission3_Push_Button](./Examples/MakerKit/Mission3_Push_Button) - the digital value will change from low to high when the button is pressed. Read the value to determine LED state.

* [Mission4_Potentiometer_RGB](./Examples/MakerKit/Mission4_Potentiometer_RGB) - the input value will change as we turn the potentiometer. Set the LED blink rate according to the value.

* [Mission5_Buzzer](./Examples/MakerKit/Mission5_Buzzer) - read the input value to set the PWM signal in order to play different notes.

* [Mission6_Seven_Segment_Display](./Examples/MakerKit/Mission6_Seven_Segment_Display) - use seven digital input siganl to print a number on 7-segment display.

* [Mission7_DC_Motors](./Examples/MakerKit/Mission7_DC_Motors) - turn the potentiometer and read the input value. Set the duty cycle of PWM output to set the speed of the motor.

* [Mission8_Servo_Motor](./Examples/MakerKit/Mission8_Servo_Motor) - turn the potentiometer and read the input value. Set the PWM output to change the angle of the servo between 0 and 180 degree.

* [Mission9_LCD](./Examples/MakerKit/Mission9_LCD) - use I2C protocol to communicate with LCD to display a string.

* [Mission10_Humiture_Sensor](./Examples/MakerKit/Mission10_Humiture_Sensor) - use I2C protocol to read current temperaturn and communicate with LCD to display the temperature.
