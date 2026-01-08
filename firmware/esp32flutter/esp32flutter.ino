/*
 * ESP32 + DHT11 + Firebase Realtime Database
 * Librería moderna: Firebase ESP Client (Mobizt)
 */

#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <DHT.h>

// ==================== CREDENCIALES ====================
#define WIFI_SSID "Totalplay74A1_2.4Gnormal"
#define WIFI_PASSWORD "Monserrat100"

#define API_KEY "AIzaSyDrZqjhzr2xNUfF26Ohefi3-u8rZMUw1lQ"
#define DATABASE_URL "push-d7f74-default-rtdb.firebaseio.com"

// ==================== DHT CONFIG ====================
#define DHTPIN 23
#define DHTTYPE DHT11

#define LED_BUILTIN 2
#define SEND_INTERVAL 5000

// ==================== OBJETOS ====================
DHT dht(DHTPIN, DHTTYPE);

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// ==================== VARIABLES ====================
unsigned long lastSend = 0;
int readingCount = 0;

// ==================== SETUP ====================
// ... (Tus includes y credenciales se mantienen igual) ...

void setup() {
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
  Serial.println("\nWiFi OK");

  // Sincronización básica
  configTime(0, 0, "pool.ntp.org");

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  
  // CONFIGURACIÓN PARA BAJA MEMORIA
  config.signer.test_mode = true;
  fbdo.setBSSLBufferSize(1024, 1024);
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  // Verificamos conexión y tiempo
  if (Firebase.ready() && (millis() - lastSend >= SEND_INTERVAL)) {
    lastSend = millis();

    float t = dht.readTemperature();
    float h = dht.readHumidity();

    if (isnan(t) || isnan(h)) {
      Serial.println("⚠️ Error al leer el sensor DHT");
      return; 
    }

    FirebaseJson json;
    json.set("temperatura", t);
    json.set("humedad", h);
    json.set("ultimo_cambio", "Sincronizado");

    // Enviamos a un nodo con timestamp para tener historial si lo deseas
    if (Firebase.RTDB.setJSON(&fbdo, "/lecturas", &json)) {
      Serial.printf("✅ Enviado: T=%.1f H=%.1f\n", t, h);
    } else {
      Serial.println("❌ Error: " + fbdo.errorReason());
    }
  }
}
