import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yumemi_weather/yumemi_weather.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

// 天気情報を管理するFutureProvider
final weatherProvider = FutureProvider<String>((ref) async {
  String jsonString = '''
{
"area": "Tokyo",
"date": "2024-09-07T12:00:00+09:00"
}
''';
  try {
    final weatherJson = YumemiWeather().fetchWeather(jsonString);
    return weatherJson;
  } catch (e) {
    throw Exception('Failed to fetch weather');
  }
});

void main() {
  // 最初に表示するWidget
  runApp(const ProviderScope(child: WeatherApp()));
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // アプリ名
      title: 'WeatherApp',
      home: InitialScreen(), // アプリ起動時に表示する画面
    );
  }
}

// 初期画面
class InitialScreen extends ConsumerWidget {
  const InitialScreen({super.key});

  @override
  // 0.5秒後にTopPageに遷移
  Widget build(BuildContext context, WidgetRef ref) {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TopPage()),
      );
    });

    return const Scaffold(
      backgroundColor: Colors.green,
    );
  }
}

/*mixin AfterLayoutMixin<T extends StatefulWidget> on State<T> {
  //Stateを継承したクラスに適用され、initStateをオーバーライドし、AfterLayoutMixinを呼び出す。
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((_) => afterFirstLayout());
  }

// 適用先のクラスで定義する。
  void afterFirstLayout();
}*/

// メイン画面
class TopPage extends ConsumerWidget {
  const TopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画面の幅を取得
    final double screenWidth = MediaQuery.of(context).size.width;
    // weatherProviderの状態を監視
    final weatherState = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather Forecast',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: weatherState.when(
        data: (weatherJson) {
          // weatherJsonをパースして必要な情報を取得
          final Map<String, dynamic> weatherData = jsonDecode(weatherJson);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenWidth / 2,
                    height: screenWidth / 2,
                    child: SvgPicture.asset(
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
                            '${weatherData['min_temperature']}°C',
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.fontSize,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth / 4,
                        child: Center(
                          child: Text(
                            '${weatherData['max_temperature']}°C',
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.fontSize,
                              color: Colors.red,
                            ),
                          ),
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
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.fontSize,
                            color: Colors.blue,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth / 4,
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          ref.refresh(weatherProvider); // Reloadボタンで再取得
                        },
                        child: Text(
                          'Reload',
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.fontSize,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _showErrorDialog(context, ref),
      ),
    );
  }

  // ダイアログ中身
  Widget _showErrorDialog(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Error'),
      content: const Text('Failed to fetch weather information.'),
      actions: <Widget>[
        TextButton(
          child: const Text('Retry'),
          onPressed: () {
            ref.refresh(weatherProvider); // Reloadボタンで再取得
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TopPage()),
            ); // TopPageに遷移してReloadボタンが押せる状態に戻る
          },
        ),
      ],
    );
  }
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
