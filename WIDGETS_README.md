# Reusable Widgets & Theme Helpers

Complete guide to using the custom widgets and theme helpers in MemoryFlow.

## Table of Contents
- [Custom Card](#custom-card)
- [Custom Button](#custom-button)
- [Topic Status Badge](#topic-status-badge)
- [Empty State](#empty-state)
- [Theme Helper](#theme-helper)

---

## Custom Card

Reusable card widget with consistent styling, shadows, and optional borders.

**Location:** `lib/widgets/common/custom_card.dart`

### Basic Usage

```dart
CustomCard(
  child: Text('Hello World'),
)
```

### With Tap Action

```dart
CustomCard(
  onTap: () => print('Tapped'),
  child: ListTile(
    title: Text('Clickable Card'),
    trailing: Icon(Icons.chevron_right),
  ),
)
```

### Custom Styling

```dart
CustomCard(
  color: AppColors.primary.withOpacity(0.1),
  borderColor: AppColors.primary,
  borderWidth: 2.0,
  elevation: 4.0,
  padding: EdgeInsets.all(AppSpacing.lg),
  margin: EdgeInsets.all(AppSpacing.md),
  borderRadius: AppBorderRadius.xl,
  child: Text('Featured Item'),
)
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| child | Widget | required | Content to display |
| onTap | VoidCallback? | null | Tap callback |
| color | Color? | theme | Background color |
| borderColor | Color? | null | Border color |
| borderWidth | double | 1.0 | Border width |
| elevation | double | 2.0 | Shadow depth |
| padding | EdgeInsets? | AppSpacing.md | Internal padding |
| margin | EdgeInsets? | zero | External margin |
| borderRadius | double? | AppBorderRadius.lg | Corner radius |

---

## Custom Button

Reusable button widget with three variants: primary, secondary, and text.

**Location:** `lib/widgets/common/custom_button.dart`

### Primary Button

```dart
CustomButton.primary(
  text: 'Save',
  onPressed: () => save(),
  icon: Icons.save,
)
```

### Secondary Button

```dart
CustomButton.secondary(
  text: 'Cancel',
  onPressed: () => cancel(),
)
```

### Text Button

```dart
CustomButton.text(
  text: 'Learn More',
  onPressed: () => navigate(),
  icon: Icons.arrow_forward,
)
```

### Loading State

```dart
CustomButton.primary(
  text: 'Submitting...',
  isLoading: true,
)
```

### Full Width

```dart
CustomButton.primary(
  text: 'Get Started',
  onPressed: () => start(),
  fullWidth: true,
  size: CustomButtonSize.large,
)
```

### Custom Colors

```dart
CustomButton.primary(
  text: 'Delete',
  onPressed: () => delete(),
  backgroundColor: AppColors.danger,
  icon: Icons.delete,
)
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| text | String | required | Button label |
| onPressed | VoidCallback? | null | Tap callback |
| type | CustomButtonType | primary | Button style |
| icon | IconData? | null | Leading icon |
| isLoading | bool | false | Show spinner |
| fullWidth | bool | false | Expand to full width |
| backgroundColor | Color? | null | Custom bg color |
| textColor | Color? | null | Custom text color |
| size | CustomButtonSize | medium | Button size |

### Button Sizes
- `CustomButtonSize.small` - Compact button
- `CustomButtonSize.medium` - Standard button
- `CustomButtonSize.large` - Prominent button

---

## Topic Status Badge

Badge widget for displaying topic review status.

**Location:** `lib/widgets/common/topic_status_badge.dart`

### Basic Usage

```dart
TopicStatusBadge(
  status: TopicStatus.overdue,
)
```

### Different Sizes

```dart
TopicStatusBadge(
  status: TopicStatus.dueToday,
  size: BadgeSize.small,
)
```

### Without Icon

```dart
TopicStatusBadge(
  status: TopicStatus.upcoming,
  showIcon: false,
  customLabel: 'In 3 days',
)
```

### Dynamic Status from Date

```dart
final status = getTopicStatusFromDate(dueDate);
TopicStatusBadge(status: status)
```

### Status Types

| Status | Color | Icon | Use Case |
|--------|-------|------|----------|
| overdue | Red | error_outline | Past due date |
| dueToday | Orange | today | Due today |
| upcoming | Green | schedule | Future date |
| completed | Blue | check_circle | Finished |
| notStarted | Gray | radio_button | Not started |

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| status | TopicStatus | required | Status to display |
| size | BadgeSize | medium | Badge size |
| showIcon | bool | true | Show status icon |
| customLabel | String? | null | Override label |

---

## Empty State

Widget for displaying empty states with icon, title, subtitle, and actions.

**Location:** `lib/widgets/common/empty_state.dart`

### Basic Empty State

```dart
EmptyState(
  icon: Icons.folder_open,
  title: 'No Items Found',
  subtitle: 'Start by adding your first item',
  buttonText: 'Add Item',
  onButtonPressed: () => addItem(),
)
```

### With Secondary Action

```dart
EmptyState(
  icon: Icons.inbox,
  title: 'Inbox Empty',
  subtitle: 'All tasks complete',
  buttonText: 'Create Task',
  onButtonPressed: () => create(),
  secondaryButtonText: 'View Archive',
  onSecondaryButtonPressed: () => viewArchive(),
)
```

### Using Presets

```dart
// No topics
EmptyStatePresets.noTopics(
  onAddTopic: () => navigateToAddTopic(),
)

// No search results
EmptyStatePresets.noSearchResults(
  searchQuery: 'Flutter',
  onClearSearch: () => clearSearch(),
)

// No reviews today
EmptyStatePresets.noReviewsToday(
  onBrowseTopics: () => browse(),
)

// Connection error
EmptyStatePresets.connectionError(
  onRetry: () => retry(),
)

// Generic error
EmptyStatePresets.error(
  message: 'Failed to load data',
  onRetry: () => reload(),
)

// Coming soon
EmptyStatePresets.comingSoon(
  feature: 'Statistics Dashboard',
)
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| icon | IconData | required | Display icon |
| title | String | required | Main title |
| subtitle | String | required | Description |
| buttonText | String? | null | Primary button |
| onButtonPressed | VoidCallback? | null | Primary action |
| secondaryButtonText | String? | null | Secondary button |
| onSecondaryButtonPressed | VoidCallback? | null | Secondary action |
| iconColor | Color? | gray | Icon color |
| iconSize | double | 80 | Icon size |
| showBackground | bool | true | Show circle bg |
| maxWidth | double | 400 | Max content width |

---

## Theme Helper

Utility class for consistent styling and theming.

**Location:** `lib/utils/theme_helper.dart`

### Spacing

```dart
// Predefined padding
Padding(
  padding: ThemeHelper.screenPadding,
  child: content,
)

Padding(
  padding: ThemeHelper.cardPadding,
  child: content,
)

// Custom padding
Container(
  padding: ThemeHelper.customPadding(
    horizontal: AppSpacing.lg,
    top: AppSpacing.xl,
  ),
)

// Spacing widgets
Column(
  children: [
    Text('Title'),
    ThemeHelper.vSpaceMedium,
    Text('Content'),
  ],
)
```

### Border Radius

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: ThemeHelper.largeRadius,
  ),
)

// Other options:
// ThemeHelper.standardRadius
// ThemeHelper.roundedRadius
// ThemeHelper.topRadius
// ThemeHelper.bottomRadius
```

### Colors

```dart
// Status colors
Container(
  color: ThemeHelper.getStatusColor(TopicStatus.overdue),
)

// Progress colors
LinearProgressIndicator(
  value: 0.75,
  color: ThemeHelper.getProgressColor(0.75),
)

// Difficulty colors
Text(
  'Hard',
  style: TextStyle(
    color: ThemeHelper.getDifficultyColor(2),
  ),
)

// Adaptive colors
Container(
  color: ThemeHelper.adaptive(
    context,
    light: Colors.white,
    dark: Colors.black,
  ),
)
```

### Text Styles

```dart
Text(
  'Important',
  style: ThemeHelper.bold(AppTextStyles.bodyLarge),
)

Text(
  'Note',
  style: ThemeHelper.muted(context, AppTextStyles.bodyMedium),
)

Text(
  'Italic',
  style: ThemeHelper.italic(AppTextStyles.bodyMedium),
)
```

### Shadows

```dart
Container(
  decoration: BoxDecoration(
    boxShadow: ThemeHelper.standardShadow,
  ),
)

// Other options:
// ThemeHelper.elevatedShadow
// ThemeHelper.customShadow(opacity: 0.2)
```

### Gradients

```dart
Container(
  decoration: BoxDecoration(
    gradient: ThemeHelper.primaryGradient,
  ),
)

// Custom gradient
Container(
  decoration: BoxDecoration(
    gradient: ThemeHelper.customGradient(
      colors: [Colors.blue, Colors.purple],
    ),
  ),
)
```

### Dividers

```dart
Column(
  children: [
    Text('Section 1'),
    ThemeHelper.dividerWithSpacing(),
    Text('Section 2'),
  ],
)
```

### Theme Detection

```dart
if (ThemeHelper.isDark(context)) {
  // Dark theme specific code
}

Color textColor = ThemeHelper.adaptive(
  context,
  light: Colors.black,
  dark: Colors.white,
);
```

---

## Widget Showcase

To see all widgets in action, navigate to:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => WidgetShowcaseScreen(),
  ),
)
```

**File:** `lib/screens/widget_showcase_screen.dart`

---

## Quick Reference

### Common Patterns

**Card with action:**
```dart
CustomCard(
  onTap: () => action(),
  child: ListTile(
    leading: Icon(Icons.topic),
    title: Text('Topic'),
    trailing: TopicStatusBadge(status: TopicStatus.overdue),
  ),
)
```

**Form with buttons:**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    TextField(),
    ThemeHelper.vSpaceMedium,
    CustomButton.primary(
      text: 'Submit',
      onPressed: () => submit(),
      fullWidth: true,
    ),
    ThemeHelper.vSpaceSmall,
    CustomButton.text(
      text: 'Cancel',
      onPressed: () => cancel(),
      fullWidth: true,
    ),
  ],
)
```

**Status indicator:**
```dart
Row(
  children: [
    Expanded(child: Text('Topic Name')),
    TopicStatusBadge(
      status: TopicStatus.dueToday,
      size: BadgeSize.small,
    ),
  ],
)
```

**Empty list:**
```dart
ListView.builder(
  itemCount: items.isEmpty ? 1 : items.length,
  itemBuilder: (context, index) {
    if (items.isEmpty) {
      return EmptyStatePresets.noTopics(
        onAddTopic: () => add(),
      );
    }
    return ListTile(/* ... */);
  },
)
```

---

## Best Practices

1. **Use theme helpers** for consistency:
   ```dart
   // Good
   ThemeHelper.vSpaceMedium

   // Avoid
   SizedBox(height: 16)
   ```

2. **Prefer reusable widgets** over custom implementations:
   ```dart
   // Good
   CustomCard(child: content)

   // Avoid
   Container(
     decoration: BoxDecoration(/* ... */),
     child: content,
   )
   ```

3. **Use preset empty states** when applicable:
   ```dart
   // Good
   EmptyStatePresets.noTopics()

   // Avoid creating custom empty state for common scenarios
   ```

4. **Leverage button variants**:
   ```dart
   // Primary for main actions
   CustomButton.primary(text: 'Save')

   // Secondary for alternative actions
   CustomButton.secondary(text: 'Edit')

   // Text for tertiary actions
   CustomButton.text(text: 'Learn More')
   ```

---

## Contributing

When adding new reusable widgets:

1. Place in `lib/widgets/common/`
2. Add comprehensive documentation
3. Include usage examples in comments
4. Add to `WidgetShowcaseScreen`
5. Update this README
