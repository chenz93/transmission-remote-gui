import AppKit

/// Compile with the production TorrentTextCell.swift; no daemon or saved settings needed.
@main
struct TextCellLayoutTests {
    @MainActor
    static func main() {
        _ = NSApplication.shared
        var checks = 0
        func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
            precondition(condition(), message)
            checks += 1
        }

        let samples = ["A long torrent name with spaces — episode 01.mkv", "做种中", "Seeding", "Feltöltés",
                       "10.54 GB", "0 (103)", "2026/10/24 15:00", "—"]
        let cell = TorrentTextCell(frame: NSRect(x: 0, y: 0, width: 180, height: 22))
        let field = cell.label
        expect(cell.textField === field, "NSTableCellView exposes its label to AppKit")
        // Every supported zoom step (80–250%), plus fractional and oversized cases.
        let scales = (8...25).map { CGFloat($0) / 10 } + [1.25, 3]
        for scale in scales {
            for width: CGFloat in [50, 180, 500] {
                for monospaced in [false, true] {
                    for alignment: NSTextAlignment in [.left, .right] {
                        for sample in samples {
                            // Reconfigure the SAME view to cover reuse and live font/row-size changes.
                            cell.frame.size = NSSize(width: width, height: (22 * scale).rounded())
                            field.font = monospaced
                                ? .monospacedDigitSystemFont(ofSize: 12 * scale, weight: .regular)
                                : .systemFont(ofSize: 12 * scale)
                            field.stringValue = sample
                            field.alignment = alignment
                            field.textColor = .secondaryLabelColor
                            field.toolTip = sample
                            cell.layoutSubtreeIfNeeded()
                            expect(abs(field.frame.midY - cell.bounds.midY) < 0.01, "Label stays vertically centered")
                            expect(abs(field.frame.height - field.intrinsicContentSize.height) < 0.01,
                                   "Label keeps its natural single-line height")
                            expect(abs(field.frame.minX) < 0.01 && abs(field.frame.width - width) < 0.01,
                                   "Label uses the full column width: expected \(width), cell \(cell.frame), label \(field.frame), insets \(field.alignmentRectInsets)")
                            expect(field.frame.minY >= 0 && field.frame.maxY <= cell.bounds.maxY,
                                   "Text fits inside the fixed row")
                            expect(!cell.hasAmbiguousLayout && !field.hasAmbiguousLayout, "Layout is unambiguous")
                            expect(field.alignment == alignment && field.stringValue == sample,
                                   "Horizontal alignment and content are preserved")
                        }
                    }
                }
            }
        }
        expect(field.lineBreakMode == .byTruncatingTail && field.cell?.usesSingleLineMode == true,
               "Long names remain single-line and tail-truncated")
        expect(field.textColor == .secondaryLabelColor && field.toolTip == "—", "Styling and tooltips survive reuse")
        let table = MenuTable()
        table.addSubview(cell)
        for type: NSEvent.EventType in [.rightMouseDown, .leftMouseDown] {
            let event = NSEvent.mouseEvent(with: type, location: .zero,
                modifierFlags: type == .leftMouseDown ? .control : [], timestamp: 0,
                windowNumber: 0, context: nil, eventNumber: 0, clickCount: 1, pressure: 1)!
            expect(cell.menu(for: event) === table.rowMenu, "Contextual clicks reach the table's row menu")
        }
        print("\(checks) text-cell layout checks passed")
    }
}

@MainActor
private final class MenuTable: NSTableView {
    let rowMenu = NSMenu()
    override func menu(for event: NSEvent) -> NSMenu? { rowMenu }
}
