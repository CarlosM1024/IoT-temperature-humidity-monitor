#ifndef _IOXhop_FirebaseStream_H_INCLUDED
#define _IOXhop_FirebaseStream_H_INCLUDED

#include <Arduino.h>
#include <ArduinoJson.h>

#define STREAM_JSON_BUFFER_SIZE 1024
#define STREAM_JSON_DATA_BUFFER_SIZE 1024

class FirebaseStream {
  public:
    FirebaseStream(String event, String data) {
      _event = event;
      DynamicJsonDocument jsonBuffer(STREAM_JSON_BUFFER_SIZE);  // Usar DynamicJsonDocument
      auto error = deserializeJson(jsonBuffer, data);  // Deserializa el JSON
      if (!error) {
        if (jsonBuffer.containsKey("path") && jsonBuffer.containsKey("data")) {
          _path = jsonBuffer["path"].as<String>();
          _data = jsonBuffer["data"].as<String>();
        }
      } else {
        // Manejo de error si el JSON no se deserializa correctamente
        _dataError = true;
      }
    }
    
    String getEvent() {
      return _event;
    }
    
    String getPath() {
      return _path;
    }
    
    int getDataInt() {
      return _data.toInt();
    }
    
    float getDataFloat() {
      return _data.toFloat();
    }
    
    String getDataString() {
      return _data;
    }
    
    bool getDataBool() {
      return _data == "true";  // Verifica si el dato es "true" (cadena)
    }
    
    void getData(int &value) {
      value = getDataInt();
    }
    
    void getData(float &value) {
      value = getDataFloat();
    }
    
    void getData(String &value) {
      value = getDataString();
    }
    
    void getData(bool &value) {
      value = getDataBool();
    }
    
    JsonVariant getData() {
      DynamicJsonDocument jsonBuffer(STREAM_JSON_DATA_BUFFER_SIZE);
      auto error = deserializeJson(jsonBuffer, _data);
      if (!error) {
        return jsonBuffer.as<JsonVariant>();
      } else {
        // En lugar de nullptr, devolver un JsonVariant vacío
        return JsonVariant();
      }
    }
    
  private:
    String _event, _path, _data = "";
    bool _dataError = false, _begin = false;
};

#endif
