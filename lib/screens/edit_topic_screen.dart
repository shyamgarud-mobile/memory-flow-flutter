import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../constants/app_constants.dart';
import '../models/topic.dart';
import '../services/file_service.dart';
import '../services/topics_index_service.dart';
import '../utils/markdown_helper.dart';
import '../utils/theme_helper.dart';
import '../widgets/common/markdown_toolbar.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/figma_text_field.dart';
import '../widgets/common/figma_button.dart';
import '../widgets/common/figma_dialog.dart';

/// Edit Topic screen - Edit existing topics with markdown editor
class EditTopicScreen extends StatefulWidget {
  final Topic topic;

  const EditTopicScreen({
    super.key,
    required this.topic,
  });

  @override
  State<EditTopicScreen> createState() => _EditTopicScreenState();
}

class _EditTopicScreenState extends State<EditTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final _fileService = FileService();
  final _topicsIndexService = TopicsIndexService();

  bool _isPreviewMode = false;
  bool _isSaving = false;
  bool _isLoading = true;
  int _wordCount = 0;
  int _characterCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.topic.title);
    _contentController = TextEditingController();
    _contentController.addListener(_updateCounts);
    _loadContent();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Load markdown content from file
  Future<void> _loadContent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final content = await _fileService.readMarkdownFile(widget.topic.id);

      if (mounted) {
        setState(() {
          _contentController.text = content;
          _updateCounts();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load content: $e';
          _isLoading = false;
        });
      }
    }
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

  /// Save the topic updates
  Future<void> _saveChanges() async {
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
      // Update topic title if changed
      final updatedTopic = widget.topic.copyWith(
        title: _titleController.text.trim(),
      );

      // Save markdown content to file
      await _fileService.saveMarkdownFile(
        widget.topic.id,
        _contentController.text,
      );

      // Update topic in index
      await _topicsIndexService.updateTopic(updatedTopic);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Topic "${updatedTopic.title}" updated successfully!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back with updated topic
        Navigator.pop(context, updatedTopic);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update topic: $e'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      print('Error updating topic: $e');
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Topic'),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Topic'),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.danger,
                ),
                ThemeHelper.vSpaceMedium,
                Text(
                  'Failed to load topic',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ThemeHelper.vSpaceSmall,
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                ThemeHelper.vSpaceLarge,
                CustomButton.primary(
                  text: 'Retry',
                  icon: Icons.refresh,
                  onPressed: _loadContent,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Topic'),
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
              child: _isPreviewMode ? _buildPreview() : _buildEditor(),
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
          : SingleChildScrollView(
              child: Markdown(
                data: _contentController.text,
                selectable: true,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                styleSheet: MarkdownStyleSheet(
                  h1: Theme.of(context).textTheme.headlineLarge,
                  h2: Theme.of(context).textTheme.headlineMedium,
                  h3: Theme.of(context).textTheme.headlineSmall,
                  p: Theme.of(context).textTheme.bodyLarge,
                  code: TextStyle(
                    fontFamily: 'monospace',
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.gray800
                        : AppColors.gray100,
                    color: AppColors.danger,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.gray800
                        : AppColors.gray100,
                    borderRadius: ThemeHelper.standardRadius,
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.gray700
                          : AppColors.gray300,
                    ),
                  ),
                ),
              ),
            ),
    );
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
              text: _isSaving ? 'Saving...' : 'Save Changes',
              icon: _isSaving ? null : Icons.save,
              onPressed: _isSaving ? null : _saveChanges,
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
