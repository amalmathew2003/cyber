
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cyber_poster.dart';

class PosterTemplate extends StatelessWidget {
  final CyberPoster poster;

  const PosterTemplate({super.key, required this.poster});

  // Helper to get font based on content
  TextStyle _getTextStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    double? height,
  }) {
    // If it contains Malayalam characters, use Noto Sans Malayalam
    bool isMalayalam = poster.title.contains(RegExp(r'[\u0D00-\u0D7F]')) || 
                      poster.description.contains(RegExp(r'[\u0D00-\u0D7F]'));

    if (isMalayalam) {
      return GoogleFonts.notoSansMalayalam(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );
    }
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450, // Fixed width for consistent poster look
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Allow column to grow as tall as needed
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFE31E24), // Warning Red
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.warning_rounded, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(
                  poster.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: _getTextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Description Hook
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF1A1A1A),
            child: Text(
              poster.description,
              textAlign: TextAlign.center,
              style: _getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),

          // Spacing between description and content
          const SizedBox(height: 16),

          // Content Sections
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel("WHAT TO WATCH FOR", const Color(0xFFE31E24)),
                const SizedBox(height: 16),
                ...poster.warningPoints.map((p) => _buildPoint(p, const Color(0xFFE31E24))),
                
                const SizedBox(height: 24),
                _buildSectionLabel("SAFETY RULES", const Color(0xFF00A859)),
                const SizedBox(height: 16),
                ...poster.safetyTips.map((p) => _buildPoint(p, const Color(0xFF00A859))),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Text(
                  poster.footer,
                  textAlign: TextAlign.center,
                  style: _getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: poster.hashtags.map((tag) => Text(
                    tag.startsWith('#') ? tag : '#$tag',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        title,
        style: GoogleFonts.oswald(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: _getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
