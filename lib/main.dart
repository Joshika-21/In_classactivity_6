import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() {
  setupWindow();
  runApp(
    ChangeNotifierProvider(
      create: (context) => Counter(),
      child: const MyApp(),
    ),
  );
}

const double windowWidth = 360;
const double windowHeight = 640;

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Provider Counter');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(
        Rect.fromCenter(
          center: screen!.frame.center,
          width: windowWidth,
          height: windowHeight,
        ),
      );
    });
  }
}

class Counter with ChangeNotifier {
  int value = 0;

  void increment() {
    if (value < 99) {
      value += 1;
      notifyListeners();
    }
  }

  void decrement() {
    if (value > 0) {
      value -= 1;
      notifyListeners();
    }
  }

  void setAge(double newValue) {
    value = newValue.toInt();
    notifyListeners();
  }

  Map<String, dynamic> getMilestone() {
    if (value == 0) {
      return {"message": "Not born yet", "color": Colors.lightBlue.shade100};
    } else if (value <= 12) {
      return {"message": "You're a child!", "color": Colors.lightBlue.shade100};
    } else if (value <= 19) {
      return {"message": "Teenager time!", "color": Colors.lightGreen.shade100};
    } else if (value <= 30) {
      return {
        "message": "You're a young adult!",
        "color": Colors.yellow.shade100,
      };
    } else if (value <= 50) {
      return {
        "message": "You're an adult now!",
        "color": Colors.orange.shade100,
      };
    } else {
      return {"message": "Golden years!", "color": Colors.grey.shade300};
    }
  }

  Color getProgressColor() {
    if (value <= 33) return Colors.green;
    if (value <= 67) return Colors.yellow;
    return Colors.red;
  }

  double getProgressValue() {
    return value / 99;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Age Counter',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Age Counter')),
      body: Consumer<Counter>(
        builder: (context, counter, child) {
          final milestone = counter.getMilestone();
          return Container(
            color: milestone["color"],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    milestone["message"],
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'I am ${counter.value} years old',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),

                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LinearProgressIndicator(
                      value: counter.getProgressValue(),
                      backgroundColor: Colors.grey.shade300,
                      color: counter.getProgressColor(),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Row for Increment and Decrement Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          var counter = context.read<Counter>();
                          counter.increment();
                        },
                        child: const Text("Increase Age"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          var counter = context.read<Counter>();
                          counter.decrement();
                        },
                        child: const Text("Decrease Age"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Slider for Age
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Slider(
                      value: counter.value.toDouble(),
                      min: 0,
                      max: 99,
                      divisions: 99,
                      label: '${counter.value}',
                      onChanged: (double newValue) {
                        counter.setAge(newValue);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
