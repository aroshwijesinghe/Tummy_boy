import 'package:flutter/material.dart';

class TummyBoyApp extends StatelessWidget {
  const TummyBoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pushup Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PushupCounterPage(),
    );
  }
}

class PushupCounterPage extends StatefulWidget {
  const PushupCounterPage({super.key});

  @override
  State<PushupCounterPage> createState() => _PushupCounterPageState();
}

class _PushupCounterPageState extends State<PushupCounterPage> {
  int pushupCount = 0;

  void increase() {
    setState(() {
      pushupCount++;
    });
  }

  void reset() {
    setState(() {
      pushupCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pushup Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pushups Done',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 12),
            Text(
              '$pushupCount',
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: increase,
              child: const Text('Add Pushup'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: reset,
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
