import AppKit

/// Keep a single-line label at its natural height, centered in the fixed-height row.
/// Returning the label itself would stretch its text cell to the row's full height,
/// where NSTextField's default text drawing is top-aligned.
final class TorrentTextCell: NSTableCellView {
    let label = NSTextField(labelWithString: "")

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.cell?.usesSingleLineMode = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(label)
        textField = label
        // NSTextField anchors refer to its inset alignment rect. Compensate so its
        // frame (and horizontal text padding) stays identical to the old full-row label.
        let insets = label.alignmentRectInsets
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("TorrentTextCell is created programmatically")
    }

    /// Preserve right-click / Ctrl-click over both the label and its vertical padding.
    /// Like ProgressCell, a container must ask the table for its row context menu.
    override func menu(for event: NSEvent) -> NSMenu? {
        var view = superview
        while let v = view, !(v is NSTableView) { view = v.superview }
        return view?.menu(for: event)
    }
}
