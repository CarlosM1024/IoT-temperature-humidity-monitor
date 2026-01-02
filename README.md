# 🌡️ IoT Temperature & Humidity Monitoring System

A complete IoT solution for real-time environmental monitoring using DHT11 sensor, ESP32, Firebase, and Flutter mobile application.

![IoT Architecture](documentation/schematics/architecture.png)
![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Platform](https://img.shields.io/badge/platform-ESP32%20%7C%20Flutter-orange)
![Last Commit](https://img.shields.io/github/last-commit/CarlosM1024/IoT-temperature-humidity-monitor)

## 🎯 Features

### 🔌 Hardware Features
- **Real-time Monitoring**: Continuous temperature and humidity readings
- **WiFi Connectivity**: ESP32 connects to local network
- **Low Power**: Optimized for energy efficiency
- **Accurate Sensing**: DHT11 sensor with ±1°C accuracy

### 📱 Mobile App Features
- **Real-time Dashboard**: Live temperature/humidity display
- **Historical Charts**: 24-hour data visualization
- **Notifications**: Alert system for thresholds
- **Dark/Light Theme**: User-friendly interface
- **Multi-language Support**: English and Spanish

### ☁️ Cloud Features
- **Firebase Integration**: Real-time database sync
- **Data Logging**: Historical data storage
- **Remote Access**: Monitor from anywhere
- **Scalable Architecture**: Supports multiple sensors

## 🏗️ System Architecture
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ DHT11 │────▶│ ESP32 │────▶│ Firebase │────▶│ Flutter │
│ Sensor │ │ (WiFi) │ │ Realtime │ │ Mobile │
│ │ │ │ │ Database │ │ App │
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
│ │ │ │
Physical Microcontroller Cloud Storage User Interface
Environment


## 📁 Project Structure
IoT-temperature-humidity-monitor/
├── 📂 firmware/ # ESP32 C++ code (PlatformIO/Arduino)
├── 📂 mobile-app/ # Flutter application
├── 📂 documentation/ # Schematics, guides, diagrams
├── 📂 hardware/ # Circuit designs, BOM
├── 📂 scripts/ # Utility scripts
├── LICENSE # MIT License
├── .gitignore # Git ignore rules
└── README.md # This file


## 🚀 Quick Start

### Prerequisites
- **Hardware**: ESP32 Dev Board, DHT11 Sensor, Jumper Wires
- **Software**: PlatformIO/VSCode, Flutter SDK, Firebase Account
- **Accounts**: Firebase Project, WiFi Network

### Installation (5-minute setup)

```bash
# 1. Clone the repository
git clone https://github.com/CarlosM1024/IoT-temperature-humidity-monitor.git
cd IoT-temperature-humidity-monitor

# 2. Set up firmware
cd firmware
cp src/config.example.h src/config.h
# Edit config.h with your WiFi and Firebase credentials
pio run --target upload

# 3. Set up mobile app
cd ../mobile-app
flutter pub get
# Configure Firebase (see mobile-app/README.md)
flutter run`
```

## 🔧 Hardware Setup
Components Required
Component	Quantity	Purpose
ESP32 Dev Board	1	Microcontroller
DHT11 Sensor	1	Temperature/Humidity
Breadboard	1	Prototyping
Jumper Wires	3	Connections
Micro USB Cable	1	Power/Programming

### Wiring Diagram
text
DHT11 → ESP32
─────────────
VCC   → 3.3V
DATA  → GPIO 4
GND   → GND


## 📱 Mobile Application
App Preview
Dashboard	Historical Data	Settings
<img src="documentation/screenshots/dashboard.png" width="200">	<img src="documentation/screenshots/history.png" width="200">	<img src="documentation/screenshots/settings.png" width="200">
Features
✅ Real-time temperature/humidity display

✅ 24-hour historical charts

✅ Customizable thresholds

✅ Push notifications

✅ Multiple sensor support

✅ Export data to CSV

### 🔌 Firmware Details
Key Features
WiFi Manager with fallback

Deep Sleep mode for battery operation

OTA (Over-the-Air) updates

Sensor calibration

Error handling and recovery

Configuration
Create firmware/src/config.h:

cpp
#define WIFI_SSID "Your_WiFi_SSID"
#define WIFI_PASSWORD "Your_WiFi_Password"
#define FIREBASE_HOST "your-project.firebaseio.com"
#define FIREBASE_AUTH "Your_Firebase_Secret"
#define SENSOR_PIN 4
#define UPDATE_INTERVAL 30000  // 30 seconds

### ☁️ Firebase Configuration
Create Firebase Project at console.firebase.google.com

Enable Realtime Database

Add Web App to get configuration

Update Rules:

json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}

### 📊 Data Flow
Sensor Reading: DHT11 reads temperature/humidity every 30s

Data Processing: ESP32 processes and validates data

Cloud Sync: Data sent to Firebase Realtime Database

Mobile Display: Flutter app fetches and displays data

User Interaction: Alerts and historical view

### 🧪 Testing
Hardware Testing
bash
# Monitor serial output
pio device monitor --baud 115200

# Expected output:
# [INFO] Connecting to WiFi...
# [INFO] Connected! IP: 192.168.1.100
# [INFO] Temperature: 24.5°C | Humidity: 55%
# [INFO] Data sent to Firebase
App Testing
bash
cd mobile-app
flutter test
flutter drive --target=test_driver/app.dart

### 🚀 Deployment
Production Considerations
Security: Use Firebase Authentication

Power: Implement deep sleep for battery operation

Monitoring: Add health checks and alerts

Backup: Regular database backups

OTA Updates
bash
# Build and upload OTA
pio run --target upload --upload-port your_esp_ip


## 🤝 Contributing

If you'd like to contribute to this project, feel free to submit a pull request. Please make sure your code follows the existing style and includes appropriate comments.

1.  Fork the repository.
2.  Create a new branch for your feature or bug fix.
3.  Commit your changes.
4.  Push to the branch.
5.  Submit a pull request.



## 🐛 Troubleshooting
Problem	Solution
ESP32 won't connect to WiFi	Check credentials and signal strength
Sensor readings are inaccurate	Calibrate sensor or check wiring
App can't connect to Firebase	Verify Firebase configuration
Data not updating in real-time	Check Firebase rules and network


## 🙏 Acknowledgments
PlatformIO for excellent IoT development tools

Flutter for beautiful cross-platform apps

Firebase for real-time database

Adafruit for DHT11 library


## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
