import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/app_theme.dart';
import '../models/balinese_mask.dart';
import '../services/gemini_service.dart';
import '../services/speech_service.dart';
import '../widgets/ar_overlay_widget.dart';
import '../widgets/chat_bubble_widget.dart';

enum ARState { scanning, detected, listening, thinking, responding }

class ARScreen extends StatefulWidget {
  final BalineseMask? initialMask;

  const ARScreen({super.key, this.initialMask});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> with TickerProviderStateMixin {
  ARState _arState = ARState.scanning;

  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  late Animation<double> _scanLineAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  CameraController? _cameraController;
  bool _isCameraReady = false;

  final GeminiService _geminiService = GeminiService();
  final SpeechService _speechService = SpeechService();

  late BalineseMask _currentMask;
  final List<BalineseMask> _availableMasks = BalineseMask.sampleMasks;

  String _userQuestion = '';
  String _aiResponse = '';
  bool _isListening = false;
  // ignore: unused_field
  bool _hasPermissions = false;

  // Interactive 3D Model rotation angle
  double _modelRotationY = 0.0;
  double _modelRotationX = 0.0;

  Timer? _detectionTimer;
  final List<Map<String, String>> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _currentMask = widget.initialMask ?? _availableMasks.first;
    _initAnimations();
    _initCameraAndPermissions();
    _simulateARDetection();
  }

