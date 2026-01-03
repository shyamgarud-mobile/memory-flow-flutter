import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/topic.dart';
import '../models/folder.dart';
import '../services/file_service.dart';
import '../services/topics_index_service.dart';
import '../services/notification_service.dart';
import '../services/folder_service.dart';
import '../utils/markdown_helper.dart';
import '../utils/theme_helper.dart';
import '../widgets/common/markdown_toolbar.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/figma_button.dart';
import '../widgets/common/figma_text_field.dart';
import '../widgets/common/figma_dialog.dart';
import '../widgets/pickers/custom_date_time_picker.dart';
import '../providers/navigation_provider.dart';

/// Add Topic screen - Create new topics with markdown editor
class AddTopicScreen extends StatefulWidget {
  const AddTopicScreen({super.key});

  @override
  State<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _fileService = FileService();
  final _topicsIndexService = TopicsIndexService();
  final _notificationService = NotificationService();
  final _folderService = FolderService();

  bool _isPreviewMode = false;
  bool _isSaving = false;
  int _wordCount = 0;
  int _characterCount = 0;

  // Scheduling options
  String _scheduleType = 'auto'; // 'auto' or 'custom'
  DateTime? _customScheduleDateTime;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  bool _showScheduleSection = false; // Toggle for scheduling section

