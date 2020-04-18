# Examples

## GetStarted

* [Blink](https://github.com/madmachineio/Examples/tree/master/GetStarted/Blink) - output 3.3 volts and 0 volt on a digital pin alternatively to blink the onboard led.

* [PWM_Brightness_Control](https://github.com/madmachineio/Examples/tree/master/GetStarted/PWM_Brightness_Control) - brighten and dim the led continuously by increasing and decreasing the duty cycle of the PWM output.

* [Read_Digital_Input](https://github.com/madmachineio/Examples/tree/master/GetStarted/Read_Digital_Input) - read and print the input value of digital pin D0, either true or false.

* [Read_Analog_Input](https://github.com/madmachineio/Examples/tree/master/GetStarted/Read_Analog_Input) - read and print the input voltage of analog pin A0. The value is a float number between 0.0 and 3.3.


## SimpleIO

* [Button_control_LED](https://github.com/madmachineio/Examples/tree/master/SimpleIO/Button_control_LED) - when the button is pressed, the input value will be changed. If it is detected, turn on the led.

* [Debounce](https://github.com/madmachineio/Examples/tree/master/SimpleIO/Debounce) - when the button is pressed, check the input signal in a certain period to ensure the exact status of the button and then turn on the onboard led.


* [Blink_Timer](https://github.com/madmachineio/Examples/tree/master/SimpleIO/Blink_Timer) - use the timer to set intereupt and every second the led will be toggled.

* [LEDs_Brightness_Control](https://github.com/madmachineio/Examples/tree/master/SimpleIO/LEDs_Brightness_Control) - brighten and dim three LEDs alternatively by cincreasing and decreasing the duty cycle of the PWM output.

* [Brightness_AnalogIn](https://github.com/madmachineio/Examples/tree/master/SimpleIO/Brightness_AnalogIn) - set the duty cycle of the PWM output with the float number between 0.0 and 1.0 read from the analog pin.

* [Blink_AnalogIn](https://github.com/madmachineio/Examples/tree/master/SimpleIO/Blink_AnalogIn) - change the sleep time with the raw value read from analog pin to change the blink frequency.

* [PWM_Sound_Output](https://github.com/madmachineio/Examples/tree/master/SimpleIO/PWM_Sound_Output) - change the frequency of the PWM output to generate different notes.

* [PWM_Melody](https://github.com/madmachineio/Examples/tree/master/SimpleIO/PWM_Melody) - list a combination of the frequencies of different pitches to generate a harmonious melody.


## AdvancedIO
* [SHT3x](https://github.com/madmachineio/Examples/tree/master/AdvancedIO/SHT3x) - use I2C protocol to communicate with the sensor to get the current temperature and humidity.
