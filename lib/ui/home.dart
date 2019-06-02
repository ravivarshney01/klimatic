import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:klimatic/util.dart' as util;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _cityEntered;

  Future _nextScreen(BuildContext context) async {
    Map result = await Navigator.of(context)
        .push(MaterialPageRoute<Map>(builder: (BuildContext context) {
      return ChangeCity();
    }));
    if (result != null && result.containsKey('enter')) {
      if (result['enter'].text.toString().isNotEmpty) {
        _cityEntered = result['enter'].text.toString();
      }
      // print(result['enter'].text.toString());
    }
  }

  void show() async {
    Map data = await getWeather(util.appId, util.city);
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Klimatic",
          style: TextStyle(color: Colors.redAccent),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            onPressed: () => {_nextScreen(context)},
            icon: Icon(
              Icons.menu,
              color: Colors.redAccent,
            ),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset(
              "images/umbrella.png",
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.fitHeight,
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            child: Text(
              "${_cityEntered == null ? util.city : _cityEntered}",
              style: city(),
            ),
          ),
          Container(
              alignment: Alignment.topLeft,
              child: Center(
                child: updateTemp(
                    "${_cityEntered == null ? util.city : _cityEntered}"),
              ))
        ],
      ),
    );
  }

  Future<Map> getWeather(String appId, String city) async {
    String api =
        "http://api.openweathermap.org/data/2.5/weather?q=$city&APPID=$appId&units=metric";

    http.Response res = await http.get(api);
    return json.decode(res.body);
  }

  Widget updateTemp(String city) {
    return FutureBuilder(
      future: getWeather(util.appId, city == null ? util.city : city),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data["cod"] == 200) {
            Map content = snapshot.data;
            return Column(
              children: <Widget>[
                Text(
                  "${content["main"]["temp"].toString()}" + " °C",
                  style: temp(),
                ),
                Text(
                  "Max-Tem- ${content["main"]["temp_max"].toString()}" + " °C",
                  style: forcast(),
                ),
                Text(
                  "Min-Temp- ${content["main"]["temp_min"].toString()}" + " °C",
                  style: forcast(),
                ),
                Text(
                  "Humidity - ${content["main"]["humidity"].toString()}",
                  style: forcast(),
                ),
              ],
            );
          } else {
            return Text(
              "Invalid city",
              style: temp(),
            );
          }
        }else{
          return Text("");
        }
      },
    );
  }
}

class ChangeCity extends StatefulWidget {
  @override
  _ChangeCityState createState() => _ChangeCityState();
}

class _ChangeCityState extends State<ChangeCity> {
  var _city = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Change city"),
          backgroundColor: Colors.red,
        ),
        body: Stack(
          children: <Widget>[
            Image.asset(
              'images/white_snow.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fitWidth,
            ),
            ListView(
              children: <Widget>[
                ListTile(
                  title: TextField(
                    decoration: InputDecoration(
                      hintText: "Enter City",
                    ),
                    controller: _city,
                  ),
                ),
                ListTile(
                  title: FlatButton(
                    onPressed: () {
                      Navigator.pop(context, {'enter': _city});
                    },
                    color: Colors.redAccent,
                    textColor: Colors.white70,
                    child: Text('Get Weather'),
                  ),
                )
              ],
            )
          ],
        ));
  }
}

TextStyle city() {
  return TextStyle(
    color: Colors.white,
    fontSize: 35,
    fontStyle: FontStyle.italic,
  );
}

TextStyle temp() {
  return TextStyle(color: Colors.white, fontSize: 50);
}

TextStyle forcast() {
  return TextStyle(
      color: Colors.white, fontSize: 20, fontStyle: FontStyle.italic);
}
