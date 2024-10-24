import 'dart:math';
import 'package:flutter/material.dart';
import 'local_storage.dart';

void main() {
  runApp(AquariumApp());
}

class AquariumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Aquarium',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AquariumScreen(),
    );
  }
}

class Fish {
  Color color;
  double speed;
  Offset position;
  Offset direction;

  Fish({required this.color, required this.speed})
      : position = Offset(150, 150), // Start position
        direction = _generateRandomDirection();

  static Offset _generateRandomDirection() {
    double dx = Random().nextDouble() * 2 - 1;
    double dy = Random().nextDouble() * 2 - 1;
    double length = sqrt(dx * dx + dy * dy);
    return Offset(dx / length, dy / length); // Normalize the direction
  }

  void updatePosition(double aquariumSize) {
    position += direction * speed;

    
    if (position.dx < 0 || position.dx > aquariumSize - 20) {
      direction = Offset(-direction.dx, direction.dy);
    }
    if (position.dy < 0 || position.dy > aquariumSize - 20) {
      direction = Offset(direction.dx, -direction.dy);
    }
  }
}

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> with SingleTickerProviderStateMixin {
  final double aquariumSize = 300.0;
  List<Fish> fishList = [];
  Color selectedColor = Colors.red;
  double selectedSpeed = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 16))..repeat();
    _loadSettings();
    _controller.addListener(() {
      setState(() {
        for (var fish in fishList) {
          fish.updatePosition(aquariumSize);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addFish() {
    if (fishList.length < 10) { // Limit to 10 fish
      setState(() {
        fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
      });
    }
  }

  Future<void> _saveSettings() async {
    LocalStorage storage = LocalStorage();
    await storage.saveSettings(fishList.length, selectedSpeed, selectedColor.value);
  }

  Future<void> _loadSettings() async {
    LocalStorage storage = LocalStorage();
    final settings = await storage.loadSettings();
    if (settings != null) {
      setState(() {
        int fishCount = settings['fishCount'] ?? 0;
        selectedSpeed = (settings['speed'] ?? 1.0).toDouble();
        selectedColor = Color(settings['color'] ?? Colors.red.value);
        fishList = List.generate(fishCount, (index) => Fish(color: selectedColor, speed: selectedSpeed));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Aquarium'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: aquariumSize,
              height: aquariumSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 4),
              ),
              child: Stack(
                children: fishList.map((fish) {
                  return Positioned(
                    left: fish.position.dx,
                    top: fish.position.dy,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: fish.color,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _addFish,
                  child: Text('Add Fish'),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Speed:'),
                    Slider(
                      value: selectedSpeed,
                      min: 0.1,
                      max: 5.0,
                      divisions: 50,
                      label: selectedSpeed.toString(),
                      onChanged: (value) {
                        setState(() {
                          selectedSpeed = value;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Color:'),
                    DropdownButton<Color>(
                      value: selectedColor,
                      items: [
                        DropdownMenuItem(
                          child: Container(width: 20, height: 20, color: Colors.red),
                          value: Colors.red,
                        ),
                        DropdownMenuItem(
                          child: Container(width: 20, height: 20, color: Colors.blue),
                          value: Colors.blue,
                        ),
                        DropdownMenuItem(
                          child: Container(width: 20, height: 20, color: Colors.green),
                          value: Colors.green,
                        ),
                       
                      ],
                      onChanged: (color) {
                        setState(() {
                          selectedColor = color!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
