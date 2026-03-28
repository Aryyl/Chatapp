import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceProUpsell extends StatelessWidget {
  const VoiceProUpsell({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1D1D1F), // Deep dark / charcoal black
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(
        24,
      ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0x26A28F79), // 15% opacity of A28F79
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic,
              color: Color(0xFFA28F79), // Gold/Beige accent
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Voice Pro',
            style: GoogleFonts.newsreader(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Unlock natural voice conversations, emotion detection, and real-time translation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
              height: 1.5,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 48),
          _buildFeatureRow(Icons.graphic_eq, 'Natural human-like voices'),
          const SizedBox(height: 20),
          _buildFeatureRow(
            Icons.language,
            'Real-time multi-language translation',
          ),
          const SizedBox(height: 20),
          _buildFeatureRow(Icons.all_inclusive, 'Unlimited voice messages'),
          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA28F79),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Upgrade for \$9.99/mo',
                style: GoogleFonts.newsreader(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.white54),
            child: const Text(
              'Maybe later',
              style: TextStyle(fontSize: 16, fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFA28F79), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}
