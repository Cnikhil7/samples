import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final model = CounterModel();

  await getTemporaryDirectory();

  runApp(
    ChangeNotifierProvider.value(
      value: model,
      child: const MyApp(),
    ),
  );
}

class CounterModel extends ChangeNotifier {
  CounterModel() {
    _channel.setMethodCallHandler(_handleMessage);
    _channel.invokeMethod<void>('requestCounter');
  }

  final _channel = const MethodChannel('dev.flutter.example/counter');

  int _count = 0;

  int get count => _count;

  void increment() {
    _channel.invokeMethod<void>('incrementCounter');
  }

  Future<dynamic> _handleMessage(MethodCall call) async {
    if (call.method == 'reportCounter') {
      _count = call.arguments as int;
      notifyListeners();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Module Title',
      routes: {
        '/': (context) => const FullScreenView(),
        '/mini': (context) => const Contents(),
      },
    );
  }
}

class FullScreenView extends StatelessWidget {
  const FullScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full-screen Flutter'),
      ),
      body: const Contents(showExit: true),
    );
  }
}

class Contents extends StatelessWidget {
  final bool showExit;

  const Contents({this.showExit = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaInfo = MediaQuery.of(context);

    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          const Positioned.fill(
            child: Opacity(
              opacity: .25,
              child: FittedBox(
                fit: BoxFit.cover,
                child: FlutterLogo(),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Window is ${mediaInfo.size.width.toStringAsFixed(1)} x '
                  '${mediaInfo.size.height.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.headline5,
                ),
                const SizedBox(height: 16),
                Consumer<CounterModel>(
                  builder: (context, model, child) {
                    return Text(
                      'Taps: ${model.count}',
                      style: Theme.of(context).textTheme.headline5,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<CounterModel>(
                  builder: (context, model, child) {
                    return ElevatedButton(
                      onPressed: () => model.increment(),
                      child: const Text('Tap me!'),
                    );
                  },
                ),
                if (showExit) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => SystemNavigator.pop(animated: true),
                    child: const Text('Exit this screen'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
