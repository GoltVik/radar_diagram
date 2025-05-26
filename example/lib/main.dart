import 'package:flutter/material.dart';
import 'package:radar_diagram/radar_diagram.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radar Diagram Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RadarDiagramExampleScreen(),
    );
  }
}

class RadarDiagramExampleScreen extends StatelessWidget {
  const RadarDiagramExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Radar Diagram Example')),
      body: Center(
        child: SizedBox(
          width: 400,
          child: RadarDiagram(
            values: [3, 2, 3, 2, 3],
            axes: 5,
            levels: 5,
            dataFillColor: ColorScheme.of(context).primary,
          ),
        ),
      ),
    );
  }
}
