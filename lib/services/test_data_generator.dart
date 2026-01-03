import 'package:uuid/uuid.dart';
import 'database_service.dart';
import 'folder_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/topic.dart';

/// Service to generate test data for development/testing
/// Creates 1000 interview question topics across 5 categories
class TestDataGenerator {
  final DatabaseService _db = DatabaseService();
  final FolderService _folderService = FolderService();
  final _uuid = const Uuid();

  // Folder IDs
  String? laravelFolderId;
  String? reactjsFolderId;
  String? flutterFolderId;
  String? pythonFolderId;
  String? aiFolderId;

  /// Generate all 1000 test topics
  Future<void> generateAllTopics() async {
    print('🚀 Starting Interview Topics Generator...\n');

    // Create folders
    await _createFolders();

    // Generate topics for each category
    await _generateLaravelTopics();
    await _generateReactJSTopics();
    await _generateFlutterTopics();
    await _generatePythonTopics();
    await _generateAITopics();

    print('\n✅ All done! 1000 topics created successfully!');
  }

  Future<void> _createFolders() async {
    print('📁 Creating category folders...');

    laravelFolderId = await _createFolder('Laravel Interview Questions', '#EF4444', 'code');
    reactjsFolderId = await _createFolder('ReactJS Interview Questions', '#61DAFB', 'web');
    flutterFolderId = await _createFolder('Flutter Interview Questions', '#02569B', 'phone_android');
    pythonFolderId = await _createFolder('Python Interview Questions', '#3776AB', 'integration_instructions');
    aiFolderId = await _createFolder('AI/ML Interview Questions', '#FF6F00', 'psychology');

    print('✓ All folders created\n');
  }

  Future<String> _createFolder(String name, String color, String iconName) async {
    final folder = await _folderService.createFolder(
      name: name,
      color: color,
      iconName: iconName,
    );

    if (folder == null) {
      throw Exception('Failed to create folder: $name');
    }

    print('  ✓ Created: $name');
    return folder.id;
  }

  Future<void> _generateLaravelTopics() async {
    print('🔴 Generating 200 Laravel topics...');

    final topics = [
      // Basics (50)
      ...List.generate(10, (i) => 'Laravel Routing - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Laravel Controllers - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Laravel Middleware - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Laravel Views & Blade - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Laravel Request & Response - Question ${i + 1}'),

      // Database (50)
      ...List.generate(15, (i) => 'Eloquent ORM - Question ${i + 1}'),
      ...List.generate(15, (i) => 'Database Migrations - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Query Builder - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Database Relationships - Question ${i + 1}'),

      // Advanced (100)
      ...List.generate(15, (i) => 'Laravel Authentication - Question ${i + 1}'),
      ...List.generate(15, (i) => 'Laravel Authorization - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Laravel Validation - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Laravel Events & Listeners - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Laravel Queues & Jobs - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Laravel API Development - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Laravel Testing - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Laravel Package Development - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Laravel Performance Optimization - Question ${i + 1}'),
    ];

    await _createTopics(topics, laravelFolderId!);
    print('  ✓ Created ${topics.length} Laravel topics\n');
  }

  Future<void> _generateReactJSTopics() async {
    print('⚛️  Generating 200 ReactJS topics...');

    final topics = [
      // Basics (60)
      ...List.generate(15, (i) => 'React Components - Question ${i + 1}'),
      ...List.generate(15, (i) => 'React Props & State - Question ${i + 1}'),
      ...List.generate(15, (i) => 'React Lifecycle Methods - Question ${i + 1}'),
      ...List.generate(15, (i) => 'React Hooks - Question ${i + 1}'),

      // Intermediate (70)
      ...List.generate(15, (i) => 'React Context API - Question ${i + 1}'),
      ...List.generate(15, (i) => 'React Router - Question ${i + 1}'),
      ...List.generate(10, (i) => 'React Forms - Question ${i + 1}'),
      ...List.generate(15, (i) => 'React Performance - Question ${i + 1}'),
      ...List.generate(15, (i) => 'React Redux - Question ${i + 1}'),

      // Advanced (70)
      ...List.generate(10, (i) => 'React Server Components - Question ${i + 1}'),
      ...List.generate(10, (i) => 'React Suspense - Question ${i + 1}'),
      ...List.generate(10, (i) => 'React Error Boundaries - Question ${i + 1}'),
      ...List.generate(10, (i) => 'React Testing (Jest/RTL) - Question ${i + 1}'),
      ...List.generate(10, (i) => 'React TypeScript - Question ${i + 1}'),
      ...List.generate(10, (i) => 'React Design Patterns - Question ${i + 1}'),
      ...List.generate(10, (i) => 'React Best Practices - Question ${i + 1}'),
    ];

    await _createTopics(topics, reactjsFolderId!);
    print('  ✓ Created ${topics.length} ReactJS topics\n');
  }

