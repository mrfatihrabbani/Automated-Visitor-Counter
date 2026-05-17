# Automated Visitor Counter

## Introduction to the Problem and the Solution

Monitoring the number of visitors manually in classrooms, laboratories, offices, or public areas can become inefficient and unreliable, especially when the number of people increases. Overcrowding may create safety problems, poor organization, and difficulty respecting occupancy limits.

To solve this problem, we developed an Automated Visitor Counter using the ATmega328P microcontroller. The system automatically detects visitor entry and exit events using infrared sensors connected to external interrupts. The occupancy count is updated in real time, displayed on an LCD screen, and compared with a predefined maximum capacity limit. When the occupancy limit is reached, the system activates an alarm using LEDs and a buzzer.

In addition, the project integrates EEPROM memory for data preservation, USART communication for serial monitoring, and an RTC module through I2C communication to generate accurate timestamps for visitor event logging.

---

# Hardware Design and Implementation Details

## Hardware Components

The system was implemented using the following hardware components:

- Arduino Uno / ATmega328P
- IR Sensors
- LCD 16x2 I2C Display
- DS3231 RTC Module
- Buzzer
- Green LED
- Red LED
- Breadboard
- Jumper Wires

## Hardware Connections

### IR Sensors

- Entry sensor → INT0 (Pin 2)
- Exit sensor → INT1 (Pin 3)

### LCD Display

The LCD 16x2 display communicates using the I2C protocol through:

- SDA line
- SCL line

### Alarm Indicators

- Green LED → Normal operating condition
- Red LED → Occupancy limit reached
- Buzzer → Alarm condition

### RTC Module

The DS3231 RTC module is connected using I2C communication to provide real-time timestamps.

## Hardware Operation

When a visitor crosses the entry sensor, the INT0 external interrupt is triggered and the occupancy count increases. When the exit sensor is triggered through INT1, the occupancy count decreases.

The LCD continuously displays the current occupancy value and occupancy limit status. If the number of visitors reaches the predefined limit of 5 visitors, the red LED and buzzer are activated automatically.

---

# Software Implementation Details

The software was implemented entirely in AVR Assembly Language using multiple modules.

## visitor_counter.S

Main integration module responsible for initializing and coordinating all system functionalities.

### Responsibilities

- Initialize peripherals
- Configure interrupts
- Start communication modules
- Coordinate all modules

---

## core_interrupt.S

Responsible for external interrupt handling and visitor event detection.

### Features

- Configure INT0 and INT1
- FALLING EDGE interrupt detection
- ENTRY_FLAG and EXIT_FLAG handling
- Lightweight ISR implementation

---

## display_timer.S

Responsible for Timer0 overflow interrupts, LCD updates, and alarm indicators.

### Features

- Timer0 configuration
- LCD display refresh
- Green and red LED indicators
- Buzzer control
- Occupancy limit monitoring

### Timer Configuration

| Parameter         | Value       |
| ----------------- | ----------- |
| Timer             | Timer0      |
| Mode              | Normal Mode |
| Prescaler         | 64          |
| Overflow Interval | ~1.024 ms   |

---

## data_communications.S

Responsible for occupancy processing, EEPROM logging, RTC communication, and USART transmission.

### Features

- Occupancy arithmetic operations
- EEPROM read/write
- I2C communication with DS3231
- RTC timestamp retrieval
- USART serial communication
- UART event logging

---

# Test Results and Performance Evaluation

The system was tested using both Proteus simulation and hardware implementation.

## Interrupt Testing

The IR sensors successfully triggered the INT0 and INT1 external interrupts whenever entry or exit events occurred. The system reacted immediately without requiring continuous polling.

## Occupancy Counter Testing

The occupancy count increased correctly during entry events and decreased correctly during exit events. Additional testing confirmed that the occupancy value never became negative.

## Alarm Testing

When the occupancy reached the maximum limit of 5 visitors:

- The red LED activated
- The buzzer activated
- The green LED turned off
- The LCD displayed the warning message

When the occupancy returned below the limit:

- The alarm was disabled
- The green LED returned to normal operation

## USART Testing

The USART module successfully transmitted visitor logs to the Proteus Virtual Terminal at 9600 baud.

Example output:

```text
[14:32:11] ENTRY - Occupancy: 5
[14:35:02] EXIT  - Occupancy: 4
```

## EEPROM Testing

The EEPROM module successfully stored occupancy values and restored them after restarting the system.

## RTC Testing

The DS3231 RTC module successfully provided real-time timestamps through I2C communication.

---

# Conclusion and Future Work

In conclusion, our Automated Visitor Counter project successfully integrated multiple embedded system concepts including external interrupts, timer interrupts, EEPROM memory, USART communication, I2C communication, RTC timestamping, LCD display control, and alarm handling using the ATmega328P microcontroller.

The final system operated reliably during both simulation and hardware testing while providing real-time occupancy monitoring and alert management.

## Future Work

Possible future improvements include:

- Wireless monitoring system
- WiFi or Bluetooth integration
- Mobile application support
- Cloud database integration
- OLED display support
- Multi-room occupancy management
- Web dashboard monitoring
