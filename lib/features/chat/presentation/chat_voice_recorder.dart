import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class ChatVoiceTake {
  const ChatVoiceTake({required this.path, required this.seconds});

  final String path;
  final int seconds;
}

class ChatVoiceRecorder {
  final _recorder = AudioRecorder();
  Timer? _timer;
  String? _path;
  Duration _duration = Duration.zero;
  void Function(Duration duration)? onTick;

  String? get path => _path;
  Duration get duration => _duration;

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> start() async {
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1),
      path: path,
    );
    _path = path;
    _duration = Duration.zero;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _duration += const Duration(seconds: 1);
      onTick?.call(_duration);
    });
  }

  Future<ChatVoiceTake?> stop() async {
    _timer?.cancel();
    String? path;
    try {
      path = await _recorder.stop();
    } catch (_) {
      path = _path;
    }
    final seconds = _duration.inSeconds;
    _path = null;
    _duration = Duration.zero;
    if (path == null || path.isEmpty || seconds < 1) return null;
    return ChatVoiceTake(path: path, seconds: seconds);
  }

  Future<void> cancel() async {
    _timer?.cancel();
    try {
      await _recorder.stop();
    } catch (_) {}
    final path = _path;
    _path = null;
    _duration = Duration.zero;
    if (path == null) return;
    final file = File(path);
    if (file.existsSync()) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  Future<void> dispose() async {
    _timer?.cancel();
    await _recorder.dispose();
  }
}
