#include <IOXhop_FirebaseESP32.h>
#include <WiFi.h>

#include <DHT.h>
#define DHTPIN 4
#define DHTTYPE DHT11
DHT dht (DHTPIN, DHTTYPE);

#define WIFI_SSID "YOUR_SSID"
#define WIFI_PASSWORD "YOUR_PASSWORD"
#define FIREBASE_HOST "your-project.firebaseio.com"
#define FIREBASE_AUTH "your_database_secret"


void setup() {
  Serial.begin(115200);
  Serial.print("DHT TEST");
  dht.begin();

  //Connect to Wifi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);  
  Serial.println("Connecting");
  while(WiFi.status() != WL_CONNECTED){
    Serial.println(".");
    delay(500);
    }
   Serial.println();
   Serial.println("Connected:");
   Serial.println(WiFi.localIP());
   Firebase.begin(FIREBASE_AUTH, FIREBASE_HOST);

}

int n= 0;


void loop() {
 //DHT = Humidity n Temperature
 float h = dht.readHumidity();
 float t = dht.readTemperature();
  if(isnan(h) || isnan(t)){
    Serial.println("Failed to read from DHT sensor");
    return;
  }
Serial.println("Humidity: ");
Serial.print(h);
Serial.println(" %\t");

Serial.println("Temperature: ");
Serial.print(t);
Serial.println(" *C");

//set value
Firebase.setFloat("Humidity:", h);
  //Handle error
if(Firebase.failed()){
  Serial.println("Setting/number failed:");
  Serial.print(Firebase.error());
  return;
  }
(Firebase.setFloat("Temperature:", t));
//Handle Error
if(Firebase.failed()){
  Serial.print("Setting/number failed:");
  Serial.println(Firebase.error());
  return;
}
Serial.println("Temperature and Humidity Data Sent Succesfully");
delay(1000);  

}
