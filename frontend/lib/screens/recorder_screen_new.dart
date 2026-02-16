import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/error_handler.dart';

class RecorderScreenNew extends StatefulWidget {
  const RecorderScreenNew({super.key});

  @override
  State<RecorderScreenNew> createState() => _RecorderScreenNewState();
}

class _RecorderScreenNewState extends State<RecorderScreenNew> with SingleTickerProviderStateMixin {
  late AudioRecorder _audioRecorder;
  bool _isRecording = false;
  String? _audioPath;
  late AnimationController _animationController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        final config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
          bitRate: 64000,
        );

        await _audioRecorder.start(config, path: path);
        setState(() {
          _isRecording = true;
          _audioPath = path;
        });
      } else {
        // 权限被拒绝
        if (mounted) {
          ErrorHandler.showError(
            context: context,
            type: ErrorType.permission,
            onRetry: _startRecording,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorType = ErrorHandler.detectErrorType(e);
        ErrorHandler.showError(
          context: context,
          type: errorType == ErrorType.unknown ? ErrorType.permission : errorType,
          customMessage: '录音启动失败: $e',
          onRetry: _startRecording,
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });

      if (path != null) {
        await _uploadRecording(path);
      }
    } catch (e) {
      if (mounted) {
        final errorType = ErrorHandler.detectErrorType(e);
        ErrorHandler.showError(
          context: context,
          type: errorType,
          customMessage: '录音停止失败: $e',
          onRetry: _stopRecording,
        );
      }
    }
  }

  Future<void> _uploadRecording(String path) async {
    setState(() {
      _isUploading = true;
    });

    try {
      if (!mounted) return;

      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.uploadAudio(path);

      if (mounted) {
        // 显示成功提示
        ErrorHandler.showSuccess(
          context: context,
          message: '上传成功，AI正在处理...',
        );

        // Close modal and notify home screen to refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        final errorType = ErrorHandler.detectErrorType(e);
        final finalErrorType = errorType == ErrorType.unknown ? ErrorType.upload : errorType;

        ErrorHandler.showError(
          context: context,
          type: finalErrorType,
          customMessage: '上传失败: ${e.toString()}',
          onRetry: () => _uploadRecording(path),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFFECFEFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isUploading ? '正在上传...' : (_isRecording ? '正在录制...' : '点击录音'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF164E63),
            ),
          ),
          const SizedBox(height: 32),
          _buildWaveform(),
          const SizedBox(height: 24),
          GlassCard(
            child: SizedBox(
              width: double.infinity,
              child: Text(
                _isUploading ? '正在处理您的语音...' : (_isRecording ? '正在录制您的语音...' : '点击下方按钮开始录音'),
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF164E63).withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Spacer(),
          _buildControls(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(9, (index) {
            final random = Random(index);
            final baseHeight = 0.2 + random.nextDouble() * 0.6;
            final height = _isRecording
                ? baseHeight + sin((_animationController.value * 2 * pi) + index) * 0.2
                : 0.2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 4,
              height: 40 * height,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFF22D3EE),
                    Color(0xFF0891B2),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildControls() {
    if (_isUploading) {
      return const Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0891B2)),
          ),
          SizedBox(height: 16),
          Text(
            '正在上传...',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF164E63),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.mic,
            color: _isRecording ? const Color(0xFF0891B2) : const Color(0xFF164E63),
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: _isRecording ? _stopRecording : _startRecording,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0891B2), Color(0xFF22D3EE)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0891B2).withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_isRecording ? 4 : 12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.close, color: Color(0xFF164E63)),
          ),
        ),
      ],
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0891B2).withOpacity(0.1),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
