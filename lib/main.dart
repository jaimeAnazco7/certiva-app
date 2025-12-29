import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'services/user_service.dart';

void main() async {
  final startTime = DateTime.now();
  print('🚀 [MAIN] Inicio de la aplicación - ${startTime.toIso8601String()}');
  
  print('🔧 [MAIN] Llamando WidgetsFlutterBinding.ensureInitialized()...');
  WidgetsFlutterBinding.ensureInitialized();
  print('✅ [MAIN] WidgetsFlutterBinding.ensureInitialized() completado');
  
  // Inicializar la app primero, luego Hive en segundo plano
  // Esto previene el crash en path_provider_foundation
  print('📱 [MAIN] Llamando runApp()...');
  runApp(const MyApp());
  print('✅ [MAIN] runApp() completado - App iniciada');
  
  // Inicializar Hive después de que la app esté corriendo
  // Usar un delay más largo para asegurar que los plugins nativos estén listos
  print('🔄 [MAIN] Iniciando inicialización de Hive en segundo plano...');
  _initializeHiveInBackground();
  print('✅ [MAIN] Función _initializeHiveInBackground() llamada (no esperada)');
}

Future<void> _initializeHiveInBackground() async {
  final initStartTime = DateTime.now();
  print('⏳ [HIVE_BG] Iniciando inicialización diferida de Hive - ${initStartTime.toIso8601String()}');
  
  // Esperar a que la app esté completamente inicializada
  print('⏳ [HIVE_BG] Esperando 1000ms para que los plugins nativos estén listos...');
  await Future.delayed(const Duration(milliseconds: 1000));
  final afterDelay = DateTime.now();
  final delayDuration = afterDelay.difference(initStartTime);
  print('✅ [HIVE_BG] Delay completado después de ${delayDuration.inMilliseconds}ms');
  
  print('🔄 [HIVE_BG] Intentando inicializar UserService (primer intento)...');
  try {
    final beforeInit = DateTime.now();
    await UserService.init();
    final afterInit = DateTime.now();
    final initDuration = afterInit.difference(beforeInit);
    print('✅ [HIVE_BG] Hive inicializado correctamente en ${initDuration.inMilliseconds}ms');
    print('✅ [HIVE_BG] Total tiempo desde inicio: ${afterInit.difference(initStartTime).inMilliseconds}ms');
  } catch (e, stackTrace) {
    final errorTime = DateTime.now();
    print('❌ [HIVE_BG] Error inicializando UserService (primer intento) - ${errorTime.toIso8601String()}');
    print('❌ [HIVE_BG] Error: $e');
    print('❌ [HIVE_BG] Stack trace: $stackTrace');
    
    // Reintentar después de otro delay
    print('⏳ [HIVE_BG] Esperando 2000ms antes del segundo intento...');
    await Future.delayed(const Duration(milliseconds: 2000));
    final afterSecondDelay = DateTime.now();
    print('✅ [HIVE_BG] Segundo delay completado después de ${afterSecondDelay.difference(errorTime).inMilliseconds}ms');
    
    print('🔄 [HIVE_BG] Intentando inicializar UserService (segundo intento)...');
    try {
      final beforeSecondInit = DateTime.now();
      await UserService.init();
      final afterSecondInit = DateTime.now();
      final secondInitDuration = afterSecondInit.difference(beforeSecondInit);
      print('✅ [HIVE_BG] Hive inicializado en segundo intento en ${secondInitDuration.inMilliseconds}ms');
      print('✅ [HIVE_BG] Total tiempo desde inicio: ${afterSecondInit.difference(initStartTime).inMilliseconds}ms');
    } catch (e2, stackTrace2) {
      final finalErrorTime = DateTime.now();
      print('❌ [HIVE_BG] Error en segundo intento de inicialización - ${finalErrorTime.toIso8601String()}');
      print('❌ [HIVE_BG] Error: $e2');
      print('❌ [HIVE_BG] Stack trace: $stackTrace2');
      print('⚠️ [HIVE_BG] La app continuará sin Hive inicializado');
      // La app puede continuar sin Hive, los servicios manejarán el error
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
