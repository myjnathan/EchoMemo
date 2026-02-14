import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  late AudioRecorder _audioRecorder;
  bool _isRecording = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // 配置录音参数，使用 AAC 编码（m4a格式，移动设备原生支持）
        final config = RecordConfig(
          encoder: AudioEncoder.aacLc,  // AAC-LC 编码器（高质量，文件小）
          sampleRate: 16000,            // 采样率 16kHz（语音识别推荐）
          bitRate: 64000,               // 比特率 64kbps（语音质量足够）
        );

        await _audioRecorder.start(config, path: path);
        setState(() {
          _isRecording = true;
          _audioPath = path;
        });
      }
    } catch (e) {
      print("Error starting record: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });
      
      // Auto upload after stop? Or let user review?
      // For "Instant Voice Card", we upload immediately.
      if (path != null) {
        await _uploadRecording(path);
      }
    } catch (e) {
      print("Error stopping record: $e");
    }
  }

  Future<void> _uploadRecording(String path) async {
    try {
      // Show uploading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading...')),
      );

      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.uploadAudio(path);

      if (mounted) {
        Navigator.pop(context); // Close modal on success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tap to Record',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onLongPress: _startRecording,
              onLongPressUp: _stopRecording,
              onTap: () {
                if (_isRecording) {
                  _stopRecording();
                } else {
                  _startRecording();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isRecording ? 100 : 80,
                height: _isRecording ? 100 : 80,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _isRecording ? Colors.red.withOpacity(0.5) : Colors.blue.withOpacity(0.5),
                      spreadRadius: _isRecording ? 10 : 2,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(_isRecording ? 'Recording...' : 'Hold or Tap to Record'),
          ],
        ),
      ),
    );
  }
}
