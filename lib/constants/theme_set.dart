import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainThemeSet {
  static Color primaryColor = Colors.blueGrey.shade900;
  static TextStyle mainFont = GoogleFonts.lato(color: Colors.white, fontSize: 24);
  static TextStyle secondaryFont =
      GoogleFonts.roboto(fontSize: 16, color: Colors.white);
  static BorderRadiusGeometry mainBorderRadius = BorderRadius.circular(8);
  static EdgeInsetsGeometry verticalPadding = EdgeInsets.symmetric(vertical: 8);
  static Color focusColor = Color.fromARGB(255, 0, 106, 103);
}

class DialogThemeSet {
  static TextStyle mainFont =
      GoogleFonts.lato(color: Colors.white, fontSize: 16);
  static TextStyle titleFont = GoogleFonts.montserrat(color: Colors.white);
  static TextStyle dropDownFont = GoogleFonts.roboto(color: Colors.white);
}