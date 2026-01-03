import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_constants.dart';

/// Figma-style text field with clean, minimal design
///
/// Design specs:
/// - Height: 56px (standard)
/// - Border radius: 12px
/// - Border: 1px solid (gray300 normal, primary focused, error on error)
/// - Font: 16px regular
/// - Padding: 16px horizontal, 16px vertical
/// - Label: 14px medium weight (optional)
/// - Error text: 12px (below field)
///
/// Usage:
/// ```dart
/// FigmaTextField(
///   controller: _controller,
///   label: 'Email',
///   hintText: 'Enter your email',
///   prefixIcon: Icons.email,
/// )
/// ```
class FigmaTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffix;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;

  const FigmaTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label (optional)
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Text field
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onTap: onTap,
          validator: validator,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 20,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  )
                : null,
            suffixIcon: suffix != null
                ? suffix
                : suffixIcon != null
                    ? IconButton(
                        icon: Icon(
                          suffixIcon,
                          size: 20,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                        onPressed: onSuffixTap,
                      )
                    : null,
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.input),
              borderSide: BorderSide(
                color: isDark ? AppColors.gray700 : AppColors.gray300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.input),
              borderSide: BorderSide(
                color: isDark ? AppColors.gray700 : AppColors.gray300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.input),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.input),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.input),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.input),
              borderSide: BorderSide(
                color: isDark ? AppColors.gray800 : AppColors.gray200,
                width: 1,
              ),
            ),
            filled: !enabled,
            fillColor: !enabled
                ? (isDark ? AppColors.gray900 : AppColors.gray100)
                : null,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: isDark ? AppColors.gray500 : AppColors.gray400,
              letterSpacing: 0,
            ),
            helperStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            errorStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}

/// Figma-style search field with search icon and clear button
///
/// Design specs:
/// - Same as FigmaTextField but with search icon prefix
/// - Clear button suffix (when text is present)
/// - Optimized for search UX
///
/// Usage:
/// ```dart
/// FigmaSearchField(
///   controller: _searchController,
///   hintText: 'Search topics...',
///   onChanged: (value) => _performSearch(value),
/// )
/// ```
class FigmaSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;

  const FigmaSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
  });

  @override
  State<FigmaSearchField> createState() => _FigmaSearchFieldState();
}

class _FigmaSearchFieldState extends State<FigmaSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_updateHasText);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_updateHasText);
    }
    super.dispose();
  }

  void _updateHasText() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return FigmaTextField(
      controller: _controller,
      hintText: widget.hintText ?? 'Search...',
      prefixIcon: Icons.search_rounded,
      suffixIcon: _hasText ? Icons.clear_rounded : null,
      onSuffixTap: _hasText ? _handleClear : null,
      onChanged: widget.onChanged,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
    );
  }
}

/// Figma-style text area for multi-line input
///
/// Design specs:
/// - Same as FigmaTextField but with multiple lines
/// - Auto-expanding or fixed height
/// - Better for long-form content
///
/// Usage:
/// ```dart
/// FigmaTextArea(
///   controller: _contentController,
///   label: 'Description',
///   hintText: 'Enter description...',
///   minLines: 3,
///   maxLines: 8,
/// )
/// ```
class FigmaTextArea extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final int minLines;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final EdgeInsetsGeometry? contentPadding;

  const FigmaTextArea({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.minLines = 3,
    this.maxLines,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
    this.validator,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return FigmaTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      onChanged: onChanged,
      validator: validator,
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
    );
  }
}
