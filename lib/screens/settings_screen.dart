import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../services/gemini_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  bool _obscureKey = true;
  bool _isSaving = false;
  bool _isTesting = false;
  String _statusMessage = '';
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('gemini_api_key') ?? '';
    setState(() {
      _apiKeyController.text = key;
    });
  }

  Future<void> _saveApiKey() async {
    setState(() {
      _isSaving = true;
      _statusMessage = '';
    });

    await _geminiService.saveApiKey(_apiKeyController.text.trim());

    setState(() {
      _isSaving = false;
      _statusMessage = 'Gemini API key berhasil disimpan!';
      _statusIsError = false;
    });
  }

  Future<void> _testApiKey() async {
    if (_apiKeyController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = 'Silakan masukkan API key terlebih dahulu.';
        _statusIsError = true;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _statusMessage = 'Menghubungkan ke Gemini AI...';
      _statusIsError = false;
    });

    await _geminiService.saveApiKey(_apiKeyController.text.trim());

    try {
      final response = await _geminiService.askQuestion(
        'Sapa saya dengan "Om Swastyastu" dan jelaskan makna Taksu Bali dalam 1 kalimat pendek.',
        [],
      );
      setState(() {
        _isTesting = false;
        _statusMessage = 'Berhasil terhubung!\nRespon AI: $response';
        _statusIsError = false;
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _statusMessage =
            'Kendala koneksi: ${e.toString().replaceFirst('Exception: ', '')}';
        _statusIsError = true;
      });
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.primaryColor,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PENGATURAN TAKSU AR',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildSectionHeader('Konfigurasi Gemini AI'),
            const SizedBox(height: 14),
            _buildInfoCard(),
            const SizedBox(height: 18),
            _buildApiKeyField(),
            const SizedBox(height: 18),
            _buildActionButtons(),
            if (_statusMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildStatusMessage(),
            ],
            const SizedBox(height: 30),
            _buildSectionHeader('Informasi Aplikasi'),
            const SizedBox(height: 14),
            _buildInfoTile(
              Icons.theater_comedy,
              'Tema Aplikasi',
              'AR Topeng Tradisional Bali (Barong, Rangda, Sidhakarya, Dalem)',
            ),
            _buildInfoTile(
              Icons.view_in_ar,
              'Model 3D',
              'Slot file 3D (.glb) siap di assets/models/',
            ),
            _buildInfoTile(
              Icons.psychology,
              'AI Model',
              'Google Gemini 2.0 Flash (Kurator Budaya Bali)',
            ),
            _buildInfoTile(
              Icons.mic,
              'Input Suara',
              'Speech-to-Text Bahasa Indonesia & Bali',
            ),
            _buildInfoTile(
              Icons.volume_up,
              'Output Suara',
              'Text-to-Speech (Membacakan filosofi)',
            ),
            const SizedBox(height: 30),
            _buildSectionHeader('Cara Mendapatkan Gemini API Key'),
            const SizedBox(height: 12),
            _buildStepCard(
              '1',
              'Kunjungi Google AI Studio',
              'Buka website aistudio.google.com melalui browser',
            ),
            const SizedBox(height: 8),
            _buildStepCard(
              '2',
              'Buat API Key Gratis',
              'Login akun Google, klik "Get API Key" lalu Create Key',
            ),
            const SizedBox(height: 8),
            _buildStepCard(
              '3',
              'Tempelkan Key ke Kolom',
              'Salin kunci dan paste pada kolom di atas, lalu klik SIMPAN',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Masukkan Gemini API Key untuk respon AI tanpa batas seputar budaya Bali. Kunci disimpan aman secara lokal di perangkat Anda.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GEMINI API KEY',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.35),
            ),
            color: AppTheme.surfaceColor,
          ),
          child: TextField(
            controller: _apiKeyController,
            obscureText: _obscureKey,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 1,
            ),
            decoration: InputDecoration(
              hintText: 'AIzaSy...',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureKey ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white38,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveApiKey,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.black,
                      ),
                    ),
                  )
                : const Text(
                    'SIMPAN KEY',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _isTesting ? null : _testApiKey,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isTesting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  )
                : const Text(
                    'UJI KONEKSI',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: _statusIsError
            ? AppTheme.errorColor.withValues(alpha: 0.12)
            : AppTheme.primaryColor.withValues(alpha: 0.1),
        border: Border.all(
          color: _statusIsError
              ? AppTheme.errorColor.withValues(alpha: 0.5)
              : AppTheme.primaryColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _statusIsError ? Icons.error_outline : Icons.check_circle_outline,
            color: _statusIsError ? AppTheme.errorColor : AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _statusIsError
                    ? AppTheme.errorColor
                    : AppTheme.primaryColor,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppTheme.surfaceColor,
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(String step, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppTheme.surfaceColor,
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              border: Border.all(color: AppTheme.primaryColor, width: 1.2),
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
