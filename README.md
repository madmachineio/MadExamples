# MadExamples


![build](https://github.com/madmachineio/MadExamples/actions/workflows/build.yml/badge.svg)
[![Discord](https://img.shields.io/discord/592743353049808899?&logo=Discord&colorB=7289da)](https://madmachine.io/discord)
[![twitter](https://img.shields.io/twitter/follow/madmachineio?label=%40madmachineio&style=social)](https://twitter.com/madmachineio)


The MadExamples repository contains a set of examples for you to dive into physical programming and learn how to program the boards using Swift.

## Tutorials

These examples come with [detailed tutorials](https://docs.madmachine.io/projects/overview) about background knowledge, circuit connection and code explanation. It's a good idea to follow these guides and then try the examples.

As for how to run these examples on your board, check [this step-by-step guide](https://docs.madmachine.io/overview/advanced/run-example).

## Examples

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


### SwiftIOPlayground

[These examples](./Examples/SwiftIOPlayground) allow you to get fully acquainted with hardware programming in Swift using the SwiftIO Playground kit. 

A series of demo projects walk you through the most basic knowledge and gradually increase in complexity to show more advanced use cases, like sound and graphic display. It comes with a series of detailed [tutorials](https://docs.madmachine.io/learn/introduction).

More to come 👀. 