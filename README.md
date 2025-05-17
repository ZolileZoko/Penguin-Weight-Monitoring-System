# Penguin Weight Monitoring System 🐧⚖️

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![ESP32](https://img.shields.io/badge/ESP32-IoT-blue)](https://www.espressif.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-NoSQL-green)](https://www.mongodb.com/)

A full-stack IoT system for tracking penguin weight in conservation environments. Combines **ESP32 hardware sensors**, **cloud data storage**, and **real-time analytics**.

## Features ✨

- 🏷️ **RFID Identification** - MFRC522 reader for penguin tagging
- ⚖️ **Precision Weight Tracking** - HX711 load cells with Kalman filtering
- ⏱️ **Accurate Timestamps** - DS3231 RTC module
- ☁️ **Wireless Data Sync** - MQTT/HTTP to cloud
- 🗃️ **MongoDB Backend** - Optimized time-series storage
- 📊 **Live Dashboard** - Real-time monitoring with TailwindCSS

## Hardware Setup 🔧

### Components
| Component | Purpose |
|-----------|---------|
| ESP32 | Main microcontroller |
| HX711 + Load Cell | Weight measurement |
| MFRC522 | RFID penguin identification |
| DS3231 | Precise timestamps |
| 12V Power Supply| Powering Hardware|

### Wiring Diagram
```plaintext
HX711 <-> ESP32:
DOUT -> GPIO12
PD_SCK -> GPIO13

MFRC522 <-> ESP32:
SDA -> GPIO5
SCK -> GPIO18
MOSI -> GPIO23
MISO -> GPIO19
RST -> GPIO15
