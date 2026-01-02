#include <IOXhop_FirebaseESP32.h>
#include <WiFi.h>

#include <DHT.h>
#define DHTPIN 4
#define DHTTYPE DHT11
DHT dht (DHTPIN, DHTTYPE);

#define WIFI_SSID "INFINITUM73C2_2.4"
#define WIFI_PASSWORD "z4wVUBhwyR"
#define FIREBASE_AUTH "https://espn-72bf1-default-rtdb.firebaseio.com/"
#define FIREBASE_HOST "oNQ5vb5kmBqCR5nfAXN75UiBX2cYOvAByfbDym6C"


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
