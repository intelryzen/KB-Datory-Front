// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:audio_session/audio_session.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
//
// class RecordController extends GetxController {
//   final String _serverUrl = "http://192.168.0.12:8080/api/upload_audio/";
//   final FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
//   bool _mRecorderIsInited = false;
//   RxBool isRecording = false.obs;
//   RxInt recordingTime = 0.obs;
//   RxInt score = 0.obs;
//
//   String? _mPath;
//   String? _tempPath;
//
//   bool sending = false;
//   StreamSubscription? _mRecordingDataSubscription;
//   final List<Uint8List> audioChunks = [];
//
//   Uint8List? lastChunk;
//
//   RecordController() {}
//
//   Future<void> openRecorder() async {
//     var status = await Permission.microphone.request();
//
//     // if (status != PermissionStatus.granted) {
//     //   try {
//     //     throw RecordingPermissionException('Microphone permission not granted');
//     //   } catch (error) {
//     //     log(error.toString());
//     //   }
//     //   return;
//     // }
//
//     await _mRecorder.openRecorder();
//
//     final session = await AudioSession.instance;
//     await session.configure(AudioSessionConfiguration(
//       avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
//       avAudioSessionCategoryOptions:
//           AVAudioSessionCategoryOptions.allowBluetooth |
//               AVAudioSessionCategoryOptions.defaultToSpeaker,
//       avAudioSessionMode: AVAudioSessionMode.voiceChat,
//       avAudioSessionRouteSharingPolicy:
//           AVAudioSessionRouteSharingPolicy.defaultPolicy,
//       avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
//       androidAudioAttributes: const AndroidAudioAttributes(
//         contentType: AndroidAudioContentType.speech,
//         flags: AndroidAudioFlags.none,
//         usage: AndroidAudioUsage.voiceCommunication,
//       ),
//       androidAudioFocusGainType:
//           AndroidAudioFocusGainType.gainTransientExclusive,
//       androidWillPauseWhenDucked: true,
//     ));
//
//     _mRecorderIsInited = true;
//     record();
//   }
//
//   Future<IOSink> createFile() async {
//     var tempDir = await getTemporaryDirectory();
//     _mPath = '${tempDir.path}/call.pcm';
//     _tempPath = '${tempDir.path}/temp-call.wav';
//     var outputFile = File(_mPath!);
//     var tempFile = File(_tempPath!);
//     if (outputFile.existsSync()) {
//       await outputFile.delete();
//     }
//     if (tempFile.existsSync()) {
//       await tempFile.delete();
//     }
//     return outputFile.openWrite();
//   }
//
//   // Future<void> _getFileSize() async {
//   //   final fileBytes = await File(_mPath!).readAsBytes();
//   //   print(fileBytes.lengthInBytes);
//   // }
//
//   Future<void> _sendFile(String path) async {
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(_serverUrl));
//       request.files.add(await http.MultipartFile.fromPath('file', path));
//       http.StreamedResponse response = await request.send();
//       if (response.statusCode == 200) {
//         String json = await response.stream.bytesToString();
//         int score = jsonDecode(json)["score"];
//         print("보이스피싱 결과 수신: $score");
//         this.score = score.obs;
//       }
//     } catch (error) {
//       print(error);
//     }
//   }
//
//   Future<void> record() async {
//     assert(_mRecorderIsInited);
//     var sink = await createFile();
//     var recordingDataController = StreamController<Food>();
//     _mRecordingDataSubscription =
//         recordingDataController.stream.listen((buffer) async {
//       if (buffer is FoodData) {
//         // sink.add(buffer.data!);
//         audioChunks.add(Uint8List.fromList(buffer.data!));
//       }
//     });
//
//     try {
//       await _mRecorder.startRecorder(
//         // toFile: _mPath,
//         toStream: recordingDataController.sink,
//         codec: Codec.pcm16,
//         numChannels: 1,
//         sampleRate: 16000,
//       );
//       isRecording = _mRecorder.isRecording.obs ?? false.obs;
//       updateRecordTime();
//     } catch (error) {
//       print(error);
//       Fluttertoast.showToast(msg: "설정에서 마이크를 허용해주세요.");
//     }
//   }
//
//   Future<void> write15MChunksToFile(String filePath) async {
//     if(lastChunk == null){
//       audioChunks.last;
//     }
//
//     int start = audioChunks.indexWhere((element) => element == lastChunk);
//
//     if (start == -1) return;
//
//     lastChunk = audioChunks.last;
//
//     List<Uint8List> chunks = [];
//
//     for (int i = start; i < audioChunks.length; i++) {
//       chunks.add(audioChunks[i]);
//     }
//
//     var totalLength = chunks.fold(0, (length, chunk) => length + chunk.length);
//     var mergedBytes = Uint8List(totalLength);
//     var offset = 0;
//     for (var chunk in chunks) {
//       mergedBytes.setRange(offset, offset + chunk.length, chunk);
//       offset += chunk.length;
//     }
//
//     var file = File(filePath);
//     await file.writeAsBytes(mergedBytes);
//     print("15초 청크 구간 파일로 저장 완료");
//   }
//
//   Future<void> writeChunksToFile(
//       List<Uint8List> chunks, String filePath) async {
//     // 모든 Uint8List 객체를 하나의 큰 Uint8List로 합치기
//     var totalLength = chunks.fold(0, (length, chunk) => length + chunk.length);
//     var mergedBytes = Uint8List(totalLength);
//     var offset = 0;
//     for (var chunk in chunks) {
//       mergedBytes.setRange(offset, offset + chunk.length, chunk);
//       offset += chunk.length;
//     }
//
//     // 합친 Uint8List를 파일에 쓰기
//     var file = File(filePath);
//     await file.writeAsBytes(mergedBytes);
//   }
//
//   Future<void> closeRecorder() async {
//     await _mRecorder.stopRecorder();
//     if (_mRecordingDataSubscription != null) {
//       await _mRecordingDataSubscription!.cancel();
//       _mRecordingDataSubscription = null;
//     }
//     isRecording = false.obs;
//     recordingTime = 0.obs;
//     _mRecorder.closeRecorder();
//     // _sendFile(_mPath!);
//     // var tempDir = await getTemporaryDirectory();
//     // String tt = '${tempDir.path}/66.wav';
//     // await writeChunksToFile(audioChunks, tt);
//     //  audioChunks.clear();
//   }
//
//   Future<void> copyFile(String sourcePath, String targetPath) async {
//     final sourceFile = File(sourcePath);
//     final targetFile = File(targetPath);
//
//     if (await sourceFile.exists()) {
//       await sourceFile.copy(targetPath);
//       // print('File copied successfully');
//     } else {
//       // print('Source file does not exist');
//     }
//   }
//
//   Future<void> updateRecordTime() async {
//     while (isRecording.isTrue) {
//       await Future.delayed(const Duration(seconds: 1));
//       recordingTime++;
//       // await convertPcmToWav(_mPath!, _tempPath!, 16000);
//       // _sendFile(_tempPath!);
//
//       // 15 초마다 요청
//       if(recordingTime % 15 == 0){
//         write15MChunksToFile(_mPath!).then((_) async {
//           await _sendFile(_mPath!);
//         });
//       }
//       // if (!sending) {
//       //   sending = true;
//       //   writeChunksToFile(audioChunks, _mPath!).then((_) async {
//       //     await convertPcmToWav(_mPath!, _tempPath!, 16000);
//       //   }).then((_) async {
//       //     await _sendFile(_tempPath!);
//       //   }).then((_) {
//       //     sending = false;
//       //   });
//       // }
//
//       // if (_mPath != null && _tempPath != null) {
//       //  await copyFile(_mPath!, _tempPath!).then((_) async {
//       //     await _sendFile(_tempPath!);
//       //   });
//       // }
//       // writeChunksToFile(audioChunks, _mPath!);
//       // if (audioChunks.isNotEmpty) {
//       //   // var combinedData = concatUint8List(audioChunks);
//       //   // var filePath = await saveToFile(chunk!);
//       //   String filePath = await getFile2();
//       //   await _sendFile(filePath);
//       //   audioChunks.clear();
//       // }
//     }
//   }
//
//   Future convertPcmToWav(String pcmPath, String wavPath, int sampleRate) async {
//     final pcmFile = File(pcmPath);
//     final pcmData = await pcmFile.readAsBytes();
//
//     final fileSize = pcmData.length + 36;
//     final dataSize = pcmData.length;
//
//     final wavHeader = ByteData(44)
//       ..setUint32(0, 0x46464952, Endian.little) // "RIFF"
//       ..setUint32(4, fileSize, Endian.little)
//       ..setUint32(8, 0x45564157, Endian.little) // "WAVE"
//       ..setUint32(12, 0x20746D66, Endian.little) // "fmt "
//       ..setUint32(16, 16, Endian.little) // Subchunk1Size
//       ..setUint16(20, 1, Endian.little) // AudioFormat
//       ..setUint16(22, 1, Endian.little) // NumChannels (Mono)
//       ..setUint32(24, sampleRate, Endian.little) // SampleRate
//       ..setUint32(28, sampleRate * 2, Endian.little) // ByteRate
//       ..setUint16(32, 2, Endian.little) // BlockAlign
//       ..setUint16(34, 16, Endian.little) // BitsPerSample
//       ..setUint32(36, 0x61746164, Endian.little) // "data"
//       ..setUint32(40, dataSize, Endian.little);
//
//     final wavData =
//         Uint8List.fromList([...wavHeader.buffer.asUint8List(), ...pcmData]);
//
//     final wavFile = File(wavPath);
//     await wavFile.writeAsBytes(wavData);
//   }
//
//   bool get recorderIsInited => _mRecorderIsInited;
// }
//
// // Future<String> saveToFile(Uint8List data) async {
// //   var tempDir = await getTemporaryDirectory();
// //   var file = File('${tempDir.path}/1.pcm');
// //   await file.writeAsBytes(data);
// //   print(await file.length());
// //   print("dd");
// //   return file.path;
// // }
// //
// // Future<void> concatUint8List(List<Uint8List> chunks) async {
// //   var totalLength = chunks.fold(0, (length, chunk) => length + chunk.length);
// //   print("len : ${totalLength}");
// //   print("len : ${audioChunks.length}");
// //   var result = Uint8List(totalLength);
// //   var offset = 0;
// //   print(totalLength);
// //   for (var chunk in chunks) {
// //     result.setRange(offset, offset + chunk.length, chunk);
// //     offset += chunk.length;
// //   }
// //   String pa =  await saveToFile(result);
// //   await _sendFile(pa);
// // }
// //
// // Future<String> getFile2() async {
// //   final byteData = await rootBundle.load('assets/22.wav');
// //
// //   final tempDir = await getTemporaryDirectory();
// //   final file = await File('${tempDir.path}/22.wav').create();
// //   await file.writeAsBytes(byteData.buffer.asUint8List());
// //
// //    return file.path;
// // }