  // Folder selection
  String? _selectedFolderId;
  String? _selectedFolderName;
  List<Folder> _allFolders = [];

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_updateCounts);
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await _folderService.loadAllFolders();
    setState(() {
      _allFolders = folders;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateCounts() {
    setState(() {
      _wordCount = MarkdownHelper.getWordCount(_contentController.text);
      _characterCount = MarkdownHelper.getCharacterCount(_contentController.text);
    });
  }

  void _togglePreviewMode() {
    setState(() {
      _isPreviewMode = !_isPreviewMode;
    });
  }

  void _showLinkDialog() {
    String linkText = '';
    String linkUrl = '';

    showDialog(
      context: context,
      builder: (context) => FigmaDialog(
        title: 'Insert Link',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FigmaTextField(
              label: 'Link Text',
              hintText: 'Example Link',
              onChanged: (value) => linkText = value,
            ),
            ThemeHelper.vSpaceMedium,
            FigmaTextField(
              label: 'URL',
              hintText: 'https://example.com',
              keyboardType: TextInputType.url,
              onChanged: (value) => linkUrl = value,
            ),
          ],
        ),
        actions: [
          FigmaTextButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          FigmaButton(
            text: 'Insert',
            onPressed: () {
              MarkdownHelper.insertLink(
                _contentController,
                url: linkUrl.isEmpty ? null : linkUrl,
                linkText: linkText.isEmpty ? null : linkText,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /// Save the topic to storage
  Future<void> _saveTopic() async {
    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Check if content is not empty
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content before saving'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Calculate first review date based on schedule type
      DateTime firstReviewDate;
      bool useCustomSchedule;
      DateTime? customReviewDatetime;

      if (_scheduleType == 'custom' && _customScheduleDateTime != null) {
        // Use custom schedule
        firstReviewDate = _customScheduleDateTime!;
        useCustomSchedule = true;
        customReviewDatetime = _customScheduleDateTime;
      } else {
        // Use auto schedule (tomorrow at reminder time)
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        firstReviewDate = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          _reminderTime.hour,
          _reminderTime.minute,
        );
        useCustomSchedule = false;
        customReviewDatetime = null;
      }

      // Create new topic with UUID and schedule info
      final topic = Topic.create(
        title: _titleController.text.trim(),
        filePath: 'topics/placeholder.md', // Will be updated with actual path
        folderId: _selectedFolderId,
      ).copyWith(
        nextReviewDate: firstReviewDate,
        useCustomSchedule: useCustomSchedule,
        customReviewDatetime: customReviewDatetime,
      );

      // Save markdown content to file
      final filePath = await _fileService.saveMarkdownFile(
        topic.id,
        _contentController.text,
      );

      // Update topic with actual file path
      final updatedTopic = topic.copyWith(filePath: filePath);

      // Add topic to index
      await _topicsIndexService.addTopic(updatedTopic);

      // Schedule notification for the first review
      try {
        await _notificationService.scheduleTopicReminder(
          updatedTopic.id,
          firstReviewDate,
        );
        print('✓ Notification scheduled for ${updatedTopic.title}');
      } catch (e) {
        print('⚠ Failed to schedule notification: $e');
        // Don't fail the save operation if notification scheduling fails
      }

      // Show success message
      if (mounted) {
        final scheduleInfo = _scheduleType == 'custom'
            ? 'Review: ${DateFormat('MMM d, y \'at\' h:mm a').format(firstReviewDate)}'
            : 'First review: Tomorrow at ${_reminderTime.format(context)}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Topic "${updatedTopic.title}" saved successfully!\n'
              '$scheduleInfo',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear the form
        _titleController.clear();
        _contentController.clear();
        setState(() {
          _scheduleType = 'auto';
          _customScheduleDateTime = null;
          _showScheduleSection = false;
          _selectedFolderId = null;
          _selectedFolderName = null;
        });

        // Navigate back to home screen (index 0)
        final navigationProvider = context.read<NavigationProvider>();
        navigationProvider.setIndex(0);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save topic: $e'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      print('Error saving topic: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Topic'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility),
            tooltip: _isPreviewMode ? 'Edit' : 'Preview',
            onPressed: _togglePreviewMode,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Markdown Help',
            onPressed: _showMarkdownHelp,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Title field
            _buildTitleField(),

            // Folder selector
            _buildFolderSelector(),

            // Stats bar
            _buildStatsBar(),

            // Toolbar (only in edit mode)
            if (!_isPreviewMode)
              MarkdownToolbar(
                controller: _contentController,
                onInsertLink: _showLinkDialog,
              ),

            // Editor or Preview
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Editor/Preview
                    SizedBox(
                      height: _showScheduleSection ? 250 : 400,
                      child: _isPreviewMode
                          ? _buildPreview()
                          : _buildEditor(),
                    ),

                    // Schedule Section Toggle
                    _buildScheduleSectionToggle(),

                    // Schedule Section (expandable)
                    if (_showScheduleSection) ...[
                      ThemeHelper.vSpaceSmall,
                      _buildScheduleSection(),
                    ],
                  ],
                ),
              ),
            ),

            // Save button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Padding(
      padding: ThemeHelper.customPadding(
        horizontal: AppSpacing.md,
        top: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      child: FigmaTextField(
        controller: _titleController,
        label: 'Topic Title',
        hintText: 'Enter topic title',
        prefixIcon: Icons.title_rounded,
        textCapitalization: TextCapitalization.words,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a title';
          }
          if (value.trim().length < 3) {
            return 'Title must be at least 3 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildFolderSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: InkWell(
        onTap: _showFolderPicker,
        borderRadius: ThemeHelper.standardRadius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.gray700
                  : AppColors.gray300,
            ),
            borderRadius: ThemeHelper.standardRadius,
          ),
          child: Row(
            children: [
              Icon(
                Icons.folder_rounded,
                color: _selectedFolderId != null
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _selectedFolderName ?? 'No folder (root level)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _selectedFolderId != null
                            ? null
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFolderPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.gray700
                        : AppColors.gray300,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_rounded),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Select Folder',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Folder list
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  // No folder option
                  ListTile(
                    leading: Icon(
                      Icons.folder_off_rounded,
                      color: _selectedFolderId == null
                          ? AppColors.primary
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    title: const Text('No folder (root level)'),
                    trailing: _selectedFolderId == null
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedFolderId = null;
                        _selectedFolderName = null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),

                  // Folders
                  ..._buildFolderList(_allFolders, null, 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFolderList(List<Folder> folders, String? parentId, int depth) {
    final widgets = <Widget>[];
    final childFolders = folders.where((f) => f.parentId == parentId).toList();

    for (final folder in childFolders) {
      widgets.add(
        ListTile(
          contentPadding: EdgeInsets.only(
            left: AppSpacing.md + (depth * 24.0),
            right: AppSpacing.md,
          ),
          leading: Icon(
            Icons.folder_rounded,
            color: _selectedFolderId == folder.id
                ? AppColors.primary
                : Theme.of(context).textTheme.bodySmall?.color,
          ),
          title: Text(folder.name),
          trailing: _selectedFolderId == folder.id
              ? const Icon(Icons.check, color: AppColors.primary)
              : null,
          onTap: () {
            setState(() {
              _selectedFolderId = folder.id;
              _selectedFolderName = folder.name;
            });
            Navigator.pop(context);
          },
        ),
      );

      // Add children recursively
      widgets.addAll(_buildFolderList(folders, folder.id, depth + 1));
    }

    return widgets;
  }

  Widget _buildStatsBar() {
    return Container(
      padding: ThemeHelper.horizontalPadding,
      child: Row(
        children: [
          Icon(
            Icons.text_fields,
            size: 16,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          ThemeHelper.hSpaceSmall,
          Text(
            '$_wordCount words · $_characterCount characters',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          if (_isPreviewMode)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.round),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  ThemeHelper.hSpaceSmall,
                  Text(
                    'Preview',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.gray700
              : AppColors.gray300,
        ),
        borderRadius: ThemeHelper.standardRadius,
      ),
      child: TextField(
        controller: _contentController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          hintText: 'Write your content here...\n\nYou can use:\n• **bold** and *italic*\n• # Headings\n• Lists and more!',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
        ),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.gray700
              : AppColors.gray300,
        ),
        borderRadius: ThemeHelper.standardRadius,
      ),
      child: _contentController.text.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_off,
                    size: 48,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  ThemeHelper.vSpaceMedium,
                  Text(
                    'Nothing to preview yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                  ThemeHelper.vSpaceSmall,
                  Text(
                    'Switch to Edit mode to add content',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          : Markdown(
              data: _contentController.text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                h1: Theme.of(context).textTheme.headlineLarge,
                h2: Theme.of(context).textTheme.headlineMedium,
                h3: Theme.of(context).textTheme.headlineSmall,
                p: Theme.of(context).textTheme.bodyLarge,
                code: TextStyle(
                  fontFamily: 'monospace',
                  backgroundColor: AppColors.gray100,
                  color: AppColors.danger,
                ),
                codeblockDecoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: ThemeHelper.standardRadius,
                  border: Border.all(color: AppColors.gray300),
                ),
              ),
            ),
    );
  }

  /// Build schedule section toggle button
  Widget _buildScheduleSectionToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: InkWell(
        onTap: () {
          setState(() {
            _showScheduleSection = !_showScheduleSection;
          });
        },
        borderRadius: ThemeHelper.standardRadius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.white,
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.gray700
                  : AppColors.gray300,
            ),
            borderRadius: ThemeHelper.standardRadius,
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppColors.primary,
                size: 20,
              ),
              ThemeHelper.hSpaceSmall,
              Expanded(
                child: Text(
                  'Schedule Options',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Icon(
                _showScheduleSection ? Icons.expand_less : Icons.expand_more,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the schedule section
  Widget _buildScheduleSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.white,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.gray700
              : AppColors.gray300,
        ),
        borderRadius: ThemeHelper.standardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Schedule Type Options
          Text(
            'First Review',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          ThemeHelper.vSpaceMedium,

          // Auto option
          _buildScheduleOption(
            icon: Icons.flash_on,
            label: 'Auto (Tomorrow)',
            description: 'First review: Tomorrow at ${_reminderTime.format(context)}',
            isSelected: _scheduleType == 'auto',
            onTap: () {
              setState(() {
                _scheduleType = 'auto';
              });
            },
          ),
          ThemeHelper.vSpaceSmall,

          // Custom option
          _buildScheduleOption(
            icon: Icons.calendar_today,
            label: 'Custom Date & Time',
            description: _customScheduleDateTime != null
                ? DateFormat('MMM d, y \'at\' h:mm a').format(_customScheduleDateTime!)
                : 'Choose specific date and time',
            isSelected: _scheduleType == 'custom',
            onTap: () {
              setState(() {
                _scheduleType = 'custom';
              });
            },
          ),

          // Custom date/time picker (shown when custom is selected)
          if (_scheduleType == 'custom') ...[
            ThemeHelper.vSpaceMedium,
            CustomDateTimePicker(
              initialDateTime: _customScheduleDateTime,
              onDateTimeSelected: (dateTime) {
                setState(() {
                  _customScheduleDateTime = dateTime;
                });
              },
              label: 'Select Review Date & Time',
              minimumDate: DateTime.now().add(const Duration(hours: 1)),
              showLabel: false,
            ),
          ],

          ThemeHelper.vSpaceLarge,

          // Reminder Time
          Text(
            'Reminder Time',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          ThemeHelper.vSpaceSmall,
          Text(
            'Default time for auto-scheduled reviews',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          ThemeHelper.vSpaceMedium,

          FigmaOutlinedButton(
            text: 'Change Time: ${_reminderTime.format(context)}',
            icon: Icons.access_time,
            onPressed: _handleChangeReminderTime,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  /// Build a schedule option button
  Widget _buildScheduleOption({
    required IconData icon,
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: ThemeHelper.standardRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: ThemeHelper.standardRadius,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).brightness == Brightness.dark
                    ? AppColors.gray700
                    : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : Theme.of(context).brightness == Brightness.dark
                        ? AppColors.gray800
                        : AppColors.gray100,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            ThemeHelper.hSpaceMedium,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppColors.primary : null,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// Handle changing the reminder time
  Future<void> _handleChangeReminderTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.white,
              onSurface: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _reminderTime = pickedTime;
      });
    }
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.white,
        boxShadow: ThemeHelper.standardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton.secondary(
              text: 'Cancel',
              onPressed: _isSaving ? null : () => Navigator.pop(context),
            ),
          ),
          ThemeHelper.hSpaceMedium,
          Expanded(
            flex: 2,
            child: CustomButton.primary(
              text: _isSaving ? 'Saving...' : 'Save Topic',
              icon: _isSaving ? null : Icons.save,
              onPressed: _isSaving ? null : _saveTopic,
              isLoading: _isSaving,
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkdownHelp() {
    showDialog(
      context: context,
      builder: (context) => FigmaDialog(
        title: 'Markdown Syntax',
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem('**Bold**', 'Bold text'),
              _buildHelpItem('*Italic*', 'Italic text'),
              _buildHelpItem('# Heading 1', 'Large heading'),
              _buildHelpItem('## Heading 2', 'Medium heading'),
              _buildHelpItem('- Item', 'Bullet list'),
              _buildHelpItem('1. Item', 'Numbered list'),
              _buildHelpItem('`code`', 'Inline code'),
              _buildHelpItem('```\ncode block\n```', 'Code block'),
              _buildHelpItem('[text](url)', 'Link'),
              _buildHelpItem('> Quote', 'Blockquote'),
            ],
          ),
        ),
        actions: [
          FigmaButton(
            text: 'Got it',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String syntax, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              syntax,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          ThemeHelper.hSpaceSmall,
          Expanded(
            flex: 3,
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
