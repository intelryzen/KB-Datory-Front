import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';

class Recorder {
  late FlutterSoundRecorder _recorder;
  late bool isRecording;
  late String _filePath;
  int fileSize = 0;

  int time = 0;
  final String _serverUrl = "https://local";
  late Timer _timer;

  Recorder() {
    _recorder = FlutterSoundRecorder();
    isRecording = false;
  }

  Future<void> startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    _filePath = '$tempPath/test.wav'; // Define your path here
    // await _recorder.openAudioSession();
    await _recorder.startRecorder(toFile: _filePath);
    isRecording = true;
    fileSize = 0;
    time = 0;

//output: /data/user
    _timer = Timer.periodic(Duration(seconds: 15), (timer) async {
      if (isRecording) {
        await _recorder.pauseRecorder();
        _sendAudioToServer();
        await _recorder.resumeRecorder();
      }
    });
  }

  Future<void> updateTime() async {
    time++;
  }

  Future<void> stopRecording() async {
    isRecording = false;
    _timer.cancel();
    await _recorder.stopRecorder();
    File file = File(_filePath);
    try {
      fileSize = await file.length(); // 파일 크기를 바이트 단위로 얻습니다.
      print('File size: $fileSize bytes');
    } catch (e) {
      print('An error occurred while getting the file size: $e');
    }
    // await _recorder.closeAudioSession();
  }

  Future<void> _sendAudioToServer() async {
    // var request = http.MultipartRequest('POST', Uri.parse(_serverUrl));
    // request.files.add(await http.MultipartFile.fromPath('audio', _filePath));
    // var response = await request.send();

    File file = File(_filePath);
    print("$time sec : 파일 전송 완료");
    try {
      fileSize = await file.length(); // 파일 크기를 바이트 단위로 얻습니다.
      print('File size: $fileSize bytes');
    } catch (e) {
      print('An error occurred while getting the file size: $e');
    }
    try {
      int fileSize = await file.length(); // 파일 크기를 바이트 단위로 얻습니다.
      print('File size: $fileSize bytes');
    } catch (e) {
      print('An error occurred while getting the file size: $e');
    }
    // if (response.statusCode == 200) {
    //   print('Successfully sent audio data');
    // } else {
    //   print('Failed to send audio data');
    // }
  }
}
