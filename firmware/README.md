# 🔌 ESP32 Firmware

This folder contains the C++ code for the ESP32 microcontroller. It handles sensor reading and data transmission to Firebase.

## 🛠️ Hardware Setup

### Wiring Diagram
| DHT11 Pin | ESP32 Pin |
| :--- | :--- |
| **VCC** | 3.3V |
| **GND** | GND |
| **DATA** | GPIO 4 (D4) |



## ⚙️ Configuration

1.  **LIBRARIES**: Ensure you have these installed in your IDE:
    * `Firebase ESP32 Client` (by Mobizt)
    * `DHT sensor library` (by Adafruit)
2.  **CREDENTIALS**: Open the source file and update:
    ```cpp
    #define WIFI_SSID "YOUR_SSID"
    #define WIFI_PASSWORD "YOUR_PASSWORD"
    #define FIREBASE_HOST "your-project.firebaseio.com"
    #define FIREBASE_AUTH "your_database_secret"
    ```

## 🚀 Flashing
1. Open the project in **PlatformIO** (recommended) or Arduino IDE.
2. Connect your ESP32 via USB.
3. Build and Upload.
4. Check the **Serial Monitor** (115200 baud) to verify the Firebase connection.
