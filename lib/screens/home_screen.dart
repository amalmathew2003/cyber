import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

// Conditional imports
import '../services/web_download_stub.dart'
    if (dart.library.html) '../services/web_download_web.dart'
    as web_helper;

import '../models/cyber_poster.dart';
import '../services/api_service.dart';
import '../widgets/poster_template.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _topicController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();

  CyberPoster? _generatedPoster;
  bool _isLoading = false;
  String? _error;
  String _selectedLanguage = "English";

  String? get _apiKey => dotenv.env['GROQ_API_KEY'];

  Future<void> _generatePoster() async {
    if (_topicController.text.isEmpty) return;
    if (_apiKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("API Key not found in .env file!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final poster = await ApiService.generatePosterContent(
        _topicController.text,
        _apiKey!,
        _selectedLanguage,
      );
      setState(() {
        _generatedPoster = poster;
        _isLoading = false;
      });
    } catch (e) {
      //
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndShare() async {
    if (_generatedPoster == null) return;

    final image = await _screenshotController.captureFromWidget(
      PosterTemplate(poster: _generatedPoster!),
    );

    if (kIsWeb) {
      web_helper.downloadWebImage(image, "cyber_poster.png");
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File(
        '${directory.path}/cyber_poster.png',
      ).create();
      await imagePath.writeAsBytes(image);

      await ImageGallerySaverPlus.saveImage(image);
      final caption = _generateCaption();
      await Share.shareXFiles([XFile(imagePath.path)], text: caption);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving image: $e")));
    }
  }

  Future<void> _shareTextOnly() async {
    if (_generatedPoster == null) return;
    await Share.share(_generateCaption());
  }

  String _generateCaption() {
    if (_generatedPoster == null) return "";
    final p = _generatedPoster!;

    return '''${p.title}

${p.description}

${p.warningPoints.join('\n')}

${p.safetyTips.join('\n')}

${p.footer}

${p.hashtags.join(' ')}
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      appBar: AppBar(
        title: Text(
          "CYBER DEFENDER",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputCard(),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: SpinKitDoubleBounce(
                      color: Colors.redAccent,
                      size: 50.0,
                    ),
                  ),
                )
              else if (_error != null)
                _buildErrorState()
              else if (_generatedPoster != null)
                _buildResultState()
              else
                _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SELECT LANGUAGE",
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: "English", label: Text("English")),
              ButtonSegment(value: "Malayalam", label: Text("Malayalam")),
            ],
            selected: {_selectedLanguage},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedLanguage = newSelection.first;
              });
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              selectedBackgroundColor: Colors.redAccent,
              selectedForegroundColor: Colors.white,
              foregroundColor: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "TOPIC",
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _topicController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "e.g. LinkedIn Job Scam",
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              prefixIcon: const Icon(Icons.security, color: Colors.redAccent),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _generatePoster(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _generatePoster,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "GENERATE POSTER",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState() {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              child: Screenshot(
                controller: _screenshotController,
                child: PosterTemplate(poster: _generatedPoster!),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Column(
          children: [
            ElevatedButton.icon(
              onPressed: _saveAndShare,
              icon: const Icon(Icons.download),
              label: Text(kIsWeb ? "DOWNLOAD POSTER" : "SHARE IMAGE + TEXT"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _shareTextOnly,
              icon: const Icon(Icons.copy_rounded),
              label: const Text("SHARE TEXT CAPTION ONLY"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            "Generation Failed",
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.shield_moon_outlined,
              color: Colors.white.withValues(alpha: 0.1),
              size: 100,
            ),
            const SizedBox(height: 16),
            Text(
              "Ready to defend?",
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
