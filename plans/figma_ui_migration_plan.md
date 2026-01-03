# MemoryFlow - Figma UI Migration Plan

**Goal:** Transform MemoryFlow app UI to match Figma Mobile Apps Prototyping Kit design patterns while maintaining existing functionality.

**Strategy:** Incremental, testable milestones - each can be tested independently before moving to the next.

---

## **PHASE 1: FOUNDATION - Design System Updates**
*Test after each milestone to ensure no breaking changes*

### **Milestone 1.1: Update Design Tokens** ⏱️ 30 min
**Files to modify:**
- `lib/constants/app_constants.dart`
- `lib/constants/design_system.dart`

**Changes:**
- [ ] Add Figma color palette option (iOS Blue #007AFF)
- [ ] Update border radius values (add `button: 24px`, `pillButton: 9999px`)
- [ ] Update shadow definitions (increase blur radius: small:8px, medium:16px, large:24px)
- [ ] Add new spacing token: `buttonHeight: 56px`

**Testing:**
- Run app, verify no crashes
- Check existing screens still render correctly
- Colors should remain unchanged (new colors added, not replaced)

**Acceptance Criteria:**
✅ App runs without errors
✅ All existing screens display correctly
✅ New design tokens available in constants

---

### **Milestone 1.2: Create Figma Color Scheme** ⏱️ 15 min
**Files to modify:**
- `lib/constants/app_constants.dart` (AppColorSchemes class)

**Changes:**
- [ ] Add new `ColorSchemeData` for "Figma iOS" theme
  - Primary: #007AFF
  - Secondary: #5AC8FA (light blue)
  - Accent: #FF9500 (orange)
  - Background: #F5F9FC
  - Surface: #FFFFFF

**Testing:**
- Go to Settings → Appearance → Color Scheme
- Select "Figma iOS" theme
- Verify app switches to new color scheme
- Switch back to original theme
- Verify everything still works

**Acceptance Criteria:**
✅ New "Figma iOS" color scheme appears in Settings
✅ Can switch between themes
✅ Theme persists after app restart

---

## **PHASE 2: CORE NAVIGATION - Bottom & Top Bars**
*Most visible changes, affects all screens*

### **Milestone 2.1: Update Bottom Navigation Bar** ⏱️ 45 min
**Files to modify:**
- `lib/screens/main_navigation.dart`
- Create new file: `lib/widgets/common/figma_bottom_nav_bar.dart`

**Changes:**
- [ ] Increase navigation bar height to 80px
- [ ] Add labels below icons ("Home", "Topics", "Calendar", "Settings")
- [ ] Update selected icon color to Figma blue when theme is active
- [ ] Add subtle top border/shadow
- [ ] Use 12px font for labels
- [ ] Icon size: 24px
- [ ] Active state: blue icon + blue text
- [ ] Inactive state: gray icon + gray text

**Design Specs:**
```
Height: 80px (60px content + 20px safe area)
Icon size: 24px
Label font: 12px, medium weight
Spacing: 4px between icon and label
Background: white (light) / #1F2937 (dark)
Active color: #007AFF or current theme primary
Inactive color: #8E8E93
```

**Testing:**
- Run app, check bottom navigation
- Tap each tab, verify:
  - Icon and label color changes
  - Navigation works correctly
  - Labels are visible and readable
- Test in both light and dark modes
- Test with different color schemes

**Acceptance Criteria:**
✅ Labels visible under all icons
✅ Active tab highlighted correctly
✅ Smooth transitions between tabs
✅ Works in light/dark mode
✅ No layout overflow issues

---

### **Milestone 2.2: Update App Bar (Top Navigation)** ⏱️ 30 min
**Files to modify:**
- All screen files with AppBar
- Create: `lib/widgets/common/figma_app_bar.dart`

**Changes:**
- [ ] Standardize AppBar height: 56px
- [ ] Remove or minimize elevation (use subtle bottom border instead)
- [ ] Back button: iOS-style chevron-left icon
- [ ] Title: 18px semibold, centered (iOS) or left-aligned (Android)
- [ ] Action buttons: 24px icons
- [ ] Background: matches scaffold background (no color difference)
- [ ] Bottom border: 1px, color: #E5E7EB (light) / #374151 (dark)

**Design Specs:**
```
Height: 56px
Title font: 18px, semibold
Back icon: Icons.chevron_left (iOS) / Icons.arrow_back (Android)
Actions: 24px icon size
Background: transparent/scaffold background
Bottom border: 1px solid divider color
```

**Testing:**
- Navigate through all screens
- Verify AppBar looks consistent
- Test back button navigation
- Test action buttons (search, add, etc.)
- Check both platforms (Android/iOS behavior)

**Acceptance Criteria:**
✅ Consistent AppBar across all screens
✅ Clean, minimal look with subtle border
✅ Back button works correctly
✅ Action buttons accessible

---

## **PHASE 3: BUTTONS & INTERACTIVE ELEMENTS**
*Update all buttons to match Figma style*

### **Milestone 3.1: Create Figma Button Components** ⏱️ 1 hour
**Files to create:**
- `lib/widgets/common/figma_button.dart`
- `lib/widgets/common/figma_outlined_button.dart`
- `lib/widgets/common/figma_text_button.dart`

**Changes:**
- [ ] **Primary Button:**
  - Height: 56px
  - Border radius: 24px (pill-shaped)
  - Font: 16px, semibold
  - Padding: 24px horizontal
  - Shadow: 0 4px 12px rgba(primary, 0.2)
  - Active/pressed state

- [ ] **Outlined Button:**
  - Same height/radius as primary
  - Border: 2px solid
  - Transparent background
  - Text color matches border

- [ ] **Text Button:**
  - Height: 48px
  - No background
  - No border
  - Text color: primary
  - Ripple effect on tap

**Design Specs:**
```dart
// Primary Button
height: 56px
borderRadius: 24px
fontSize: 16px
fontWeight: semibold
horizontalPadding: 24px
shadow: [0, 4, 12, rgba(primary, 0.2)]

// Outlined Button
height: 56px
borderRadius: 24px
borderWidth: 2px
fontSize: 16px

// Text Button
height: 48px
fontSize: 16px
```

**Testing:**
- Create test screen with all button variants
- Test tap states (normal, pressed, disabled)
- Test different widths (full-width, wrapped)
- Test with icons (leading/trailing)
- Test in light/dark modes

**Acceptance Criteria:**
✅ Buttons have rounded, modern appearance
✅ All states work (enabled, disabled, pressed)
✅ Icons display correctly
✅ Smooth animations

---

### **Milestone 3.2: Update Settings Screen Buttons** ⏱️ 30 min
**Files to modify:**
- `lib/screens/settings_screen.dart`

**Changes:**
- [ ] Replace all ElevatedButton with FigmaButton
- [ ] Replace all OutlinedButton with FigmaOutlinedButton
- [ ] Replace all TextButton with FigmaTextButton
- [ ] Update "Backup Now" button
- [ ] Update "Restore from Backup" button
- [ ] Update "Connect/Disconnect" buttons

**Testing:**
- Open Settings screen
- Verify all buttons look consistent
- Test button functionality (backup, restore, connect)
- Check spacing and alignment

**Acceptance Criteria:**
✅ All buttons updated to Figma style
✅ Settings screen maintains functionality
✅ Buttons properly aligned and spaced

---

### **Milestone 3.3: Update All Other Screens' Buttons** ⏱️ 1 hour
**Files to modify:**
- `lib/screens/add_topic_screen.dart`
- `lib/screens/edit_topic_screen.dart`
- `lib/screens/topic_detail_screen.dart`
- `lib/screens/onboarding_screen.dart`
- `lib/screens/google_drive_connect_screen.dart`

**Changes:**
- [ ] Replace all buttons with Figma variants
- [ ] Ensure consistent spacing
- [ ] Update "Save" buttons
- [ ] Update "Add Topic" buttons
- [ ] Update "Mark as Reviewed" buttons

**Testing:**
- Navigate through each screen
- Test all button actions
- Verify visual consistency

**Acceptance Criteria:**
✅ All app buttons use Figma style
✅ No functionality broken
✅ Consistent visual appearance

---

## **PHASE 4: INPUT FIELDS & FORMS**
*Create branded input components*

### **Milestone 4.1: Create Figma TextField Component** ⏱️ 1 hour
**Files to create:**
- `lib/widgets/common/figma_text_field.dart`
- `lib/widgets/common/figma_text_form_field.dart`

**Changes:**
- [ ] **TextField Design:**
  - Height: 56px
  - Border radius: 12px
  - Border: 1.5px solid #E5E7EB (unfocused)
  - Border: 2px solid primary (focused)
  - Padding: 16px horizontal, 16px vertical
  - Font size: 16px
  - Label: floats above when focused
  - Helper text: 12px below field
  - Error state: red border + red helper text
  - Prefix/suffix icon support

**Design Specs:**
```dart
height: 56px
borderRadius: 12px
fontSize: 16px
contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)
border: {
  unfocused: 1.5px solid #E5E7EB
  focused: 2px solid primary
  error: 2px solid #EF4444
}
labelStyle: 14px, raised above when focused
hintStyle: 16px, #9CA3AF
helperStyle: 12px, #6B7280
errorStyle: 12px, #EF4444
```

**Testing:**
- Create test form with various inputs
- Test focus/unfocus states
- Test error validation
- Test with/without labels
- Test prefix/suffix icons
- Test multiline inputs

**Acceptance Criteria:**
✅ Clean, modern input appearance
✅ Smooth focus animations
✅ Validation errors display correctly
✅ Works with Form validation

---

### **Milestone 4.2: Update Add/Edit Topic Forms** ⏱️ 45 min
**Files to modify:**
- `lib/screens/add_topic_screen.dart`
- `lib/screens/edit_topic_screen.dart`

**Changes:**
- [ ] Replace TextField with FigmaTextField
- [ ] Update form layout spacing
- [ ] Add proper labels and hints
- [ ] Implement validation errors with new styling

**Testing:**
- Open Add Topic screen
- Fill out form, test validation
- Test save functionality
- Open Edit Topic screen
- Verify editing works
- Test form validation

**Acceptance Criteria:**
✅ Forms use Figma-style inputs
✅ Validation works correctly
✅ Form submission successful
✅ Error messages display properly

---

## **PHASE 5: CARDS & LISTS**
*Update card styling and list items*

### **Milestone 5.1: Update Card Components** ⏱️ 45 min
**Files to modify:**
- `lib/constants/design_system.dart` (cardDecoration methods)
- `lib/widgets/branded/branded_card.dart` (if exists)

**Changes:**
- [ ] Update card border radius to 12px
- [ ] Update shadow: 0 2px 8px rgba(0,0,0,0.08)
- [ ] Padding: 20px (increased from 16px)
- [ ] Add pressed state for tappable cards
- [ ] Background: white (light) / #1F2937 (dark)

**Design Specs:**
```dart
borderRadius: 12px
padding: 20px
shadow: [
  BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 8,
    offset: Offset(0, 2),
  )
]
background: {
  light: #FFFFFF
  dark: #1F2937
}
```

**Testing:**
- Check all screens with cards
- Verify shadow is visible but subtle
- Test tap effects on interactive cards
- Check spacing inside cards

**Acceptance Criteria:**
✅ Cards have modern, clean appearance
✅ Shadows are subtle and professional
✅ Consistent padding across all cards

---

### **Milestone 5.2: Update List Items** ⏱️ 1 hour
**Files to modify:**
- `lib/screens/topics_list_screen.dart`
- `lib/widgets/common/topic_card.dart` (if exists)

**Changes:**
- [ ] Update ListTile height to 72px minimum
- [ ] Icon container: 40x40px, 8px radius
- [ ] Title: 16px semibold
- [ ] Subtitle: 14px regular, gray color
- [ ] Trailing icons: 20px
- [ ] Divider: 1px, only between items, not at edges
- [ ] Add tap ripple effect
- [ ] Padding: 16px horizontal, 12px vertical

**Design Specs:**
```dart
minHeight: 72px
horizontalPadding: 16px
verticalPadding: 12px
leadingIcon: {
  size: 40x40px
  radius: 8px
  iconSize: 20px
}
title: 16px semibold
subtitle: 14px regular, #6B7280
trailing: 20px icon size
divider: 1px solid #E5E7EB
```

**Testing:**
- Open Topics List screen
- Scroll through topics
- Tap topics to open details
- Check icon alignment
- Verify dividers appear correctly

**Acceptance Criteria:**
✅ List items properly spaced
✅ Icons aligned and sized correctly
✅ Text hierarchy clear
✅ Dividers subtle but visible

---

## **PHASE 6: MODALS & BOTTOM SHEETS**
*Create branded modal components*

### **Milestone 6.1: Create Figma Bottom Sheet** ⏱️ 1 hour
**Files to create:**
- `lib/widgets/common/figma_bottom_sheet.dart`

**Changes:**
- [ ] Top border radius: 20px
- [ ] Handle bar at top: 36x4px, centered, gray
- [ ] Padding: 24px
- [ ] Background: white (light) / #1F2937 (dark)
- [ ] Drag to dismiss gesture
- [ ] Smooth animations

**Design Specs:**
```dart
topBorderRadius: 20px
handleBar: {
  width: 36px
  height: 4px
  color: #D1D5DB
  topMargin: 8px
}
padding: 24px
background: scaffold background
```

**Testing:**
- Create test bottom sheet
- Test drag to dismiss
- Test tap outside to dismiss
- Test with different content heights
- Test animations

**Acceptance Criteria:**
✅ Handle bar visible and centered
✅ Smooth drag gesture
✅ Proper content padding
✅ Clean animations

---

### **Milestone 6.2: Update Restore Backup Dialog** ⏱️ 30 min
**Files to modify:**
- `lib/widgets/dialogs/restore_backup_dialog.dart`

**Changes:**
- [ ] Convert from Dialog to FigmaBottomSheet
- [ ] Update button styles
- [ ] Add handle bar
- [ ] Update list of backups styling

**Testing:**
- Go to Settings → Restore from Backup
- Verify bottom sheet appears correctly
- Test selecting backup
- Test restore functionality

**Acceptance Criteria:**
✅ Restore dialog uses bottom sheet
✅ Maintains all functionality
✅ Improved visual appearance

---

### **Milestone 6.3: Create Figma Dialog Component** ⏱️ 45 min
**Files to create:**
- `lib/widgets/common/figma_dialog.dart`

**Changes:**
- [ ] Border radius: 16px
- [ ] Padding: 24px
- [ ] Title: 20px bold
- [ ] Content: 14px regular
- [ ] Action buttons at bottom
- [ ] Max width: 320px on phones
- [ ] Backdrop blur effect

**Design Specs:**
```dart
borderRadius: 16px
padding: 24px
maxWidth: 320px
title: 20px bold
content: 14px regular
actionsPadding: EdgeInsets.only(top: 24)
```

**Testing:**
- Test confirmation dialogs
- Test in different contexts
- Verify backdrop dismissal
- Check button layout

**Acceptance Criteria:**
✅ Modern dialog appearance
✅ Proper content spacing
✅ Buttons aligned correctly

---

## **PHASE 7: SPECIALIZED SCREENS**
*Update screen-specific components*

### **Milestone 7.1: Update Onboarding Screen** ⏱️ 1 hour
**Files to modify:**
- `lib/screens/onboarding_screen.dart`
- `lib/screens/google_drive_connect_screen.dart`

**Changes:**
- [ ] Add pagination dots if multi-screen
- [ ] Update button styles (already done in 3.3)
- [ ] Larger illustrations/icons (80-100px)
- [ ] Title: 28px bold
- [ ] Description: 16px regular
- [ ] Spacing: 32px between sections
- [ ] Skip button: top right, text button

**Testing:**
- Clear app data
- Open app to trigger onboarding
- Navigate through screens
- Test skip and get started

**Acceptance Criteria:**
✅ Clean, inviting onboarding flow
✅ Proper visual hierarchy
✅ Smooth transitions

---

### **Milestone 7.2: Update Calendar Screen** ⏱️ 1 hour
**Files to modify:**
- `lib/screens/calendar_screen.dart`

**Changes:**
- [ ] Update calendar widget styling
- [ ] Selected date: primary color circle
- [ ] Today: outlined circle
- [ ] Event dots: 6px below dates
- [ ] Month/year header: 20px semibold
- [ ] Day headers: 12px uppercase
- [ ] Spacing between date cells

**Testing:**
- Open Calendar screen
- Select different dates
- Verify topics load correctly
- Check visual clarity

**Acceptance Criteria:**
✅ Calendar easy to read
✅ Selected dates clearly marked
✅ Due dates visually distinct

---

### **Milestone 7.3: Update Topic Detail Screen** ⏱️ 1 hour
**Files to modify:**
- `lib/screens/topic_detail_screen.dart`

**Changes:**
- [ ] Update review buttons layout
- [ ] Add visual hierarchy to content
- [ ] Update spacing and padding
- [ ] Improve markdown rendering appearance
- [ ] Update action buttons

**Testing:**
- Open topic from list
- Test review buttons
- Test edit navigation
- Test delete confirmation

**Acceptance Criteria:**
✅ Clean content presentation
✅ Clear action buttons
✅ Maintains all functionality

---

### **Milestone 7.4: Update Settings Screen (Complete)** ⏱️ 45 min
**Files to modify:**
- `lib/screens/settings_screen.dart`

**Changes:**
- [ ] Section headers: 13px uppercase, semibold, #6B7280
- [ ] Icon containers: 36x36px, 10px radius, primary color at 10% opacity
- [ ] Update switches to Cupertino style
- [ ] Improved spacing between sections (32px)
- [ ] Card-based sections with proper padding

**Testing:**
- Navigate through all settings
- Toggle all switches
- Test all navigation items
- Verify Google Drive section

**Acceptance Criteria:**
✅ Professional settings layout
✅ Clear visual hierarchy
✅ All settings functional

---

## **PHASE 8: POLISH & REFINEMENTS**
*Final touches and consistency*

### **Milestone 8.1: Update Empty States** ⏱️ 45 min
**Files to modify:**
- All screens with empty states

**Changes:**
- [ ] Illustration/icon: 120px
- [ ] Title: 20px semibold
- [ ] Description: 14px regular, gray
- [ ] Action button below
- [ ] Vertical spacing: 24px

**Testing:**
- Trigger empty states on all screens
- Verify visual consistency
- Test action buttons

**Acceptance Criteria:**
✅ Consistent empty state design
✅ Clear call-to-action
✅ Professional appearance

---

### **Milestone 8.2: Add Loading States** ⏱️ 30 min
**Files to modify:**
- Create: `lib/widgets/common/figma_loading_indicator.dart`

**Changes:**
- [ ] Circular progress: primary color
- [ ] Shimmer loading for lists
- [ ] Skeleton screens for cards
- [ ] Loading overlay for full-screen

**Testing:**
- Test all loading states
- Verify smooth animations
- Check dark mode appearance

**Acceptance Criteria:**
✅ Professional loading indicators
✅ Smooth animations
✅ Consistent styling

---

### **Milestone 8.3: Accessibility & Final Review** ⏱️ 1 hour
**Files to review:**
- All modified files

**Changes:**
- [ ] Verify color contrast ratios (WCAG AA)
- [ ] Add semantic labels where missing
- [ ] Test with screen reader
- [ ] Verify touch target sizes (minimum 44x44)
- [ ] Test font scaling
- [ ] Dark mode final check

**Testing:**
- Enable TalkBack/VoiceOver
- Navigate through app
- Test with large text size
- Verify all colors meet contrast requirements

**Acceptance Criteria:**
✅ WCAG AA compliance
✅ Screen reader friendly
✅ Works with accessibility settings

---

## **FINAL MILESTONE: Documentation & Handoff**

### **Milestone 9.1: Update Design Documentation** ⏱️ 30 min
**Files to create/update:**
- `docs/design_system.md`
- `docs/component_library.md`

**Changes:**
- [ ] Document all new components
- [ ] Add usage examples
- [ ] Screenshot library
- [ ] Migration notes

**Acceptance Criteria:**
✅ Complete design system documentation
✅ Component usage examples
✅ Visual reference guide

---

## **TESTING CHECKLIST** (After All Milestones)

### Functional Testing:
- [ ] All existing features work correctly
- [ ] No regressions in functionality
- [ ] Google Drive sync works
- [ ] Notifications work
- [ ] Spaced repetition scheduling correct
- [ ] Data persistence works

### Visual Testing:
- [ ] Light mode looks correct
- [ ] Dark mode looks correct
- [ ] All color schemes work
- [ ] Consistent spacing throughout
- [ ] No layout overflow issues
- [ ] Proper alignment everywhere

### Platform Testing:
- [ ] Android appearance correct
- [ ] iOS appearance correct (if applicable)
- [ ] Tablet layout works
- [ ] Different screen sizes work

### Performance Testing:
- [ ] No animation jank
- [ ] Smooth scrolling
- [ ] Fast screen transitions
- [ ] No memory leaks

---

## **ROLLBACK PLAN**

For each milestone:
1. **Create git branch**: `feature/figma-milestone-X.X`
2. **Commit after completion**: Clear commit message
3. **Test thoroughly** before merging
4. **Keep previous version** in separate branch

If issues arise:
```bash
git checkout main
git branch -D feature/figma-milestone-X.X
```

---

## **TIME ESTIMATES**

| Phase | Milestones | Est. Time | Priority |
|-------|-----------|-----------|----------|
| Phase 1 | 1.1 - 1.2 | 45 min | High |
| Phase 2 | 2.1 - 2.2 | 1h 15min | High |
| Phase 3 | 3.1 - 3.3 | 2h 30min | High |
| Phase 4 | 4.1 - 4.2 | 1h 45min | Medium |
| Phase 5 | 5.1 - 5.2 | 1h 45min | Medium |
| Phase 6 | 6.1 - 6.3 | 2h 15min | Medium |
| Phase 7 | 7.1 - 7.4 | 3h 45min | Low |
| Phase 8 | 8.1 - 8.3 | 2h 15min | Low |
| Phase 9 | 9.1 | 30 min | Low |
| **TOTAL** | **27 milestones** | **~16 hours** | - |

---

## **SUCCESS CRITERIA**

✅ All screens match Figma aesthetic
✅ No functionality broken
✅ Improved user experience
✅ Consistent design language
✅ Accessible and performant
✅ Documentation complete

---

## **NEXT STEPS**

1. ✅ Review this plan
2. ✅ Confirm milestone order
3. ✅ Start with Phase 1, Milestone 1.1
4. ✅ Test each milestone before proceeding
5. ✅ Create git branches for each phase
6. ✅ Document any deviations or issues

**Ready to start when you give the green light!** 🚀
