import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_constants.dart';
import 'screens/main_navigation.dart';
import 'screens/onboarding_screen.dart';
import 'providers/navigation_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MemoryFlowApp());
}

/// Service locator for lazy-loaded services
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  NotificationService? _notificationService;
  DatabaseService? _databaseService;
  bool _isInitialized = false;

  /// Check if services are initialized
  bool get isInitialized => _isInitialized;

  /// Get notification service (lazy loaded)
  NotificationService get notificationService {
    _notificationService ??= NotificationService();
    return _notificationService!;
  }

  /// Get database service (lazy loaded)
  DatabaseService get databaseService {
    _databaseService ??= DatabaseService();
    return _databaseService!;
  }

  /// Initialize all services asynchronously
  Future<void> initialize() async {
    if (_isInitialized) return;

    final stopwatch = Stopwatch()..start();

    // Initialize services in parallel where possible
    await Future.wait([
      _initNotifications(),
      _initDatabase(),
    ]);

    _isInitialized = true;
    stopwatch.stop();
    print('Services initialized in ${stopwatch.elapsedMilliseconds}ms');
  }

  Future<void> _initNotifications() async {
    await notificationService.initialize();
    await notificationService.requestPermissions();
  }

  Future<void> _initDatabase() async {
    // Pre-warm database connection
    await databaseService.database;
  }
}

class MemoryFlowApp extends StatefulWidget {
  const MemoryFlowApp({super.key});

  @override
  State<MemoryFlowApp> createState() => _MemoryFlowAppState();
}

class _MemoryFlowAppState extends State<MemoryFlowApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider.value(value: _themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(themeProvider.colorScheme),
            darkTheme: _buildDarkTheme(themeProvider.colorScheme),
            themeMode: themeProvider.themeMode,
            builder: (context, child) {
              // Apply text scale factor based on font size setting
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: themeProvider.textScaleFactor,
                ),
                child: child!,
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

/// Splash screen with async initialization
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String _statusMessage = 'Loading...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final stopwatch = Stopwatch()..start();

    try {
      setState(() => _statusMessage = 'Initializing services...');

      // Initialize services
      await ServiceLocator().initialize();

      setState(() => _statusMessage = 'Loading topics...');

      // Pre-load first page of topics for faster home screen
      // This runs in background while splash shows

      stopwatch.stop();
      print('App initialized in ${stopwatch.elapsedMilliseconds}ms');

      // Minimum splash display time for branding
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 1000) {
        await Future.delayed(Duration(milliseconds: 1000 - elapsed));
      }

      // Check if onboarding is complete
      final onboardingComplete = await isOnboardingComplete();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                onboardingComplete
                    ? const MainNavigation()
                    : const OnboardingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _statusMessage = 'Failed to initialize: $e';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // App Name
                Text(
                  AppConfig.appName,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Spaced Repetition Learning',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 48),

                // Loading indicator or error
                if (_hasError)
                  Column(
                    children: [
                      Icon(Icons.error_outline,
                          color: AppColors.danger, size: 32),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _statusMessage = 'Retrying...';
                          });
                          _initializeApp();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Theme builder functions
ThemeData _buildLightTheme(AppColorScheme colorScheme) {
  final schemeData = AppColorSchemes.getScheme(colorScheme);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: schemeData.primary,
      secondary: schemeData.secondary,
      surface: schemeData.surface,
      error: AppColors.danger,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimaryLight,
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: schemeData.background,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: schemeData.background,
      foregroundColor: AppColors.textPrimaryLight,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimaryLight,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      color: AppColors.white,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: schemeData.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: schemeData.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: schemeData.primary,
        side: BorderSide(color: schemeData.primary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.gray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        borderSide: const BorderSide(color: AppColors.gray300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        borderSide: const BorderSide(color: AppColors.gray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        borderSide: BorderSide(color: schemeData.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
    ),

    // FloatingActionButton Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: schemeData.primary,
      foregroundColor: AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
      ),
    ),

    // BottomNavigationBar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: schemeData.primary,
      unselectedItemColor: AppColors.gray400,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: AppTextStyles.labelSmall,
      unselectedLabelStyle: AppTextStyles.labelSmall,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      displaySmall: AppTextStyles.displaySmall.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      titleMedium: AppTextStyles.titleMedium.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      titleSmall: AppTextStyles.titleSmall.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondaryLight,
      ),
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.textPrimaryLight,
      size: 24,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.gray200,
      thickness: 1,
      space: 1,
    ),
  );
}

/// Build dark theme configuration
ThemeData _buildDarkTheme(AppColorScheme colorScheme) {
  final schemeData = AppColorSchemes.getScheme(colorScheme);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: schemeData.primary,
      secondary: schemeData.secondary,
      surface: AppColors.surfaceDark,
      error: AppColors.danger,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimaryDark,
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textPrimaryDark,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      color: AppColors.surfaceDark,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: schemeData.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: schemeData.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: schemeData.primary,
        side: BorderSide(color: schemeData.primary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.gray800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        borderSide: const BorderSide(color: AppColors.gray600),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        borderSide: const BorderSide(color: AppColors.gray600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        borderSide: BorderSide(color: schemeData.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
    ),

    // FloatingActionButton Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: schemeData.primary,
      foregroundColor: AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
      ),
    ),

    // BottomNavigationBar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: schemeData.primary,
      unselectedItemColor: AppColors.gray400,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: AppTextStyles.labelSmall,
      unselectedLabelStyle: AppTextStyles.labelSmall,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      displaySmall: AppTextStyles.displaySmall.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      titleMedium: AppTextStyles.titleMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      titleSmall: AppTextStyles.titleSmall.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.textPrimaryDark,
      size: 24,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.gray700,
      thickness: 1,
      space: 1,
    ),
  );
}
