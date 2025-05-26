# 🐧 Penguin Weight Monitoring System — Smart Conservation with IoT, ML & RFID 🌍📡

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![ESP32](https://img.shields.io/badge/ESP32-IoT-blue)](https://www.espressif.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-NoSQL-green)](https://www.mongodb.com/)
[![AWS EC2](https://img.shields.io/badge/AWS-EC2-orange)](https://aws.amazon.com/ec2/)
[![Twilio](https://img.shields.io/badge/Twilio-SMS-red)](https://www.twilio.com/)

A full-stack conservation-grade monitoring system combining **IoT hardware**, **machine learning**, and a **web-based dashboard** to track and alert on African penguin weight anomalies. Designed to enable global, real-time insight into penguin health for researchers and conservationists.

---

## 🚀 Features

- 🏷️ **RFID Identification** – Recognize and log tagged penguins automatically using MFRC522.
- ⚖️ **Accurate Weight Monitoring** – Dual load cell system + Kalman & dual moving average filtering for stable measurement.
- 📸 **Visual Logging** – ESP32-CAM captures photos of each penguin on entry.
- 🧠 **Anomaly Detection** – Isolation Forest ML model detects abnormal weights and triggers SMS alerts via Twilio.
- ☁️ **Real-Time Cloud Sync** – Sensor data and images pushed to a Flask backend hosted on AWS EC2.
- 🗺️ **Location-Aware UI** – Interactive map with 5 monitored colonies and trends per site.
- 📊 **Live Dashboard** – Real-time streaming of activity, CSV export, dark/light mode, and RFID-based filtering.
- 💬 **SMS Alerts** – Researchers are notified instantly about anomalies for quick intervention.

---

## 🔧 Hardware Setup

### Components

| Component       | Purpose                               |
|-----------------|----------------------------------------|
| ESP32           | Main microcontroller                   |
| HX711 + Load Cell | Penguin weight measurement           |
| MFRC522         | RFID identification of tagged penguins |
| ESP32-CAM       | Captures penguin image on entry        |
| DS3231 RTC      | Timestamping events                    |
| 12V Power Supply| Powers the system                      |

-----------------------------------------------------------

---

## 🧠 ML Pipeline

- **Preprocessing:** Dual Moving Average + Kalman Filter for smoothing.
- **Model:** Isolation Forest trained on normal weight distributions.
- **Trigger:** Sends SMS via Twilio on outlier detection.

-----------------------------------------------------------------------

## 🖥️ Dashboard Highlights

- Real-time weight chart with penguin ID
- Most recent image (auto-refreshed every 10 seconds)
- Interactive colony map with population trend graphs
- CSV export of measurements
- RFID-based data filtering
- Dark/light mode toggle

----------------------------------------------------------------------

## 🌍 Future Plans

- Add solar-powered edge nodes for remote areas
- Expand to cover more colonies globally
- Train models on seasonal/behavioral patterns
- Collaborate with conservation groups for large-scale deployments

---

## 📄 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

