import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:aitest/main.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:audioplayers/audioplayers.dart' as audio;

class RecordController extends GetxController {
  final audio.AudioPlayer audioPlayer = audio.AudioPlayer();
  final String _serverUrl = "http://$localhost/api/score/";
  final String myPhone = "010-5122-4138";
  late String targetPhone;
  final FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  final Uuid uuid = const Uuid();

  bool _mRecorderIsInited = false;

  bool get recorderIsInited => _mRecorderIsInited;

  RxBool isRecording = false.obs;
  RxInt recordingTime = 0.obs;
  RxInt score = 0.obs;
  String? _pcmFilePath;
  String? _wavFilePath;

  StreamSubscription? _mRecordingDataSubscription;
  final List<Uint8List> audioChunks = [];
  int startChunkIndex = 0;
  bool sending = false;

  Future<void> openRecorder(targetPhone) async {
    this.targetPhone = targetPhone;
    var status = await Permission.microphone.request();
    await _mRecorder.openRecorder();

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.voiceChat,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType:
          AndroidAudioFocusGainType.gainTransientExclusive,
      androidWillPauseWhenDucked: true,
    ));
    await createFile();
    _mRecorderIsInited = true;

    startRecord();
  }

  Future createFile() async {
    var tempDir = await getTemporaryDirectory();
    String fileName = uuid.v4();
    _pcmFilePath = '${tempDir.path}/${fileName}.pcm';
    _wavFilePath = '${tempDir.path}/${fileName}.wav';
  }

  Future<void> startRecord() async {
    assert(_mRecorderIsInited);

    var recordingDataController = StreamController<Food>();
    _mRecordingDataSubscription =
        recordingDataController.stream.listen((buffer) async {
      if (buffer is FoodData) {
        // sink.add(buffer.data!);
        audioChunks.add(Uint8List.fromList(buffer.data!));
      }
    });

    try {
      await _mRecorder.startRecorder(
        // toFile: _mPath,
        toStream: recordingDataController.sink,
        codec: Codec.pcm16,
        numChannels: 1,
        sampleRate: 16000,
      );

      isRecording = _mRecorder.isRecording.obs;
      _updateRecordTime();
    } catch (error) {
      print(error);
      Fluttertoast.showToast(msg: "설정에서 마이크를 허용해주세요.");
    }
  }

  Future<void> _updateRecordTime() async {
    while (isRecording.isTrue) {
      await Future.delayed(const Duration(seconds: 1));
      recordingTime++;

      // 15 초마다 요청
      if (recordingTime % 3 == 0 && sending == false) {
        writeChunksToFile(_pcmFilePath!).then((lastIndex) async {
          if (lastIndex > 0) {
            bool completedConverted =
                await convertPcmToWav(_pcmFilePath!, _wavFilePath!, 16000);

            if (completedConverted) {
              print("15초 wav 파일로 저장 완료");
              bool status = await _sendFile(_wavFilePath!);
              if (status) {
                startChunkIndex = lastIndex + 1;
              }
            }
          }
        });
      }
    }
  }

  void playAlertSound(int score) async {
    if (score < 50) return;
    late String alertSoundPath;
    if (score >= 70) {
      alertSoundPath = 'level2.mp3';
    } else {
      alertSoundPath = 'level1.mp3';
    }

    await audioPlayer.play(audio.AssetSource(alertSoundPath));

    debugPrint("Alert sound played successfully.");
  }

  Future<int> writeChunksToFile(String filePath) async {
    List<Uint8List> chunks = [];
    int lastIndex = audioChunks.length - 1;

    for (int i = startChunkIndex; i < lastIndex + 1; i++) {
      chunks.add(audioChunks[i]);
    }

    var totalLength = chunks.fold(0, (length, chunk) => length + chunk.length);
    var mergedBytes = Uint8List(totalLength);
    var offset = 0;
    for (var chunk in chunks) {
      mergedBytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    var file = File(filePath);
    await file.writeAsBytes(mergedBytes);
    return lastIndex;
  }

  Future<bool> _sendFile(String path) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_serverUrl));
      request.fields["my_phone"] = myPhone;
      request.fields["target_phone"] = targetPhone;
      request.files.add(await http.MultipartFile.fromPath('file', path));
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        String json = await response.stream.bytesToString();
        int score = jsonDecode(json)["score"];
        print("보이스피싱 결과 수신: $score");
        this.score = score.obs;
        playAlertSound(score);
        return true;
      }
    } catch (error) {
      print(error);
    }
    return false;
  }

  Future<void> closeRecorder() async {
    await _mRecorder.stopRecorder();
    if (_mRecordingDataSubscription != null) {
      await _mRecordingDataSubscription!.cancel();
      _mRecordingDataSubscription = null;
    }
    isRecording = false.obs;
    sending = false;
    recordingTime = 0.obs;
    score = 0.obs;
    startChunkIndex = 0;
    audioChunks.clear();
    _mRecorderIsInited = false;
    _mRecorder.closeRecorder();
    var pcmFile = File(_pcmFilePath!);
    var wavFile = File(_wavFilePath!);
    _pcmFilePath = null;
    _wavFilePath = null;
    if (pcmFile.existsSync()) {
      await pcmFile.delete();
    }
    if (wavFile.existsSync()) {
      await wavFile.delete();
    }
  }

  Future<bool> convertPcmToWav(
      String pcmPath, String wavPath, int sampleRate) async {
    final pcmFile = File(pcmPath);
    final pcmData = await pcmFile.readAsBytes();

    final fileSize = pcmData.length + 36;
    final dataSize = pcmData.length;

    final wavHeader = ByteData(44)
      ..setUint32(0, 0x46464952, Endian.little) // "RIFF"
      ..setUint32(4, fileSize, Endian.little)
      ..setUint32(8, 0x45564157, Endian.little) // "WAVE"
      ..setUint32(12, 0x20746D66, Endian.little) // "fmt "
      ..setUint32(16, 16, Endian.little) // Subchunk1Size
      ..setUint16(20, 1, Endian.little) // AudioFormat
      ..setUint16(22, 1, Endian.little) // NumChannels (Mono)
      ..setUint32(24, sampleRate, Endian.little) // SampleRate
      ..setUint32(28, sampleRate * 2, Endian.little) // ByteRate
      ..setUint16(32, 2, Endian.little) // BlockAlign
      ..setUint16(34, 16, Endian.little) // BitsPerSample
      ..setUint32(36, 0x61746164, Endian.little) // "data"
      ..setUint32(40, dataSize, Endian.little);

    final wavData =
        Uint8List.fromList([...wavHeader.buffer.asUint8List(), ...pcmData]);

    final wavFile = File(wavPath);
    await wavFile.writeAsBytes(wavData);
    return true;
  }

  Future<void> _printFileSize(String path) async {
    final fileBytes = await File(path).readAsBytes();
    print(fileBytes.lengthInBytes);
  }
}
