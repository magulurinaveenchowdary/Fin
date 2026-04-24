import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get display => GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.bold,
      );

  static TextStyle get body => GoogleFonts.dmSans();

  static TextStyle h1 = display.copyWith(fontSize: 32);
  static TextStyle h2 = display.copyWith(fontSize: 24);
  static TextStyle h3 = display.copyWith(fontSize: 20);
  
  static TextStyle bodyLarge = body.copyWith(fontSize: 18);
  static TextStyle bodyMedium = body.copyWith(fontSize: 16);
  static TextStyle bodySmall = body.copyWith(fontSize: 14);
  
  static TextStyle label = display.copyWith(fontSize: 12, fontWeight: FontWeight.w500);
}
