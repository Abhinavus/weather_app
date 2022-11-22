import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Post> fetchAlbum() async {
  final response = await http
      .get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=12.97&longitude=77.59&daily=temperature_2m_max,temperature_2m_min&timezone=auto'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    print(response.body);
    return Post.fromJson(jsonDecode(response.body));
   
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}




Post postFromJson(String str) => Post.fromJson(json.decode(str));

String postToJson(Post data) => json.encode(data.toJson());

class Post {
    Post({
        required this.latitude,
        required this.longitude,
        required this.generationtimeMs,
        required this.utcOffsetSeconds,
        required this.timezone,
        required this.timezoneAbbreviation,
        required this.elevation,
        required this.dailyUnits,
        required this.daily,
    });

    double latitude;
    double longitude;
    double generationtimeMs;
    int utcOffsetSeconds;
    String timezone;
    String timezoneAbbreviation;
    double elevation;
    DailyUnits dailyUnits;
    Daily daily;

    factory Post.fromJson(Map<String, dynamic> json) => Post(
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
        generationtimeMs: json["generationtime_ms"].toDouble(),
        utcOffsetSeconds: json["utc_offset_seconds"],
        timezone: json["timezone"],
        timezoneAbbreviation: json["timezone_abbreviation"],
        elevation: json["elevation"].toDouble(),
        dailyUnits: DailyUnits.fromJson(json["daily_units"]),
        daily: Daily.fromJson(json["daily"]),
    );

    Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "generationtime_ms": generationtimeMs,
        "utc_offset_seconds": utcOffsetSeconds,
        "timezone": timezone,
        "timezone_abbreviation": timezoneAbbreviation,
        "elevation": elevation,
        "daily_units": dailyUnits.toJson(),
        "daily": daily.toJson(),
    };
}

class Daily {
    Daily({
        required this.time,
        required this.temperature2MMax,
        required this.temperature2MMin,
    });

    List<DateTime> time;
    List<double> temperature2MMax;
    List<double> temperature2MMin;

    factory Daily.fromJson(Map<String, dynamic> json) => Daily(
        time: List<DateTime>.from(json["time"].map((x) => DateTime.parse(x))),
        temperature2MMax: List<double>.from(json["temperature_2m_max"].map((x) => x.toDouble())),
        temperature2MMin: List<double>.from(json["temperature_2m_min"].map((x) => x.toDouble())),
    );

    Map<String, dynamic> toJson() => {
        "time": List<dynamic>.from(time.map((x) => "${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}")),
        "temperature_2m_max": List<dynamic>.from(temperature2MMax.map((x) => x)),
        "temperature_2m_min": List<dynamic>.from(temperature2MMin.map((x) => x)),
    };
}

class DailyUnits {
    DailyUnits({
        required this.time,
        required this.temperature2MMax,
        required this.temperature2MMin,
    });

    String time;
    String temperature2MMax;
    String temperature2MMin;

    factory DailyUnits.fromJson(Map<String, dynamic> json) => DailyUnits(
        time: json["time"],
        temperature2MMax: json["temperature_2m_max"],
        temperature2MMin: json["temperature_2m_min"],
    );

    Map<String, dynamic> toJson() => {
        "time": time,
        "temperature_2m_max": temperature2MMax,
        "temperature_2m_min": temperature2MMin,
    };
}


void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Post> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<Post>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.timezone);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}