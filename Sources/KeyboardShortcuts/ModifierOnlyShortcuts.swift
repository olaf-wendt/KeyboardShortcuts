#if os(macOS)
import AppKit
import Carbon.HIToolbox

extension KeyboardShortcuts {
    /// Extension to handle modifier-only shortcuts
    public struct ModifierOnlyShortcut: Hashable, Codable, Sendable {
        public let modifiers: NSEvent.ModifierFlags
        
        public init(modifiers: NSEvent.ModifierFlags) {
            self.modifiers = modifiers
        }
        
        /// Initialize from a key event
        public init?(event: NSEvent) {
            guard event.isKeyEvent, event.keyCode == 0 else {
                return nil
            }
            
            self.modifiers = event.modifierFlags
        }
        
        // Implement Hashable
        public func hash(into hasher: inout Hasher) {
            hasher.combine(modifiers.rawValue)
        }
        
        // Implement Codable
        private enum CodingKeys: String, CodingKey {
            case modifiers
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let rawValue = try container.decode(UInt.self, forKey: .modifiers)
            self.modifiers = NSEvent.ModifierFlags(rawValue: rawValue)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(modifiers.rawValue, forKey: .modifiers)
        }
    }
}

extension KeyboardShortcuts.Shortcut {
    /// Initialize from a modifier-only shortcut
    public init(_ modifierShortcut: KeyboardShortcuts.ModifierOnlyShortcut) {
        self.init(
            carbonKeyCode: 0, // No key code for modifier-only
            carbonModifiers: modifierShortcut.modifiers.carbon
        )
    }
    
    /// Check if this is a modifier-only shortcut
    public var isModifierOnly: Bool {
        carbonKeyCode == 0 && !modifiers.isEmpty
    }
}
#endif
