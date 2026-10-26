import 'package:flutter/material.dart';

/// Paleta cálida de la cafetería: crema, espresso y terracota.
abstract final class AppColors {
  static const crema = Color(0xFFFBF6F0);
  static const superficie = Color(0xFFFFFFFF);
  static const borde = Color(0xFFEDE3DA);
  static const espresso = Color(0xFF4E342E);
  static const espressoSuave = Color(0xFF6D4C41);
  static const terracota = Color(0xFFBF5B3D);
  static const terracotaSuave = Color(0xFFF7E7DF);
  static const texto = Color(0xFF2E2622);
  static const textoSuave = Color(0xFF7A6E67);
  static const agotado = Color(0xFF9E938C);
  static const agotadoSuave = Color(0xFFF0EBE7);
  static const verde = Color(0xFF3F7D58);
  static const verdeSuave = Color(0xFFE6F1E9);
  static const error = Color(0xFFB3261E);
}

/// Espaciados base (múltiplos de 4).
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

/// Radios de esquina: nada de cajas cuadradas estilo Material.
abstract final class AppRadii {
  static const sm = 12.0;
  static const md = 18.0;
  static const lg = 22.0;
  static const xl = 28.0;
}

/// Tema visual propio sobre Material: misma librería, otra cara.
abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.espresso,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.espresso,
          onPrimary: Colors.white,
          primaryContainer: AppColors.terracotaSuave,
          onPrimaryContainer: AppColors.espresso,
          secondary: AppColors.terracota,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.terracotaSuave,
          onSecondaryContainer: AppColors.espresso,
          surface: AppColors.superficie,
          onSurface: AppColors.texto,
          surfaceContainerHighest: AppColors.crema,
          outline: AppColors.borde,
          outlineVariant: AppColors.borde,
          error: AppColors.error,
        );

    final texto = Typography.material2021().black;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.crema,
      // Sin ripple: la app no se siente como un formulario de Android.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      visualDensity: VisualDensity.standard,
      textTheme: texto.copyWith(
        headlineSmall: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: AppColors.texto,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: AppColors.texto,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.texto,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14.5,
          height: 1.45,
          color: AppColors.texto,
        ),
        bodySmall: const TextStyle(fontSize: 13, color: AppColors.textoSuave),
        labelLarge: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.crema,
        foregroundColor: AppColors.texto,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.superficie,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: AppColors.borde),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(AppColors.espresso),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          ),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          overlayColor: const WidgetStatePropertyAll(Color(0x1A000000)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(AppColors.espresso),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.borde),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          ),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.espressoSuave,
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.superficie,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 18,
        ),
        labelStyle: const TextStyle(color: AppColors.textoSuave),
        floatingLabelStyle: const TextStyle(color: AppColors.espresso),
        hintStyle: const TextStyle(color: AppColors.agotado),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.espresso, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.espresso,
        foregroundColor: Colors.white,
        elevation: 3,
        focusElevation: 3,
        hoverElevation: 3,
        highlightElevation: 5,
        shape: StadiumBorder(),
        extendedTextStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.espresso,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.superficie,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.superficie,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xl),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.borde, space: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.superficie,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.selected)
              ? AppColors.verde
              : AppColors.agotadoSuave,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _TransicionSuave(),
          TargetPlatform.iOS: _TransicionSuave(),
          TargetPlatform.macOS: _TransicionSuave(),
        },
      ),
    );
  }
}

/// Transición propia (fade + deslizamiento corto) en lugar del zoom de Material.
class _TransicionSuave extends PageTransitionsBuilder {
  const _TransicionSuave();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curva = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: curva,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.03, 0),
          end: Offset.zero,
        ).animate(curva),
        child: child,
      ),
    );
  }
}