  void _initAnimations() {
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _scanLineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotateController);
  }

  Future<void> _initCameraAndPermissions() async {
    try {
      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      setState(() {
        _hasPermissions = cameraStatus.isGranted && micStatus.isGranted;
      });

      if (cameraStatus.isGranted) {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          _cameraController = CameraController(
            cameras.first,
            ResolutionPreset.medium,
            enableAudio: false,
          );
          await _cameraController!.initialize();
          if (mounted) {
            setState(() {
              _isCameraReady = true;
            });
          }
        }
      }
    } catch (_) {
      _isCameraReady = false;
    }
  }

  void _simulateARDetection() {
    _detectionTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _arState = ARState.detected);
      }
    });
  }

  Future<void> _startListening() async {
    if (_arState != ARState.detected && _arState != ARState.responding) return;

    setState(() {
      _arState = ARState.listening;
      _isListening = true;
      _userQuestion = '';
    });

    await _speechService.startListening(
      (text) {
        setState(() => _userQuestion = text);
      },
      onDone: () {
        _stopListeningAndQuery();
      },
    );
  }

  Future<void> _sendDirectQuery(String question) async {
    setState(() {
      _userQuestion = question;
      _arState = ARState.thinking;
      _isListening = false;
    });

    _chatHistory.add({'role': 'user', 'text': question});

    try {
      final response = await _geminiService.askQuestion(
        question,
        _chatHistory,
        activeMask: _currentMask,
      );
      if (!mounted) return;
      setState(() {
        _aiResponse = response;
        _arState = ARState.responding;
        _chatHistory.add({'role': 'ai', 'text': response});
      });
      await _speechService.speak(response);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiResponse = 'Terjadi kendala saat menghubungkan ke AI: $e';
        _arState = ARState.responding;
      });
    }
  }

  Future<void> _stopListeningAndQuery() async {
    await _speechService.stopListening();
    setState(() {
      _isListening = false;
      _arState = ARState.thinking;
    });

    if (_userQuestion.trim().isEmpty) {
      setState(() => _arState = ARState.detected);
      return;
    }

    _chatHistory.add({'role': 'user', 'text': _userQuestion});

    try {
      final response = await _geminiService.askQuestion(
        _userQuestion,
        _chatHistory,
        activeMask: _currentMask,
      );
      if (!mounted) return;
      setState(() {
        _aiResponse = response;
        _arState = ARState.responding;
        _chatHistory.add({'role': 'ai', 'text': response});
      });
      await _speechService.speak(response);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiResponse =
            'Maaf, tidak dapat terhubung ke AI. Pastikan Gemini API Key sudah tersimpan di Pengaturan.';
        _arState = ARState.responding;
      });
    }

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _arState == ARState.responding) {
        setState(() => _arState = ARState.detected);
      }
    });
  }

  void _switchMask(BalineseMask newMask) {
    setState(() {
      _currentMask = newMask;
      _arState = ARState.detected;
      _aiResponse = '';
      _userQuestion = '';
    });
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _detectionTimer?.cancel();
    _speechService.stopSpeaking();
    _speechService.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Kamera aktif HANYA saat scanning, setelah detected → matikan kamera
          // untuk hemat baterai & performa
          if (_arState == ARState.scanning)
            _isCameraReady && _cameraController != null
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _cameraController!.value.previewSize?.height ?? 1,
                        height: _cameraController!.value.previewSize?.width ?? 1,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  )
                : _buildBalineseDummyCameraView()
          else
            // Background Balinese gelap saat model sudah terdeteksi
            _buildDetectedBackground(),

          // Interactive touch gesture for rotating the 3D Balinese Mask (only for fallback 2D)
          if (_arState == ARState.scanning || !_currentMask.hasModel3D)
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _modelRotationY += details.delta.dx * 0.01;
                  _modelRotationX -= details.delta.dy * 0.01;
                });
              },
              onDoubleTap: () {
                setState(() {
                  _modelRotationY = 0.0;
                  _modelRotationX = 0.0;
                });
              },
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // AR Overlay (HUD + Balinese Mandala Reticle)
          AROverlayWidget(
            arState: _arState,
            scanLineAnimation: _scanLineAnimation,
            pulseAnimation: _pulseAnimation,
            rotateAnimation: _rotateAnimation,
            userRotationX: _modelRotationX,
            userRotationY: _modelRotationY,
            mask: _currentMask,
          ),

          // Top Bar with Mask Selector
          _buildTopBar(),

          // Bottom Controls (Voice Mic + Cultural Preset Chips)
          _buildBottomControls(),

          // State Indicator (Scanning)
          _buildStateIndicator(),

          // Chat Bubble for AI Response
          if (_arState == ARState.responding || _arState == ARState.thinking)
            _buildResponseOverlay(),

          // User Voice Question Overlay
          if (_arState == ARState.listening ||
              (_arState == ARState.thinking && _userQuestion.isNotEmpty))
            _buildUserQuestionOverlay(),
        ],
      ),
    );
  }

  Widget _buildBalineseDummyCameraView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0D0F14),
      child: CustomPaint(painter: BalineseARGridPainter()),
    );
  }

  /// Background gelap bergradient saat topeng sudah terdeteksi (kamera OFF)
  Widget _buildDetectedBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.15),
          radius: 1.1,
          colors: [
            Color(0xFF1A1500), // tengah — hangat gelap keemasan
            Color(0xFF0D0F14), // pinggir — gelap total
          ],
        ),
      ),
      child: CustomPaint(painter: BalineseARGridPainter()),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎭 ', style: TextStyle(fontSize: 13)),
                  Text(
                    _currentMask.name.replaceAll('Topeng ', '').toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Mask Picker Menu
            PopupMenuButton<BalineseMask>(
              color: AppTheme.surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              onSelected: _switchMask,
              itemBuilder: (context) {
                return _availableMasks.map((mask) {
                  return PopupMenuItem<BalineseMask>(
                    value: mask,
                    child: Row(
                      children: [
                        Text(
                          mask.id == _currentMask.id ? '✓ ' : '   ',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          mask.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.swap_horiz,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cultural Prompt Chips
              if (_arState == ARState.detected ||
                  _arState == ARState.responding)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _currentMask.commonQuestions.map((q) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8, bottom: 12),
                        child: ActionChip(
                          backgroundColor: AppTheme.surfaceColor,
                          side: BorderSide(
                            color: AppTheme.primaryColor.withValues(alpha: 0.35),
                          ),
                          label: Text(
                            q,
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () => _sendDirectQuery(q),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Chat history badge
              if (_chatHistory.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: _showChatHistory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: AppTheme.primaryColor,
                            size: 13,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_chatHistory.length ~/ 2} dialog budaya',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Mic Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Stop Button if listening
                  if (_arState == ARState.listening)
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: GestureDetector(
                        onTap: _stopListeningAndQuery,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.errorColor.withValues(alpha: 0.15),
                            border: Border.all(
                              color: AppTheme.errorColor,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.stop,
                            color: AppTheme.errorColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                  // Main Microphone Button (Solid Clean Yellow)
                  GestureDetector(
                    onTap: _arState == ARState.listening
                        ? _stopListeningAndQuery
                        : (_arState == ARState.detected ||
                                _arState == ARState.responding)
                            ? _startListening
                            : null,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        final isActive =
                            _arState == ARState.listening || _isListening;
                        return Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? AppTheme.errorColor
                                : _arState == ARState.detected ||
                                        _arState == ARState.responding
                                    ? AppTheme.primaryColor
                                    : AppTheme.surfaceElevated,
                            border: Border.all(
                              color: isActive
                                  ? AppTheme.errorColor
                                  : AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isActive ? Icons.mic : Icons.mic_none,
                            color: isActive
                                ? Colors.white
                                : _arState == ARState.detected ||
                                        _arState == ARState.responding
                                    ? Colors.black
                                    : Colors.white38,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getMicHint(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateIndicator() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.12,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _arState == ARState.scanning
              ? _buildScanningIndicator()
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return Container(
      key: const ValueKey('scanning'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Mencari target ${_currentMask.name}...',
            style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseOverlay() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.14,
      left: 18,
      right: 18,
      child: ChatBubbleWidget(
        isThinking: _arState == ARState.thinking,
        message: _aiResponse,
        userQuestion: _userQuestion,
      ),
    );
  }

  Widget _buildUserQuestionOverlay() {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.26,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.record_voice_over,
              color: AppTheme.primaryColor,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _userQuestion.isEmpty ? 'Mendengarkan suara Anda...' : _userQuestion,
                style: TextStyle(
                  color: _userQuestion.isEmpty
                      ? Colors.white38
                      : Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  fontStyle: _userQuestion.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMicHint() {
    switch (_arState) {
      case ARState.scanning:
        return 'Arahkan kamera ke target atau permukaan datar...';
      case ARState.detected:
        return 'Ketuk mic untuk bertanya ke Taksu AR';
      case ARState.listening:
        return 'Ketuk lagi setelah selesai berbicara';
      case ARState.thinking:
        return 'Taksu AR sedang memproses filosofi...';
      case ARState.responding:
        return 'Ketuk mic untuk pertanyaan berikutnya';
    }
  }

  void _showChatHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildChatHistorySheet(),
    );
  }

  Widget _buildChatHistorySheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Dialog Budaya',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white54, size: 18),
              ),
            ],
          ),
          const Divider(color: Colors.white12),
          Expanded(
            child: ListView.separated(
              itemCount: _chatHistory.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _chatHistory[index];
                final isUser = item['role'] == 'user';
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: isUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!isUser) ...[
                      const Text('🎭 ', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppTheme.primaryColor.withValues(alpha: 0.15)
                              : AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUser
                                ? AppTheme.primaryColor.withValues(alpha: 0.35)
                                : Colors.white10,
                          ),
                        ),
                        child: Text(
                          item['text'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                    if (isUser) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                        size: 18,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BalineseARGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
