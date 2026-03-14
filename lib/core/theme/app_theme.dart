import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color _primaryGreen = Color(0xFF10B981);
  static const Color _accentGold = Color(0xFFFFB347);
  static const Color _dangerRed = Color(0xFFFF5252);

  // Dark
  static const Color _darkBg = Color(0xFF0A0E1A);
  static const Color _darkSurface = Color(0xFF131928);
  static const Color _darkCard = Color(0xFF1C2438);
  static const Color _darkBorder = Color(0xFF2A3550);

  // Light
  static const Color _lightBg = Color(0xFFF4F7FE);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFFFFFFF);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _darkBg,
        colorScheme: const ColorScheme.dark(
          primary: _primaryGreen,
          secondary: _accentGold,
          error: _dangerRed,
          surface: _darkSurface,
          onPrimary: Colors.white,
          onSurface: Colors.white,
        ),
        textTheme:
            GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFFB0BEC5),
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF8899AA),
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _primaryGreen,
          ),
        ),
        cardTheme: CardThemeData(
          color: _darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _darkBorder, width: 1),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: _darkBg,
          elevation: 0,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _darkSurface,
          selectedItemColor: _primaryGreen,
          unselectedItemColor: Color(0xFF4A5668),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
          ),
          hintStyle: const TextStyle(color: Color(0xFF4A5668)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        dividerTheme: const DividerThemeData(color: _darkBorder, thickness: 1),
        extensions: [AppColors.dark],
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: _lightBg,
        colorScheme: const ColorScheme.light(
          primary: _primaryGreen,
          secondary: _accentGold,
          error: _dangerRed,
          surface: _lightSurface,
          onPrimary: Colors.white,
          onSurface: Color(0xFF0A0E1A),
        ),
        textTheme:
            GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
          displayLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A0E1A),
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A0E1A),
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0A0E1A),
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF445566),
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF667788),
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _primaryGreen,
          ),
        ),
        cardTheme: CardThemeData(
          color: _lightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: _lightBg,
          elevation: 0,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A0E1A),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF0A0E1A)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _lightSurface,
          selectedItemColor: _primaryGreen,
          unselectedItemColor: Color(0xFFAABBCC),
          type: BottomNavigationBarType.fixed,
          elevation: 2,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _lightCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
          ),
          hintStyle: const TextStyle(color: Color(0xFFAABBCC)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        dividerTheme:
            const DividerThemeData(color: Color(0xFFE2E8F0), thickness: 1),
        extensions: [AppColors.light],
      );
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.gainColor,
    required this.lossColor,
    required this.cardBg,
    required this.borderColor,
    required this.subtleText,
    required this.greenScore,
    required this.yellowScore,
    required this.redScore,
  });

  final Color gainColor;
  final Color lossColor;
  final Color cardBg;
  final Color borderColor;
  final Color subtleText;
  final Color greenScore;
  final Color yellowScore;
  final Color redScore;

  static const AppColors dark = AppColors(
    gainColor: Color(0xFF10B981),
    lossColor: Color(0xFFFF5252),
    cardBg: Color(0xFF1C2438),
    borderColor: Color(0xFF2A3550),
    subtleText: Color(0xFF8899AA),
    greenScore: Color(0xFF10B981),
    yellowScore: Color(0xFFFFB347),
    redScore: Color(0xFFFF5252),
  );

  static const AppColors light = AppColors(
    gainColor: Color(0xFF10B981),
    lossColor: Color(0xFFE53935),
    cardBg: Color(0xFFFFFFFF),
    borderColor: Color(0xFFE2E8F0),
    subtleText: Color(0xFF667788),
    greenScore: Color(0xFF10B981),
    yellowScore: Color(0xFFFF8F00),
    redScore: Color(0xFFE53935),
  );

  @override
  AppColors copyWith({
    Color? gainColor,
    Color? lossColor,
    Color? cardBg,
    Color? borderColor,
    Color? subtleText,
    Color? greenScore,
    Color? yellowScore,
    Color? redScore,
  }) {
    return AppColors(
      gainColor: gainColor ?? this.gainColor,
      lossColor: lossColor ?? this.lossColor,
      cardBg: cardBg ?? this.cardBg,
      borderColor: borderColor ?? this.borderColor,
      subtleText: subtleText ?? this.subtleText,
      greenScore: greenScore ?? this.greenScore,
      yellowScore: yellowScore ?? this.yellowScore,
      redScore: redScore ?? this.redScore,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      gainColor: Color.lerp(gainColor, other.gainColor, t)!,
      lossColor: Color.lerp(lossColor, other.lossColor, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      greenScore: Color.lerp(greenScore, other.greenScore, t)!,
      yellowScore: Color.lerp(yellowScore, other.yellowScore, t)!,
      redScore: Color.lerp(redScore, other.redScore, t)!,
    );
  }
}
