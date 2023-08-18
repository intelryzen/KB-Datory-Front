import 'package:aitest/audio.dart';
import 'package:aitest/dial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'controller/record_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GetMaterialApp(
      title: 'AI Challenge',
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffffffff),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xfff5ac04)),
        useMaterial3: true,
      ),
      home:  MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
   MyHomePage({super.key});
  final RecordController recordController = Get.put(RecordController());

  @override
  Widget build(BuildContext context) {
    return const DialScreen();
  }
}

//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final recorder = Recorder();
//
//   @override
//   Widget build(BuildContext context) {
//     return const DialScreen();
//     // return Scaffold(
//     //   appBar: AppBar(
//     //     backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//     //     title: Text(widget.title),
//     //   ),
//     //   body: Center(
//     //     child: Column(
//     //       // wireframe for each widget.
//     //       mainAxisAlignment: MainAxisAlignment.center,
//     //       children: <Widget>[
//     //         Text(
//     //           '${recorder.time} sec',
//     //           style: Theme.of(context).textTheme.headlineMedium,
//     //         ),
//     //         Text(
//     //           '확장자: wav\n전송된 파일 사이즈: ${recorder.fileSize} byte',
//     //           textAlign: TextAlign.center,
//     //           style: Theme.of(context).textTheme.bodyMedium,
//     //         ),
//     //       ],
//     //     ),
//     //   ),
//     //   floatingActionButton: Row(
//     //     mainAxisAlignment: MainAxisAlignment.end,
//     //     children: [
//     //       FloatingActionButton(
//     //         onPressed: () async {
//     //           // await recorder.startRecording();
//     //           // while (true) {
//     //           //   recorder.updateTime();
//     //           //   setState(() {});
//     //           //   if (!recorder.isRecording) {
//     //           //     break;
//     //           //   }
//     //           //   await Future.delayed(Duration(seconds: 1));
//     //           // }
//     //         },
//     //         tooltip: 'Increment',
//     //         child: Icon(recorder.isRecording ? Icons.pause : Icons.play_arrow),
//     //       ),
//     //       SizedBox(
//     //         width: 10,
//     //       ),
//     //       FloatingActionButton(
//     //         onPressed: () async {
//     //           await recorder.stopRecording();
//     //           setState(() {});
//     //         },
//     //         tooltip: 'Increment',
//     //         child: const Icon(Icons.stop),
//     //       ),
//     //     ],
//     //   ), // This trailing comma makes auto-formatting nicer for build methods.
//     // );
//   }
// }
