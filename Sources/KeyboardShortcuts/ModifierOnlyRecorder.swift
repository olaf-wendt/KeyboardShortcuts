#if os(macOS)
import AppKit
import Carbon.HIToolbox

/// A recorder that supports modifier-only shortcuts
public final class ModifierOnlyRecorder: NSControl {
    private var eventMonitor: LocalEventMonitor?
    private var showsCancelButton = false
    private var shortcut: KeyboardShortcuts.Shortcut?
    
    public var onShortcutChange: ((KeyboardShortcuts.Shortcut?) -> Void)?
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        wantsLayer = true
        layer?.cornerRadius = 6.0
        layer?.borderWidth = 1.0
        layer?.borderColor = NSColor.controlAccentColor.cgColor
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Draw the current shortcut
        if let shortcut = shortcut {
            let text = "\(shortcut)"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
                .foregroundColor: NSColor.labelColor
            ]
            let size = text.size(withAttributes: attributes)
            let point = NSPoint(
                x: (bounds.width - size.width) / 2,
                y: (bounds.height - size.height) / 2
            )
            text.draw(at: point, withAttributes: attributes)
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        startRecording()
    }
    
    public func startRecording() {
        eventMonitor = LocalEventMonitor(events: [.keyDown, .leftMouseUp, .rightMouseUp]) { [weak self] event in
            guard let self else { return event }
            
            if event.type == .leftMouseUp || event.type == .rightMouseUp {
                if !bounds.contains(convert(event.locationInWindow, from: nil)) {
                    stopRecording()
                }
                return event
            }
            
            guard event.isKeyEvent else { return event }
            
            // Handle escape key
            if event.keyCode == kVK_Escape {
                stopRecording()
                return event
            }
            
            // Handle modifier-only shortcuts
            let shortcut: KeyboardShortcuts.Shortcut?
            if event.modifiers.isEmpty && event.keyCode == 0 {
                if let modifierShortcut = KeyboardShortcuts.ModifierOnlyShortcut(event: event) {
                    shortcut = KeyboardShortcuts.Shortcut(modifierShortcut)
                } else {
                    shortcut = nil
                }
            } else {
                shortcut = KeyboardShortcuts.Shortcut(event: event)
            }
            
            guard let validShortcut = shortcut else {
                NSSound.beep()
                return event
            }
            
            self.shortcut = validShortcut
            onShortcutChange?(validShortcut)
            needsDisplay = true
            stopRecording()
            
            return event
        }
        
        eventMonitor?.start()
    }
    
    public func stopRecording() {
        eventMonitor?.stop()
        eventMonitor = nil
    }
    
    public func clear() {
        shortcut = nil
        needsDisplay = true
        onShortcutChange?(nil)
    }
}
#endif
