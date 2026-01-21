import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:ui';
import 'screens/welcome_screen.dart';
import 'services/user_service.dart';

void main() async {
  final startTime = DateTime.now();
  debugPrint('🚀 [MAIN] Inicio de la aplicación - ${startTime.toIso8601String()}');
  
  debugPrint('🔧 [MAIN] Llamando WidgetsFlutterBinding.ensureInitialized()...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('✅ [MAIN] WidgetsFlutterBinding.ensureInitialized() completado');
  
  // CRÍTICO: Esperar 500ms para que iOS esté completamente listo
  // Esto evita el crash EXC_BAD_ACCESS en path_provider_foundation
  debugPrint('⏳ [MAIN] Esperando 500ms para que iOS esté completamente inicializado...');
  await Future.delayed(const Duration(milliseconds: 500));
  debugPrint('✅ [MAIN] Delay completado - iOS debería estar listo');
  
  // FIREBASE DESACTIVADO - Comentado completamente
  // // Inicializar Firebase
  // try {
  //   debugPrint('🔥 [MAIN] Inicializando Firebase...');
  //   await Firebase.initializeApp();
  //   debugPrint('✅ [MAIN] Firebase inicializado correctamente');
  //   
  //   // Configurar Crashlytics
  //   FlutterError.onError = (errorDetails) {
  //     FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  //   };
  //   
  //   // Pasar errores no capturados a Crashlytics
  //   PlatformDispatcher.instance.onError = (error, stack) {
  //     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //     return true;
  //   };
  //   
  //   FirebaseCrashlytics.instance.log('🚀 [MAIN] App iniciada - Firebase Crashlytics configurado');
  //   debugPrint('✅ [MAIN] Crashlytics configurado');
  // } catch (e, stackTrace) {
  //   debugPrint('❌ [MAIN] Error inicializando Firebase: $e');
  //   // Continuar sin Firebase si falla
  // }
  
  // Inicializar la app primero, luego Hive en segundo plano
  // Esto previene el crash en path_provider_foundation
  debugPrint('📱 [MAIN] Llamando runApp()...');
  // FirebaseCrashlytics.instance.log('📱 [MAIN] Llamando runApp()');
  runApp(const MyApp());
  debugPrint('✅ [MAIN] runApp() completado - App iniciada');
  
  // Inicializar Hive después de que la app esté corriendo
  // Usar un delay más largo para asegurar que los plugins nativos estén listos
  debugPrint('🔄 [MAIN] Iniciando inicialización de Hive en segundo plano...');
  // FirebaseCrashlytics.instance.log('🔄 [MAIN] Iniciando inicialización de Hive en segundo plano');
  _initializeHiveInBackground();
  debugPrint('✅ [MAIN] Función _initializeHiveInBackground() llamada (no esperada)');
}

Future<void> _initializeHiveInBackground() async {
  final initStartTime = DateTime.now();
  final logMessage = '⏳ [HIVE_BG] Iniciando inicialización diferida de Hive - ${initStartTime.toIso8601String()}';
  // FirebaseCrashlytics.instance.log(logMessage);
  debugPrint(logMessage);
  
  // Esperar a que la app esté completamente inicializada
  // Aumentado a 2000ms para iOS 18.7.1 que requiere más tiempo
  // FirebaseCrashlytics.instance.log('⏳ [HIVE_BG] Esperando 2000ms para que los plugins nativos estén listos (iOS 18)...');
  debugPrint('⏳ [HIVE_BG] Esperando 2000ms para que los plugins nativos estén listos (iOS 18)...');
  await Future.delayed(const Duration(milliseconds: 2000));
  final afterDelay = DateTime.now();
  final delayDuration = afterDelay.difference(initStartTime);
  final delayLog = '✅ [HIVE_BG] Delay completado después de ${delayDuration.inMilliseconds}ms';
  // FirebaseCrashlytics.instance.log(delayLog);
  debugPrint(delayLog);
  
  // FirebaseCrashlytics.instance.log('🔄 [HIVE_BG] Intentando inicializar UserService (primer intento)...');
  debugPrint('🔄 [HIVE_BG] Intentando inicializar UserService (primer intento)...');
  try {
    final beforeInit = DateTime.now();
    await UserService.init();
    final afterInit = DateTime.now();
    final initDuration = afterInit.difference(beforeInit);
    final successLog = '✅ [HIVE_BG] Hive inicializado correctamente en ${initDuration.inMilliseconds}ms';
    // FirebaseCrashlytics.instance.log(successLog);
    debugPrint(successLog);
    final totalTimeLog = '✅ [HIVE_BG] Total tiempo desde inicio: ${afterInit.difference(initStartTime).inMilliseconds}ms';
    // FirebaseCrashlytics.instance.log(totalTimeLog);
    debugPrint(totalTimeLog);
  } catch (e, stackTrace) {
    final errorTime = DateTime.now();
    final errorLog = '❌ [HIVE_BG] Error inicializando UserService (primer intento) - ${errorTime.toIso8601String()}';
    // FirebaseCrashlytics.instance.log(errorLog);
    debugPrint(errorLog);
    // FirebaseCrashlytics.instance.log('❌ [HIVE_BG] Error: $e');
    debugPrint('❌ [HIVE_BG] Error: $e');
    // FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: false);
    debugPrint('❌ [HIVE_BG] Stack trace: $stackTrace');
    
    // Reintentar después de otro delay más largo
    // FirebaseCrashlytics.instance.log('⏳ [HIVE_BG] Esperando 3000ms antes del segundo intento...');
    debugPrint('⏳ [HIVE_BG] Esperando 3000ms antes del segundo intento...');
    await Future.delayed(const Duration(milliseconds: 3000));
    final afterSecondDelay = DateTime.now();
    final secondDelayLog = '✅ [HIVE_BG] Segundo delay completado después de ${afterSecondDelay.difference(errorTime).inMilliseconds}ms';
    // FirebaseCrashlytics.instance.log(secondDelayLog);
    debugPrint(secondDelayLog);
    
    // FirebaseCrashlytics.instance.log('🔄 [HIVE_BG] Intentando inicializar UserService (segundo intento)...');
    debugPrint('🔄 [HIVE_BG] Intentando inicializar UserService (segundo intento)...');
    try {
      final beforeSecondInit = DateTime.now();
      await UserService.init();
      final afterSecondInit = DateTime.now();
      final secondInitDuration = afterSecondInit.difference(beforeSecondInit);
      final secondSuccessLog = '✅ [HIVE_BG] Hive inicializado en segundo intento en ${secondInitDuration.inMilliseconds}ms';
      // FirebaseCrashlytics.instance.log(secondSuccessLog);
      debugPrint(secondSuccessLog);
      final secondTotalTimeLog = '✅ [HIVE_BG] Total tiempo desde inicio: ${afterSecondInit.difference(initStartTime).inMilliseconds}ms';
      // FirebaseCrashlytics.instance.log(secondTotalTimeLog);
      debugPrint(secondTotalTimeLog);
    } catch (e2, stackTrace2) {
      final finalErrorTime = DateTime.now();
      final finalErrorLog = '❌ [HIVE_BG] Error en segundo intento de inicialización - ${finalErrorTime.toIso8601String()}';
      // FirebaseCrashlytics.instance.log(finalErrorLog);
      // FirebaseCrashlytics.instance.log('❌ [HIVE_BG] Error: $e2');
      // FirebaseCrashlytics.instance.recordError(e2, stackTrace2, fatal: false);
      // FirebaseCrashlytics.instance.log('⚠️ [HIVE_BG] La app continuará sin Hive inicializado');
      debugPrint(finalErrorLog);
      debugPrint('❌ [HIVE_BG] Error: $e2');
      debugPrint('❌ [HIVE_BG] Stack trace: $stackTrace2');
      debugPrint('⚠️ [HIVE_BG] La app continuará sin Hive inicializado');
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
     //home: Scaffold(backgroundColor: Colors.red, body: Center(child: Text("HOLA"))),
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
