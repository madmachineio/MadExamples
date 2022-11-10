# MadExamples


![build](https://github.com/madmachineio/MadExamples/actions/workflows/build.yml/badge.svg)
[![Discord](https://img.shields.io/discord/592743353049808899?&logo=Discord&colorB=7289da)](https://madmachine.io/discord)
[![twitter](https://img.shields.io/twitter/follow/madmachineio?label=%40madmachineio&style=social)](https://twitter.com/madmachineio)


The MadExamples repository contains a set of examples for you to dive into physical programming and learn how to program the boards using Swift.

## Tutorials

These examples come with [detailed tutorials](https://docs.madmachine.io/projects/overview) about background knowledge, circuit connection and code explanation. It's a good idea to follow these guides and then try the examples.

As for how to run these examples on your board, check [this step-by-step guide](https://docs.madmachine.io/overview/advanced/run-example).

## Examples

All examples are divided into several parts:

### GettingStarted

These examples show some basic usages and concepts to get started with the board. This part is based on any type of our board and you may need some other frequently-used components.

* [Blink](./Examples/GettingStarted/Blink) - output 3.3 volts and 0 volt on a digital pin alternatively to blink the onboard LED.

* [BreathingLED](./Examples/GettingStarted/BreathingLED) - brighten and dim an LED continuously by increasing and decreasing the duty cycle of the PWM output.

* [ReadDigitalInput](./Examples/GettingStarted/ReadDigitalInput) - read and print the input value of a digital pin, either true or false.

* [ReadAnalogInput](./Examples/GettingStarted/ReadAnalogInput) - read and print the input voltage of an analog pin. The value is a float number between 0.0 and 3.3.


### SimpleIO

These examples introduce more interesting projects after GettingStated. This part is based on any type of our board and you may need some other frequently-used components.

* [BlinkRate](./Examples/SimpleIO/BlinkRate) - adjust the blink rate using a potentiometer.

* [BlinkTimer](./Examples/SimpleIO/BlinkTimer) - use a timer to blink an LED.

* [BrightnessControl](./Examples/SimpleIO/BrightnessControl) - control the brightness of an LED using a potentiometer.

* [Debounce](./Examples/SimpleIO/Debounce) - use a debounce method to check if a button is pressed.

* [LEDSwitch](./Examples/SimpleIO/LEDSwitch) - use a button as an LED switch. If a button is pressed, turn on the LED.

* [PWMMelody](./Examples/SimpleIO/PWMMelody) - play a fragment of a melody using a buzzer.

* [PWMSoundOutput](./Examples/SimpleIO/PWMSoundOutput) - play a scale using a buzzer.

* [RGBBreathingLEDs](./Examples/SimpleIO/RGBBreathingLEDs) - brighten and dim RGB LEDs alternatively by increasing and decreasing the duty cycle of the PWM output.


### MakerKit

These examples provide dozens of missions that come with the SwiftIO Maker kit to explore all modules.

* [Mission1_Blink](./Examples/MakerKit/Mission1_Blink) - blink the onboard blue LED every second by changing the output voltage.

* [Mission2_RGB_LED](./Examples/MakerKit/Mission2_RGB_LED) - turn on and off red, green and blue LED alternatively every second.

* [Mission3_Push_Button](./Examples/MakerKit/Mission3_Push_Button) - turn on the LED if the button is pressed.

* [Mission4_Potentiometer_RGB](./Examples/MakerKit/Mission4_Potentiometer_RGB) - change the LED blink rate by rotating a potentiometer.

* [Mission5_Buzzer](./Examples/MakerKit/Mission5_Buzzer) - change the buzzer sound pitch by rotating a potentiometer.

* [Mission6_Seven_Segment_Display](./Examples/MakerKit/Mission6_Seven_Segment_Display) - show a number on a 7-segment display.

* [Mission7_DC_Motors](./Examples/MakerKit/Mission7_DC_Motors) - turn a potentiometer to set the speed of a motor.

* [Mission8_Servo_Motor](./Examples/MakerKit/Mission8_Servo_Motor) - turn a potentiometer to change the angle of a servo between 0 and 180 degrees.

* [Mission9_LCD](./Examples/MakerKit/Mission9_LCD) - use I2C protocol to communicate with LCD to display a string.

* [Mission10_Humiture_Sensor](./Examples/MakerKit/Mission10_Humiture_Sensor) - use I2C protocol to read the current temperature and communicate with 16x2 LCD to display the temperature.

* [Mission11_Reproduce_Mission10](./Examples/MakerKit/Mission11_Reproduce_Mission10) - display temperature on a 16x2 LCD using external libraries.

* [Mission12_Buzzer_Music](./Examples/MakerKit/Mission12_Buzzer_Music) - play a piece of music according to the score.


### SwiftIOCircuitPlaygrounds

These examples allow you to get fully acquainted with hardware programming in Swift using the kit. A series of demo projects walk you through the most basic knowledge and gradually increase in complexity to show more advanced use cases, like sound and graphic display. 

* [C01S01LEDBlink](./Examples/SwiftIOCircuitPlaygrounds/C01S01LEDBlink) - blink an LED per second.
* [C01S01LEDMorseCode](./Examples/SwiftIOCircuitPlaygrounds/C01S01LEDMorseCode) - blink an LED to send a morse code message.
* [C01S02ButtonInterrupt](./Examples/SwiftIOCircuitPlaygrounds/C01S02ButtonInterrupt) - use the interrupt technique to detect button presses.
* [C01S02ButtonLED](./Examples/SwiftIOCircuitPlaygrounds/C01S02ButtonLED) - use a button to turn on/off an LED.
* [C01S02TimerLEDToggle](./Examples/SwiftIOCircuitPlaygrounds/C01S02TimerLEDToggle) - blink an LED using a timer.
* [C01S03ButtonPWM](./Examples/SwiftIOCircuitPlaygrounds/C01S03ButtonPWM) - use two buttons to increase or decrease LED brightness.
* [C01S03Buzzer](./Examples/SwiftIOCircuitPlaygrounds/C01S03Buzzer) - play a scale using a buzzer.
* [C01S03PWMLed](./Examples/SwiftIOCircuitPlaygrounds/C01S03PWMLed) - create a breathing LED.
* [C01S04Potentiometer](./Examples/SwiftIOCircuitPlaygrounds/C01S04Potentiometer) - read analog values changed by a potentiometer.
* [C01S04PotentiometerBuzzer](./Examples/SwiftIOCircuitPlaygrounds/C01S04PotentiometerBuzzer) - change the sound pitch from a buzzer by rotating a potentiometer.
* [C01S04PotentiometerLED](./Examples/SwiftIOCircuitPlaygrounds/C01S04PotentiometerLED) - change the LED brightness by rotating a potentiometer.
* [C01S05Humiture](./Examples/SwiftIOCircuitPlaygrounds/C01S05Humiture) - read temperature and relative humidity.
* [C01S07Accelerometer](./Examples/SwiftIOCircuitPlaygrounds/C01S07Accelerometer) - read accelerations in x, y, z-axis.
* [C01S07AccelerometerDice](./Examples/SwiftIOCircuitPlaygrounds/C01S07AccelerometerDice) - generate a random number (1-6) after shaking the board.
* [C01S08LCD](./Examples/SwiftIOCircuitPlaygrounds/C01S08LCD) - display graphics on a screen.
* [C01S09MusicPlayer](./Examples/SwiftIOCircuitPlaygrounds/C01S09MusicPlayer) - play the music according to the score.
* [C01S09Speaker](./Examples/SwiftIOCircuitPlaygrounds/C01S09Speaker) - play the sound generated from a triangle wave and square wave.

More to come 👀. 