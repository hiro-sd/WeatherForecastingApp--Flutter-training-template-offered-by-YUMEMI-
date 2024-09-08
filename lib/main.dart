import 'package:flutter/material.dart';
import 'package:yumemi_weather/yumemi_weather.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

void main() {
  // 最初に表示するWidget
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // アプリ名
      title: 'WeatherApp',
      theme: ThemeData(),
      home: const InitialScreen(), // アプリ起動時に表示する画面
    );
  }
}

// 初期画面
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  InitialScreenState createState() => InitialScreenState();
}

class InitialScreenState extends State<InitialScreen>
    with AfterLayoutMixin<InitialScreen> {
  @override
  void afterFirstLayout() {
    // 0.5秒後にTopPageに遷移
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TopPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
    );
  }
}

mixin AfterLayoutMixin<T extends StatefulWidget> on State<T> {
  //Stateを継承したクラスに適用され、initStateをオーバーライドし、AfterLayoutMixinを呼び出す。
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((_) => afterFirstLayout());
  }

// 適用先のクラスで定義する。
  void afterFirstLayout();
}

// メイン画面
class TopPage extends StatefulWidget {
  const TopPage({super.key});

  @override
  TopPageState createState() => TopPageState();
}

class TopPageState extends State<TopPage> {
  String _weatherJson = '';
  String jsonString = '''
  {
    "area": "Tokyo",
    "date": "2024-09-07T12:00:00+09:00"
  }
  ''';

  // 天気予報を取得する関数
  Future<void> _fetchWeather() async {
    try {
      final weatherJson = YumemiWeather().fetchWeather(jsonString);
      setState(() {
        _weatherJson = weatherJson;
      });
    } catch (e) {
      setState(() {
        // エラーが発生した場合はエラーダイアログを表示
        _showErrorDialog();
      });
    }
  }

// ダイアログ中身
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to fetch weather information.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
          ],
        );
      },
    );
  }

  // 天気に対応するSVG画像のパスを取得
  String _getWeatherImage(String weatherCondition) {
    switch (weatherCondition) {
      case 'sunny':
        return 'assets/images/sunny.svg';
      case 'cloudy':
        return 'assets/images/cloudy.svg';
      case 'rainy':
        return 'assets/images/rainy.svg';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 画面の幅を取得
    final double screenWidth = MediaQuery.of(context).size.width;

    // weatherJsonをパースして必要な情報を取得
    Map<String, dynamic> weatherData = {};
    if (_weatherJson.isNotEmpty) {
      weatherData = jsonDecode(_weatherJson);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth / 2,
              height: screenWidth / 2,
              child: _weatherJson.isEmpty
                  ? const Placeholder()
                  : SvgPicture.asset(
                      _getWeatherImage(weatherData['weather_condition']),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenWidth / 4,
                  child: Center(
                    child: Text(
                        weatherData.isEmpty
                            ? ''
                            : '${weatherData['min_temperature']}°C',
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.fontSize,
                            color: Colors.blue)),
                  ),
                ),
                SizedBox(
                  width: screenWidth / 4,
                  child: Center(
                    child: Text(
                        weatherData.isEmpty
                            ? ''
                            : '${weatherData['max_temperature']}°C',
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.fontSize,
                            color: Colors.red)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16)
          ],
        ),
        const SizedBox(height: 80),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth / 4,
              child: Center(
                child: TextButton(
                  child: Text('Close',
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.labelLarge?.fontSize,
                          color: Colors.blue)),
                  onPressed: () {
                    Navigator.pop(context); // Closeボタンを押した時に画面を閉じる
                  },
                ),
              ),
            ),
            SizedBox(
              width: screenWidth / 4,
              child: Center(
                child: TextButton(
                  onPressed: _fetchWeather, // Reloadボタンを押した時に天気予報を取得
                  child: Text('Reload',
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.labelLarge?.fontSize,
                          color: Colors.red)),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
