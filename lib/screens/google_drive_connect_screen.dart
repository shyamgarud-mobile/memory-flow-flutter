import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/google_drive_service.dart';
import '../utils/theme_helper.dart';
import '../widgets/common/figma_button.dart';

/// Google Drive connection onboarding screen
class GoogleDriveConnectScreen extends StatefulWidget {
  const GoogleDriveConnectScreen({super.key});

  @override
  State<GoogleDriveConnectScreen> createState() => _GoogleDriveConnectScreenState();
}

class _GoogleDriveConnectScreenState extends State<GoogleDriveConnectScreen> {
  final GoogleDriveService _driveService = GoogleDriveService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _driveService.initialize();
  }

  /// Handle sign in with Google
  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _driveService.signIn();

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully connected to Google Drive'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to connect to Google Drive'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle skip
  void _handleSkip() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _handleSkip,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Center(
                        child: Column(
                          children: [
                            // Google Drive logo
                            Image.asset(
                              'assets/images/google_logo.png',
                              height: 80,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.cloud_outlined,
                                  size: 64,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ThemeHelper.vSpaceLarge,

                      // Title
                      Text(
                        'Backup to Google Drive',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      ThemeHelper.vSpaceMedium,

                      // Subtitle
                      Text(
                        'Keep your memories safe and accessible across all your devices',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      ThemeHelper.vSpaceLarge,

                      // Benefits
                      _buildBenefitItem(
                        context,
                        Icons.folder_outlined,
                        'Auto-Organization',
                        'We\'ll create a folder named "MemoryFlow" in your Drive',
                      ),
                      ThemeHelper.vSpaceMedium,
                      _buildBenefitItem(
                        context,
                        Icons.lock_outline,
                        'Your Data Stays Private',
                        'Only you can access your backups. We never see your data.',
                      ),
                      ThemeHelper.vSpaceMedium,
                      _buildBenefitItem(
                        context,
                        Icons.sync_outlined,
                        'Automatic Backups',
                        'Set it once and forget it. Your data is always protected.',
                      ),
                      ThemeHelper.vSpaceMedium,
                      _buildBenefitItem(
                        context,
                        Icons.devices_outlined,
                        'Sync Across Devices',
                        'Access your topics from any device, anytime.',
                      ),
                      ThemeHelper.vSpaceLarge,

                      // Privacy note
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            ThemeHelper.hSpaceSmall,
                            Expanded(
                              child: Text(
                                'Google Drive is used only for backup. Your learning progress stays on your device.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textPrimaryLight,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Buttons
              Column(
                children: [
                  FigmaButton(
                    text: _isLoading ? 'Connecting...' : 'Sign in with Google',
                    icon: Icons.login,
                    onPressed: _isLoading ? null : _handleSignIn,
                    isLoading: _isLoading,
                    fullWidth: true,
                  ),
                  ThemeHelper.vSpaceMedium,
                  FigmaTextButton(
                    text: 'Skip for now',
                    onPressed: _isLoading ? null : _handleSkip,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a benefit item
  Widget _buildBenefitItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.success,
            size: 24,
          ),
        ),
        ThemeHelper.hSpaceMedium,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ThemeHelper.vSpaceSmall,
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
