# MemoryFlow Tests

This directory contains unit tests for the MemoryFlow application.

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/services/database_service_test.dart
flutter test test/services/spaced_repetition_service_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Run integration tests
```bash
flutter test integration_test/app_test.dart
```

## Test Structure

### Unit Tests (`test/`)
- **services/** - Tests for service classes
  - `database_service_test.dart` - SQLite database operations
  - `spaced_repetition_service_test.dart` - Spaced repetition logic

- **models/** - Tests for data models
- **widgets/** - Tests for custom widgets

### Integration Tests (`integration_test/`)
- `app_test.dart` - End-to-end user flow tests

## Test Coverage Goals

- Services: >90%
- Models: >85%
- Widgets: >75%
- Overall: >80%

## Writing Tests

### Unit Test Template
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_flow/services/my_service.dart';

void main() {
  late MyService service;

  setUp(() {
    service = MyService();
  });

  tearDown(() {
    // Cleanup
  });

  group('MyService', () {
    test('should do something', () {
      // Arrange
      final input = 'test';

      // Act
      final result = service.doSomething(input);

      // Assert
      expect(result, 'expected');
    });
  });
}
```

### Integration Test Template
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:memory_flow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('should complete user flow', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Simulate user actions
    await tester.tap(find.text('Button'));
    await tester.pumpAndSettle();

    // Verify results
    expect(find.text('Result'), findsOneWidget);
  });
}
```

## Continuous Integration

Tests are automatically run on every commit via CI/CD pipeline.

## Mocking

We use `mockito` for mocking dependencies:

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([MyService])
void main() {
  late MockMyService mockService;

  setUp(() {
    mockService = MockMyService();
  });

  test('should use mock', () {
    when(mockService.getData()).thenReturn('mocked data');

    final result = mockService.getData();

    expect(result, 'mocked data');
    verify(mockService.getData()).called(1);
  });
}
```

## Testing Database

For database tests, we use `sqflite_common_ffi` to test SQLite operations without a real device:

```dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Your tests here
}
```

## Troubleshooting

### Tests fail with "MissingPluginException"
- Make sure you're using `sqflite_common_ffi` for database tests
- Initialize FFI in test setup

### Integration tests fail on CI
- Ensure emulator/simulator is running
- Check that integration test driver is properly configured

### Coverage report not generated
- Run: `flutter test --coverage`
- Generate HTML: `genhtml coverage/lcov.info -o coverage/html`
