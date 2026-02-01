import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Sistem UI ayarları (status bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const LightPollutionApp());
}

class LightPollutionApp extends StatelessWidget {
  const LightPollutionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Işık Kirliliği',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'SF Pro Display', // iOS tarzı font
        
        // AppBar teması
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple[700],
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        // Elevated Button teması
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shadowColor: Colors.deepPurple.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        
        // Text Field teması
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple[700]!, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey[700]),
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
        
        // Card teması
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        
        // Divider teması
        dividerTheme: DividerThemeData(
          color: Colors.grey[200],
          thickness: 1,
          space: 24,
        ),
        
        // Icon teması
        iconTheme: IconThemeData(
          color: Colors.deepPurple[700],
        ),
        
        // Text teması
        textTheme: TextTheme(
          displayLarge: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Colors.grey[800],
          ),
          bodyMedium: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        
        colorScheme: ColorScheme.light(
          primary: Colors.deepPurple[700]!,
          secondary: Colors.deepPurple[400]!,
          surface: Colors.white,
          background: Colors.grey[50]!,
          error: Colors.red[700]!,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}