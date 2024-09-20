import 'package:flutter/material.dart';
import '../models/tool.dart';
import '../widgets/tool_grid_item.dart';
import 'tools/calculator_page.dart';
import 'tools/timer_page.dart';
import 'tools/notes_page.dart';
import 'tools/weather_page.dart';
import 'tools/camera_page.dart';

class HomePage extends StatelessWidget {
  final List<Tool> tools = [
    Tool(name: '视倾角计算器', icon: Icons.calculate),
    Tool(name: 'Timer', icon: Icons.timer),
    Tool(name: 'Notes', icon: Icons.note),
    Tool(name: '地区天气磁偏角查询', icon: Icons.cloud),
    Tool(name: 'Camera', icon: Icons.camera_alt),
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CUGB GeoTools',
          style: TextStyle(
            fontSize: 24, // 设置标题字体大小
            fontWeight: FontWeight.bold, // 设置标题字体加粗
          ),
        ),
        centerTitle: true, // 标题居中
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0), // 设置左右间距
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200, // 设置每个单元格的最大宽度
            childAspectRatio: 1.0, // 宽高比
            crossAxisSpacing: 16, // 水平间距
            mainAxisSpacing: 16, // 垂直间距
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            return ToolGridItem(
              tool: tools[index],
              onTap: () {
                switch (tools[index].name) {
                  case '视倾角计算器':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CalculatorPage(),
                      ),
                    );
                    break;
                  case 'Timer':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TimerPage(),
                      ),
                    );
                    break;
                  case 'Notes':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotesPage(),
                      ),
                    );
                    break;
                  case '地区天气磁偏角查询':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WeatherPage(),
                      ),
                    );
                    break;
                  case 'Camera':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraPage(),
                      ),
                    );
                    break;
                  default:
                    break;
                }
              },
            );
          },
        ),
      ),
    );
  }
}
