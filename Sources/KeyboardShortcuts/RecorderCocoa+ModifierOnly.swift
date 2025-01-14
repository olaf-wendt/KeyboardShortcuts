#if os(macOS)
import AppKit
import Carbon.HIToolbox

public class ModifierOnlyShortcutRecorder: NSView {
    private let recorder: KeyboardShortcuts.RecorderCocoa
    private var eventMonitor: Any?
    private let clearButton: NSButton
    
    /// Callback when the shortcut changes
    public var onChange: ((KeyboardShortcuts.Shortcut?) -> Void)?
    
    private var currentShortcut: KeyboardShortcuts.Shortcut? {
        didSet {
            onChange?(currentShortcut)
        }
    }
    
    public init(name: KeyboardShortcuts.Name) {
        clearButton = NSButton(title: "×", target: nil, action: nil)
        clearButton.bezelStyle = .roundRect
        clearButton.isBordered = false
        clearButton.isHidden = true
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        
        recorder = KeyboardShortcuts.RecorderCocoa(for: name)
        super.init(frame: .zero)
        
        setupModifierOnlyHandling()
        setupRecorder()
        setupClearButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupClearButton() {
        clearButton.target = self
        clearButton.action = #selector(handleClearButton)
        
        NSLayoutConstraint.activate([
            clearButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            clearButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 20),
            clearButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc private func handleClearButton() {
        recorder.clear()
        currentShortcut = nil
        clearButton.isHidden = true
    }
    
    private func setupRecorder() {
        addSubview(recorder)
        recorder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            recorder.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -4),
            recorder.topAnchor.constraint(equalTo: topAnchor),
            recorder.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupModifierOnlyHandling() {
        // Create a new event monitor that supports modifier-only shortcuts
        let newMonitor = LocalEventMonitor(events: [.keyDown, .leftMouseUp, .rightMouseUp]) { [weak self] event -> NSEvent? in
            guard let self else {
                return nil
            }

            let clickPoint = convert(event.locationInWindow, from: nil)
            let clickMargin = 3.0

            if
                event.type == .leftMouseUp || event.type == .rightMouseUp,
                !bounds.insetBy(dx: -clickMargin, dy: -clickMargin).contains(clickPoint)
            {
                blur()
                return event
            }

            guard event.isKeyEvent else {
                return nil
            }

            if
                event.modifiers.isEmpty,
                event.specialKey == .tab
            {
                blur()
                return event
            }

            if
                event.modifiers.isEmpty,
                event.keyCode == kVK_Escape
            {
                blur()
                return nil
            }

            if
                event.modifiers.isEmpty,
                event.specialKey == .delete
                    || event.specialKey == .deleteForward
                    || event.specialKey == .backspace
            {
                recorder.clear()
                return nil
            }

            // Handle both modifier-only and regular shortcuts
            let shortcut: KeyboardShortcuts.Shortcut?
            if event.modifiers.isEmpty && event.keyCode == 0 {
                shortcut = KeyboardShortcuts.ModifierOnlyShortcut(event: event).map { KeyboardShortcuts.Shortcut($0) }
            } else {
                shortcut = KeyboardShortcuts.Shortcut(event: event)
            }

            guard let validShortcut = shortcut else {
                NSSound.beep()
                return nil
            }

            if let menuItem = validShortcut.takenByMainMenu {
                recorder.blur()
                NSAlert.showModal(
                    for: recorder.window!,
                    title: String.localizedStringWithFormat("keyboard_shortcut_used_by_menu_item".localized, menuItem.title)
                )
                recorder.focus()
                return nil
            }

            if validShortcut.isDisallowed {
                recorder.blur()
                NSAlert.showModal(
                    for: recorder.window!,
                    title: "keyboard_shortcut_disallowed".localized
                )
                recorder.focus()
                return nil
            }

            if validShortcut.isTakenBySystem {
                recorder.blur()
                let modalResponse = NSAlert.showModal(
                    for: recorder.window!,
                    title: "keyboard_shortcut_used_by_system".localized,
                    message: "keyboard_shortcuts_can_be_changed".localized,
                    buttonTitles: [
                        "ok".localized,
                        "force_use_shortcut".localized
                    ]
                )
                recorder.focus()
                guard modalResponse == .alertSecondButtonReturn else {
                    return nil
                }
            }

            recorder.stringValue = "\(validShortcut)"
            currentShortcut = validShortcut
            clearButton.isHidden = false
            recorder.blur()

            return nil
        }.start()
    }
}
#endif
