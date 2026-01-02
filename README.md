# 🌡️ IoT Temperature & Humidity Monitoring System

A complete IoT solution for real-time environmental monitoring using a DHT11 sensor, ESP32, Firebase, and a Flutter mobile application.

![License](https://img.shields.io/badge/license-MIT-blue)
![Platform](https://img.shields.io/badge/platform-ESP32%20%7C%20Flutter-orange)
![Last Commit](https://img.shields.io/github/last-commit/CarlosM1024/IoT-temperature-humidity-monitor)

## 🏗️ System Architecture

The data flows from the physical environment to your pocket through the following pipeline:

1.  **Firmware (ESP32):** Reads data from the DHT11 sensor and pushes it to Firebase via Wi-Fi.
2.  **Cloud (Firebase):** Acts as the real-time bridge and historical storage.
3.  **Mobile App (Flutter):** Listens to Firebase changes and visualizes data for the user.

## 🎯 Features

### 🔌 Hardware Features
* **Real-time Monitoring**: Continuous temperature and humidity readings.
* **WiFi Connectivity**: Native ESP32 connection to local networks.
* **Accurate Sensing**: Reliable DHT11 integration with the Adafruit library.

### 📱 Mobile App Features
* **Real-time Dashboard**: Live updates without refreshing (Firebase Streams).
* **Historical Charts**: Visualization of data trends.
* **Cross-Platform**: Built with Flutter for Android and iOS.

## 📁 Project Structure

```text
IoT-temperature-humidity-monitor/
├── 📂 firmware/      # ESP32 C++ code (PlatformIO/Arduino)
├── 📂 mobile-app/    # Flutter application source code
├── LICENSE           # MIT License
└── README.md         # General documentation
```


## 🚀 Quick Start

```bash
### 1. Clone the repository
git clone https://github.com/CarlosM1024/IoT-temperature-humidity-monitor.git
cd IoT-temperature-humidity-monitor
```

### 2. Hardware Setup
Prepare the following components to build the device:

| Component | Quantity | Purpose |
| :--- | :---: | :--- |
| **ESP32 Dev Board** | 1 | Main Microcontroller & WiFi gateway |
| **DHT11 Sensor** | 1 | Temperature and Humidity sensing |
| **Jumper Wires** | 3 | Circuit connections (VCC, GND, Data) |
| **Micro USB Cable** | 1 | Power supply and programming |

### 3. Deployment Steps
The project must be configured in two stages. Please follow the specific guides in each folder:

* **Firmware:** Go to [`/firmware/README.md`](./firmware/README.md) to configure your WiFi credentials, Firebase API keys, and flash the ESP32.
* **Mobile App:** Go to [`/mobile-app/README.md`](./mobile-app/README.md) to set up the Flutter environment and link the app to your Firebase project.


## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.


## 🤝 Contributing

If you'd like to contribute to this project, feel free to submit a pull request. Please make sure your code follows the existing style and includes appropriate comments.

1.  Fork the repository.
2.  Create a new branch for your feature or bug fix.
3.  Commit your changes.
4.  Push to the branch.
5.  Submit a pull request.
