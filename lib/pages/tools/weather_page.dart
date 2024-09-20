import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'dart:io' show Platform;

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  Future<Position> _getCurrentLocation() async {
    LocationPermission permission;

    // 检查权限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 请求权限
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('定位权限被拒绝');
      }
    }

    // 获取当前位置
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<Map<String, dynamic>> _getLocationFromIP() async {
    final response = await http.get(Uri.parse('http://ip-api.com/json/'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('无法获取位置信息');
    }
  }

  Future<Map<String, dynamic>> _fetchWeather(
      double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_probability_mean&timezone=auto&forecast_days=4'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('无法获取天气信息');
    }
  }

  Future<double> _getMagneticDeclination(
      double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://www.ngdc.noaa.gov/geomag-web/calculators/calculateDeclination?lat1=$latitude&lon1=$longitude&resultFormat=json'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['result'] != null && data['result']['declination'] != null) {
        return data['result']['declination'];
      } else {
        throw Exception('无法获取磁偏角信息');
      }
    } else {
      throw Exception('无法获取磁偏角信息');
    }
  }

  Future<String> _getPlaceName(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      return placemarks.first.locality ?? '未知地点';
    } else {
      throw Exception('无法获取地名');
    }
  }

  String _getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return '晴朗';
      case 1:
      case 2:
      case 3:
        return '多云';
      case 45:
      case 48:
        return '有雾';
      case 51:
      case 53:
      case 55:
        return '小雨';
      case 56:
      case 57:
        return '冻雨';
      case 61:
      case 63:
      case 65:
        return '雨';
      case 66:
      case 67:
        return '冻雨';
      case 71:
      case 73:
      case 75:
        return '雪';
      case 77:
        return '雪粒';
      case 80:
      case 81:
      case 82:
        return '暴雨';
      case 85:
      case 86:
        return '大雪';
      case 95:
        return '雷暴';
      case 96:
      case 99:
        return '雷暴伴有冰雹';
      default:
        return '未知';
    }
  }

  IconData _getWeatherIcon(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return Icons.wb_sunny;
      case 1:
      case 2:
      case 3:
        return Icons.cloud;
      case 45:
      case 48:
        return Icons.foggy;
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
        return Icons.grain;
      case 56:
      case 57:
      case 66:
      case 67:
        return Icons.ac_unit;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Icons.ac_unit;
      case 80:
      case 81:
      case 82:
        return Icons.grain;
      case 95:
      case 96:
      case 99:
        return Icons.flash_on;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('天气查询'),
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: Platform.isWindows
              ? _getLocationFromIP()
              : _getCurrentLocation().then((position) => {
                    'lat': position.latitude,
                    'lon': position.longitude,
                    'city': '未知地点',
                    'regionName': ''
                  }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('错误: ${snapshot.error}');
            } else {
              var locationData = snapshot.data!;
              double latitude = locationData['lat'];
              double longitude = locationData['lon'];
              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchWeather(latitude, longitude),
                builder: (context, weatherSnapshot) {
                  if (weatherSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (weatherSnapshot.hasError) {
                    return Text('天气错误: ${weatherSnapshot.error}');
                  } else {
                    var weatherData = weatherSnapshot.data!;
                    return FutureBuilder<double>(
                      future: _getMagneticDeclination(latitude, longitude),
                      builder: (context, magneticSnapshot) {
                        if (magneticSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (magneticSnapshot.hasError) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Card(
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '当前位置: ${locationData['city']}, ${locationData['regionName']}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '磁偏角错误: ${magneticSnapshot.error}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Card(
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '未来三天天气预报',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      for (int i = 1; i < 4; i++)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                '日期: ${weatherData['daily']['time'][i]}',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              Row(
                                                children: [
                                                  Icon(_getWeatherIcon(
                                                      weatherData['daily']
                                                          ['weathercode'][i])),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '天气: ${_getWeatherDescription(weatherData['daily']['weathercode'][i])}',
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '降雨概率: ${weatherData['daily']['precipitation_probability_mean'][i]}%',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                '最高温度: ${weatherData['daily']['temperature_2m_max'][i]}°C',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                '最低温度: ${weatherData['daily']['temperature_2m_min'][i]}°C',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              const Divider(),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          double magneticDeclination = magneticSnapshot.data!;
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Card(
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '当前位置: ${locationData['city']}, ${locationData['regionName']}',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          '磁偏角: $magneticDeclination°',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '未来三天天气预报',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 16),
                                        for (int i = 1; i < 4; i++)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  '日期: ${weatherData['daily']['time'][i]}',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(_getWeatherIcon(
                                                        weatherData['daily']
                                                                ['weathercode']
                                                            [i])),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '天气: ${_getWeatherDescription(weatherData['daily']['weathercode'][i])}',
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '降雨概率: ${weatherData['daily']['precipitation_probability_mean'][i]}%',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                Text(
                                                  '最高温度: ${weatherData['daily']['temperature_2m_max'][i]}°C',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                Text(
                                                  '最低温度: ${weatherData['daily']['temperature_2m_min'][i]}°C',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                const Divider(),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
