# Modifier-Only Shortcuts Extension

This extension adds support for single modifier key shortcuts (e.g., just Command, just Control) to the KeyboardShortcuts package.

## Usage

### 1. Defining Shortcuts

You can define shortcuts that support both single modifier keys and regular key combinations:

```swift
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleFeature = Self("toggleFeature", default: .init(modifiers: [.command]))
}

// Usage
KeyboardShortcuts.onKeyDown(for: .toggleFeature) {
    print("Shortcut triggered!")
}
```

### 2. Using the Recorder in a View

Here's how to integrate the recorder into a SwiftUI view:

```swift
import SwiftUI
import KeyboardShortcuts

struct ShortcutSettingsView: View {
    @State private var isRecording = false
    
    var body: some View {
        VStack {
            ModifierOnlyShortcutRecorder(name: .toggleFeature)
                .frame(width: 200, height: 24)
                // Supports both modifier-only and regular key combinations
            
            Text("Press shortcut to record")
                .foregroundColor(.secondary)
        }
    }
}
```

### 3. Code Structure

The extension consists of several files:

#### Tests/KeyboardShortcutsTests/ModifierOnlyShortcutTests.swift
- Comprehensive test coverage for modifier-only shortcuts
- Tests for fn, control, and command key recognition
- Validation of shortcut recording and clearing

#### ModifierOnlyExtension.swift

#### RecorderCocoa+ModifierOnly.swift
- Extends RecorderCocoa with modifier-only shortcut handling
- Implements key event monitoring for modifier-only shortcuts
- Handles event filtering and validation
- Manages the clear button functionality
- Maintains UI state during recording

#### ModifierOnlyExtension.swift
- Contains the `ModifierOnlyRecorder` class
- Handles event monitoring and cleanup
- Implements the modifier-only recording logic
- Extends the existing RecorderCocoa functionality

#### ModifierOnlyShortcuts.swift
- Defines the `ModifierOnlyShortcut` struct
- Adds extension methods to `Shortcut` for modifier-only support
- Implements validation and conflict checking
- Extends RecorderCocoa with modifier-only handling

### API Reference

#### ModifierOnlyShortcut
- `init(modifiers: NSEvent.ModifierFlags)`
- `toShortcut() -> Shortcut`

#### Shortcut Extensions
- `init(modifiers: NSEvent.ModifierFlags)`
- `var isModifierOnly: Bool`
- `var isValidModifierOnly: Bool`

#### RecorderCocoa Extensions
- `func handleModifierOnlyShortcut(event: NSEvent) -> Bool`

### Notes
- Supported modifier keys: Command, Control, Option, Shift, Function
- Shift alone is not allowed as a shortcut
- Modifier-only shortcuts are validated against system and menu conflicts
- Includes a clear button for resetting shortcuts
- Proper layout constraints ensure consistent UI appearance
