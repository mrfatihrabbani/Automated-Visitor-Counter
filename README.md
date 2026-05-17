# Automated Visitor Counter

## Overview

The Automated Visitor Counter is our embedded systems project developed using the ATmega328P microcontroller. The purpose of this project is to monitor the number of visitors entering and exiting a monitored area in real time using infrared (IR) sensors and external interrupts.

The system automatically updates the occupancy count, displays the information on an LCD screen, stores data using EEPROM memory, retrieves timestamps from an RTC module through I2C communication, and activates an alarm system whenever the maximum occupancy limit is reached.

---

# Features

- Real-time visitor counting
- Entry and exit detection using IR sensors
- External interrupt handling (INT0 and INT1)
- LCD occupancy display
- Occupancy limit monitoring
- Red and green LED indicators
- Buzzer alarm activation
- EEPROM data storage
- RTC timestamp retrieval
- USART serial communication
- Proteus simulation support

---

# Hardware Components

- Arduino Uno / ATmega328P
- IR Sensors
- LCD 16x2 I2C Display
- DS3231 RTC Module
- EEPROM (Internal ATmega328P EEPROM)
- Buzzer
- Green LED
- Red LED
- Breadboard
- Jumper Wires

---

# Software Tools

- AVR Assembly Language
- Arduino IDE
- Proteus
- GitHub
- Google Docs
- Discord

---

# System Architecture

```text
IR Sensors
     ↓
External Interrupts (INT0 / INT1)
     ↓
ENTRY_FLAG / EXIT_FLAG
     ↓
Occupancy Counter Logic
     ↓
+-------------------------------+
| LCD Display                   |
| EEPROM Logging                |
| RTC Timestamp Retrieval       |
| USART Serial Communication    |
| Alarm System                  |
+-------------------------------+
```

---

# Modules

## 1. visitor_counter.S

Main integration file responsible for initializing and coordinating all modules of the system.

### Responsibilities

- Initialize peripherals
- Configure interrupts
- Start communication modules
- Coordinate all system functionalities

### Developed By

Everyone

---

## 2. core_interrupt.S

Handles external interrupt configuration and visitor event detection.

### Features

- Configure INT0 and INT1
- FALLING EDGE interrupt detection
- ENTRY_FLAG handling
- EXIT_FLAG handling
- Lightweight ISR implementation

### Developed By

Derryl

---

## 3. display_timer.S

Handles Timer0 overflow interrupts, LCD updates, and alarm indicators.

### Features

- Timer0 configuration
- LCD display refresh
- Green and red LED indicators
- Buzzer activation
- Occupancy limit monitoring

### Developed By

Ibrahima

---

## 4. data_communications.S

Handles occupancy processing, EEPROM logging, RTC communication, and USART transmission.

### Features

- Occupancy arithmetic operations
- EEPROM read/write
- I2C communication with DS3231
- RTC timestamp retrieval
- USART serial communication
- UART event logging

### Developed By

Fatih

---

# Interrupt Configuration

| Interrupt | Function     |
| --------- | ------------ |
| INT0      | Entry sensor |
| INT1      | Exit sensor  |

Both interrupts are configured on FALLING EDGE detection.

---

# Occupancy Logic

```text
ENTRY_FLAG → Occupancy + 1
EXIT_FLAG  → Occupancy - 1
```

Maximum occupancy limit:

```text
LIMIT = 5
```

If occupancy ≥ 5:

- Red LED ON
- Buzzer ON
- Alarm Active

Otherwise:

- Green LED ON
- Normal operation

---

# Timer Configuration

| Parameter     | Value       |
| ------------- | ----------- |
| Timer         | Timer0      |
| Mode          | Normal Mode |
| Prescaler     | 64          |
| Overflow Time | ~1.024 ms   |

---

# USART Configuration

| Parameter     | Value                    |
| ------------- | ------------------------ |
| Communication | UART                     |
| Baud Rate     | 9600 bps                 |
| Display       | Proteus Virtual Terminal |

Example output:

```text
[14:32:11] ENTRY - Occupancy: 5
[14:35:02] EXIT  - Occupancy: 4
```

---

# I2C Communication

The ATmega328P communicates with the DS3231 RTC module using the I2C protocol.

## Lines Used

- SDA
- SCL

## Retrieved Data

- Hours
- Minutes
- Seconds

---

# EEPROM Storage

The EEPROM module is used to:

- Store occupancy values
- Preserve visitor logs
- Restore data after reset or power interruption

---

# Testing

The system was tested using:

- Proteus simulation
- Hardware implementation
- LCD verification
- Interrupt testing
- USART monitoring
- EEPROM restoration
- RTC timestamp verification

---

# Results

The system successfully:

- Detected visitor entry and exit events
- Updated occupancy count in real time
- Activated alarm conditions correctly
- Displayed occupancy information on LCD
- Stored data into EEPROM
- Retrieved RTC timestamps
- Sent USART logs to the virtual terminal

---

# Challenges Encountered

- IR sensor instability in Proteus
- Interrupt synchronization
- EEPROM debugging
- LCD refresh timing
- Preventing repeated sensor triggering

---

# Future Improvements

Possible future improvements include:

- Wireless monitoring
- WiFi integration
- Mobile application support
- Cloud data storage
- OLED display integration
- Multi-room occupancy management

---

# Conclusion

Our Automated Visitor Counter project successfully demonstrated the integration of multiple embedded systems concepts including interrupts, timers, EEPROM memory, USART communication, I2C communication, RTC timestamping, LCD control, and alarm management using the ATmega328P microcontroller.

The final system operated reliably in both simulation and hardware testing environments while providing real-time occupancy monitoring and alert handling.

---

# Team Members

| Member   | Responsibility                  |
| -------- | ------------------------------- |
| Derryl   | Interrupt and Sensor Management |
| Ibrahima | Display and Alarm System        |
| Fatih    | Data Communication and Storage  |

---

# License

This project was developed for academic purposes as part of our Embedded Systems course project.
