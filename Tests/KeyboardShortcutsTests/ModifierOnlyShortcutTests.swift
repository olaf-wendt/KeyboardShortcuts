import XCTest
@testable import KeyboardShortcuts

final class ModifierOnlyShortcutTests: XCTestCase {
    func testModifierOnlyShortcut() {
        let recorder = ModifierOnlyShortcutRecorder(name: .init("testModifierOnly"))
        
        // Simulate fn key press
        let fnEvent = NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: [.function],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "",
            charactersIgnoringModifiers: "",
            isARepeat: false,
            keyCode: 0
        )!
        
        let fnShortcut = KeyboardShortcuts.Shortcut(event: fnEvent)
        XCTAssertNotNil(fnShortcut, "Function key should be recognized as a valid shortcut")
        
        // Simulate control key press
        let controlEvent = NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: [.control],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "",
            charactersIgnoringModifiers: "",
            isARepeat: false,
            keyCode: 0
        )!
        
        let controlShortcut = KeyboardShortcuts.Shortcut(event: controlEvent)
        XCTAssertNotNil(controlShortcut, "Control key should be recognized as a valid shortcut")
        
        // Simulate command key press
        let commandEvent = NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: [.command],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "",
            charactersIgnoringModifiers: "",
            isARepeat: false,
            keyCode: 0
        )!
        
        let commandShortcut = KeyboardShortcuts.Shortcut(event: commandEvent)
        XCTAssertNotNil(commandShortcut, "Command key should be recognized as a valid shortcut")
    }
}
