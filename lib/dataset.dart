import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
class Weather {

  final int max;
  final int min;
  final int current;
  final String name;
  final String day;
  final int wind;
  final int humidity;
  final int chanceRain;
  final String image;
  final String time;
  final String location;

  Weather(
   {required this.max,
     required this.min,
     required this.name,
     required this.day,
     required this.wind,
     required this.humidity,
     required this.chanceRain,
     required this.image,
     required this.current,
     required this.time,
     required this.location});
}

String appId = "8509d17604f50464ce0e744844cd6dd0";
Future<List> fetchData(String lat,String lon,String city) async{
  var url = "https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&units=metric&appid=$appId";
  var response = await http.get(Uri.parse(url));
  DateTime date = DateTime.now();
  if(response.statusCode==200){
    var res = json.decode(response.body);
    //current Temp
    var current = res["current"];
    Weather currentTemp = Weather(
        current: current["temp"]?.round()??0,
        name: current["weather"][0]["main"].toString(),
        day: DateFormat("EEEE dd MMMM").format(date),
        wind: current["wind_speed"]?.round()??0,
        humidity: current["humidity"]?.round()??0,
        chanceRain: current["uvi"]?.round()??0,
        location: city,
        image: findIcon(current["weather"][0]["main"].toString(), true), min: 0, max: 0, time: ''
    );


    //today weather
    List<Weather> todayWeather = [];
    int hour = int.parse(DateFormat("hh").format(date));
    for(var i=0;i<4;i++){
      var temp = res["hourly"];
      var hourly = Weather(
          current: temp[i]["temp"]?.round()??0,
          image: findIcon(temp[i]["weather"][0]["main"].toString(),false),
          time: Duration(hours: hour+i+1).toString().split(":")[0]+":00", location: '', humidity: 0, name: '', chanceRain: 0, min: 0, max: 0, wind: 0, day: ''
      );
      todayWeather.add(hourly);
    }

    //Tomorrow Weather
    var daily = res["daily"][0];
    Weather tomorrowTemp = Weather(
        max: daily["temp"]["max"]?.round()??0,
        min:daily["temp"]["min"]?.round()??0,
        image: findIcon(daily["weather"][0]["main"].toString(), true),
        name:daily["weather"][0]["main"].toString(),
        wind: daily["wind_speed"]?.round()??0,
        humidity: daily["rain"]?.round()??0,
        chanceRain: daily["uvi"]?.round()??0, current: 0, location: '', time: '', day: ''
    );

    //Seven Day Weather
    List<Weather> sevenDay = [];
    for(var i=1;i<8;i++){
      String day = DateFormat("EEEE").format(DateTime(date.year,date.month,date.day+i+1)).substring(0,3);
      var temp = res["daily"][i];
      var hourly = Weather(
          max:temp["temp"]["max"]?.round()??0,
          min:temp["temp"]["min"]?.round()??0,
          image:findIcon(temp["weather"][0]["main"].toString(), false),
          name:temp["weather"][0]["main"].toString(),
          day: day, time: '', chanceRain: 0, wind: 0, current: 0, humidity: 0, location: ''
      );
      sevenDay.add(hourly);
    }
    return [currentTemp,todayWeather,tomorrowTemp,sevenDay];
  }
  return [null,null,null,null];
}

//findIcon
String findIcon(String name,bool type){
  if(type){
    switch(name){
      case "Clouds":
        return "cloud/35.png";
        break;
      case "Rain":
        return "rain/36.png";
        break;
      case "Drizzle":
        return "rain/36.png";
        break;
      case "Thunderstorm":
        return "lighting/34.png";
        break;
      case "Snow":
        return "snow/36.png";
        break;
      default:
        return "sun/27.png";
    }
  }else{
    switch(name){
      case "Clouds":
        return "cloud/35.png";
        break;
      case "Rain":
        return "cloud/7.png";
        break;
      case "Drizzle":
        return "assets/rainy_2d.png";
        break;
      case "Thunderstorm":
        return "cloud/12.png";
        break;
      case "Snow":
        return "cloud/23.png";
        break;
      default:
        return "sun/27.png";
    }
  }
}
class CityModel{
  final String name;
  final String lat;
  final String lon;
  CityModel({required this.name,required this.lat,required this.lon});
}

var cityJSON;

Future<CityModel?> fetchCity(String cityName) async{
  if(cityJSON==null){
    String link = "https://raw.githubusercontent.com/dr5hn/countries-states-cities-database/master/cities.json";
    var response = await http.get(Uri.parse(link));
    if(response.statusCode==200){
      cityJSON = json.decode(response.body);
    }
  }
  for(var i=0;i<cityJSON.length;i++){
    if(cityJSON[i]["name"].toString().toLowerCase() == cityName.toLowerCase()){
      return CityModel(
          name:cityJSON[i]["name"].toString(),
          lat: cityJSON[i]["latitude"].toString(),
          lon: cityJSON[i]["longitude"].toString()
      );
    }
  }
  return null;
}

