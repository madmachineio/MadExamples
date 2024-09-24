# MadExamples



![build](https://github.com/madmachineio/MadExamples/actions/workflows/build.yml/badge.svg)
[![Discord](https://img.shields.io/discord/592743353049808899?&logo=Discord&colorB=7289da)](https://madmachine.io/discord)
[![twitter](https://img.shields.io/twitter/follow/madmachineio?label=%40madmachineio&style=social)](https://twitter.com/madmachineio)


The MadExamples repository offers a collection of examples designed to help you delve into embedded Swift programming. Explore these resources to master programming microcontrollers using Swift.

## Get started

Refer to [this step-by-step tutorial](https://docs.madmachine.io/overview/getting-started/software-prerequisite) for setting up the required software environment and working on a "Hello, World" project.


## SwiftIOPlayground

Immerse yourself and become thoroughly acquainted with embedded Swift programming by leveraging the [SwiftIO Playground kit](https://madmachine.io/products/swiftio-playground-kit).

![SwiftIO Playground Kit](https://madmachine.io/cdn/shop/files/UseKit_fee8d964-e9cf-4d13-bf2e-daa4bc53c165.jpg?v=1709822154&width=1680)

It contains a series of demo projects to guide you from fundamental concepts, including electronics and Swift programming, and to progressively advanced use cases such as sound generation and graphic display. Additionally, it is complemented by a series of comprehensive [tutorials](https://docs.madmachine.io/learn/introduction) to provide detailed guidance throughout your learning journey.

* [01LED](./Examples/SwiftIOPlayground/01LED) - start by learning how to blink an LED, which will help you become familiar with digital output. 
* [02Button](./Examples/SwiftIOPlayground/02Button) - interact with a button to grasp digital input concepts.
* [03Buzzer](./Examples/SwiftIOPlayground/03Buzzer) - create sound with a buzzer to understand PWM (Pulse Width Modulation).
* [04Potentiometer](./Examples/SwiftIOPlayground/04Potentiometer) - rotate a potentiometer to control an LED or buzzer and explore analog input concepts.
* [05Humiture](./Examples/SwiftIOPlayground/05Humiture) - measure temperature and humidity while learning to utilize I2C communication.
* [06RTC](./Examples/SwiftIOPlayground/06RTC) - retrieve the current time using an RTC via I2C communication.
* [07Accelerometer](./Examples/SwiftIOPlayground/07Accelerometer) - detect movement by reading acceleration data using I2C communication.
* [08LCD](./Examples/SwiftIOPlayground/08LCD) - create graphics on a small screen and explore SPI communication.
* [09Speaker](./Examples/SwiftIOPlayground/09Speaker) - play music through a speaker, grasp essential sound principles, and delve into I2S communication.
* [10UART](./Examples/SwiftIOPlayground/10UART) - learn how to utilize a USB-serial converter to establish communication between your board and other USB devices.
* [11WiFi](./Examples/SwiftIOPlayground/11WiFi) - utilize ESP32 to establish a WiFi connection and transmit/receive data from the internet.
* [12MoreProjects](./Examples/SwiftIOPlayground/12MoreProjects) - engage in more advanced projects by incorporating different modules from the kit. This allows you to apply what you've learned and explore a wider range of possibilities.

## MakerKit

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