  Future<void> _generateFlutterTopics() async {
    print('💙 Generating 200 Flutter topics...');

    final topics = [
      // Basics (50)
      ...List.generate(15, (i) => 'Flutter Widgets - Question ${i + 1}'),
      ...List.generate(15, (i) => 'Flutter State Management - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Flutter Navigation - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Flutter Layouts - Question ${i + 1}'),

      // UI/UX (50)
      ...List.generate(10, (i) => 'Flutter Animations - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Flutter Themes - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Flutter Custom Widgets - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Flutter Gestures - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Flutter Responsive Design - Question ${i + 1}'),

      // Advanced (100)
      ...List.generate(15, (i) => 'Flutter Provider - Question ${i + 1}'),
      ...List.generate(15, (i) => 'Flutter Riverpod - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Flutter BLoC Pattern - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Flutter GetX - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Flutter SQLite - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Flutter HTTP & API - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Flutter Firebase - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Flutter Platform Channels - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Flutter Testing - Question ${i + 1}'),
    ];

    await _createTopics(topics, flutterFolderId!);
    print('  ✓ Created ${topics.length} Flutter topics\n');
  }

  Future<void> _generatePythonTopics() async {
    print('🐍 Generating 200 Python topics...');

    final topics = [
      // Basics (50)
      ...List.generate(15, (i) => 'Python Data Types - Question ${i + 1}'),
      ...List.generate(15, (i) => 'Python Functions - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Python Classes & OOP - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Python Modules & Packages - Question ${i + 1}'),

      // Intermediate (70)
      ...List.generate(15, (i) => 'Python Decorators - Question ${i + 1}'),
      ...List.generate(15, (i) => 'Python Generators - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Python Context Managers - Question ${i + 1}'),
      ...List.generate(15, (i) => 'Python File Handling - Question ${i + 1}'),
      ...List.generate(15, (i) => 'Python Exception Handling - Question ${i + 1}'),

      // Advanced (80)
      ...List.generate(10, (i) => 'Python Multithreading - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Python Multiprocessing - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Python Async/Await - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Python Django - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Python Flask - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Python FastAPI - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Python Testing (pytest) - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Python Best Practices - Question ${i + 1}'),
    ];

    await _createTopics(topics, pythonFolderId!);
    print('  ✓ Created ${topics.length} Python topics\n');
  }

  Future<void> _generateAITopics() async {
    print('🤖 Generating 200 AI/ML topics...');

    final topics = [
      // ML Basics (60)
      ...List.generate(15, (i) => 'Machine Learning Fundamentals - Question ${i + 1}'),
      ...List.generate(15, (i) => 'Supervised Learning - Question ${i + 1}'),
      ...List.generate(15, (i) => 'Unsupervised Learning - Question ${i + 1}'),
      ...List.generate(15, (i) => 'Model Evaluation - Question ${i + 1}'),

      // Deep Learning (70)
      ...List.generate(15, (i) => 'Neural Networks - Question ${i + 1}'),
      ...List.generate(15, (i) => 'CNN (Computer Vision) - Question ${i + 1}'),
      ...List.generate(15, (i) => 'RNN & LSTM - Question ${i + 1}'),
      ...List.generate(15, (i) => 'Transformers & Attention - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Transfer Learning - Question ${i + 1}'),

      // Advanced (70)
      ...List.generate(15, (i) => 'NLP & Language Models - Question ${i + 1}'),
      ...List.generate(15, (i) => 'GANs & Generative AI - Question ${i + 1}'),
      ...List.generate(10, (i) => 'Reinforcement Learning - Question ${i + 1}'),
      ...List.generate(10, (i) => 'MLOps & Deployment - Question ${i + 1}'),
      ...List.generate(10, (i) => 'AI Ethics & Bias - Question ${i + 1}'),
      ...List.generate(10, (i) => 'AI Tools (TensorFlow/PyTorch) - Question ${i + 1}'),
    ];

    await _createTopics(topics, aiFolderId!);
    print('  ✓ Created ${topics.length} AI/ML topics\n');
  }

  Future<void> _createTopics(List<String> titles, String folderId) async {
    final now = DateTime.now();
    final topics = <Topic>[];

    // Create Topic objects
    for (var i = 0; i < titles.length; i++) {
      final id = _uuid.v4();
      final title = titles[i];
      final nextReviewDate = now.add(Duration(days: i % 7)); // Distribute reviews

      final topic = Topic(
        id: id,
        title: title,
        filePath: 'topics/$id.md',
        createdAt: now,
        currentStage: 0,
        nextReviewDate: nextReviewDate,
        lastReviewedAt: null,
        reviewCount: 0,
        tags: const [],
        isFavorite: false,
        useCustomSchedule: false,
        customReviewDatetime: null,
        folderId: folderId,
      );

      topics.add(topic);

      // Create markdown file content
      final content = _generateQuestionContent(title);
      await _createMarkdownFile(id, content);
    }

    // Batch insert all topics at once
    await _db.insertTopicsBatch(topics);
  }

  String _generateQuestionContent(String title) {
    return '''# $title

## Question
[Interview question will go here]

## Answer
[Your answer here]

## Key Points
- Point 1
- Point 2
- Point 3

## Code Example
\`\`\`
// Code example here
\`\`\`

## Follow-up Questions
1. Related question 1?
2. Related question 2?

## Resources
- [Documentation](#)
- [Tutorial](#)
''';
  }

  Future<void> _createMarkdownFile(String id, String content) async {
    // Get app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final topicsDir = Directory('${appDir.path}/topics');

    if (!await topicsDir.exists()) {
      await topicsDir.create(recursive: true);
    }

    final file = File('${topicsDir.path}/$id.md');
    await file.writeAsString(content);
  }
}
