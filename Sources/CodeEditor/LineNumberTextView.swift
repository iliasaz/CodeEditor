//
// LineNumberTextView.swift
// LineNumberTextView
// https://github.com/raphaelhanneken/line-number-text-view
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Raphael Hanneken
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Cocoa

/// A NSTextView with a line number gutter attached to it.
public class LineNumberTextView: NSTextView {
    
    /// Holds the attached line number gutter.
    private var lineNumberGutter: LineNumberGutter?
    
    /// Holds the text color for the gutter. Available in the Inteface Builder.
    @IBInspectable public var gutterForegroundColor: NSColor? {
        didSet {
            if let gutter = self.lineNumberGutter,
               let color  = self.gutterForegroundColor {
                gutter.foregroundColor = color
            }
        }
    }
    
    /// Holds the background color for the gutter. Available in the Inteface Builder.
    @IBInspectable public var gutterBackgroundColor: NSColor? {
        didSet {
            if let gutter = self.lineNumberGutter,
               let color  = self.gutterBackgroundColor {
                gutter.backgroundColor = color
            }
        }
    }
        
    override public func awakeFromNib() {
        // Get the enclosing scroll view
        guard let scrollView = self.enclosingScrollView else {
            fatalError("Unwrapping the text views scroll view failed!")
        }
        
        if let gutterBG = self.gutterBackgroundColor,
           let gutterFG = self.gutterForegroundColor {
            self.lineNumberGutter = LineNumberGutter(withTextView: self, foregroundColor: gutterFG, backgroundColor: gutterBG)
        } else {
            self.lineNumberGutter = LineNumberGutter(withTextView: self)
        }
        
        scrollView.verticalRulerView  = self.lineNumberGutter
        scrollView.hasHorizontalRuler = false
        scrollView.hasVerticalRuler   = true
        scrollView.rulersVisible      = true
        self.addObservers()
    }
    
    /// Add observers to redraw the line number gutter, when necessary.
    internal func addObservers() {
        self.postsFrameChangedNotifications = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.drawGutter), name: NSView.frameDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.drawGutter), name: NSText.didChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.logTextkit1Switch), name: LineNumberTextView.didSwitchToNSLayoutManagerNotification, object: self)
    }
    
    /// Set needsDisplay of lineNumberGutter to true.
    @objc internal func drawGutter() {
        if let lineNumberGutter = self.lineNumberGutter {
            lineNumberGutter.needsDisplay = true
        }
    }
    
    @objc internal func logTextkit1Switch() {
        print("switched to Textkit1")
    }
    
    override public var drawsBackground: Bool {
        set {} // always return false, we'll draw the background
        get { return false }
    }
    
    var selectedLineRect: NSRect? {
        var textLineRects = [NSRect]()
        var textLineRect: NSRect?
        
        if #available(macOS 12, *),
           let textLayoutManager = self.textLayoutManager,
           let contentManager = textLayoutManager.textContentManager {
            guard let textRange = textLayoutManager.textSelections.first?.textRanges.first else { return nil }
            textLayoutManager.enumerateTextSegments(in: textRange, type: .standard, options: .headSegmentExtended) { _, rect, _, _ in
                textLineRects.append(rect)
                return false // first segment only
            }
            textLineRect = textLineRects.first
        } else {
            guard let layout = layoutManager, let container = textContainer else { return nil }
            if selectedRange().length > 0 { return nil }
            textLineRect = layout.boundingRect(forGlyphRange: selectedRange(), in: container)
        }
        return textLineRect
    }
    
    override public func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.setFillColor(backgroundColor.cgColor)
        context.fill(dirtyRect)
        
        if let textRect = selectedLineRect {
            let lineRect = NSRect(x: 0, y: textRect.origin.y + textRect.height/2.0, width: self.frame.width, height: textRect.height)
            context.setFillColor( currentLineColor.cgColor )
            context.fill(lineRect)
        }
        if let lineNumberGutter = self.lineNumberGutter {
            lineNumberGutter.needsDisplay = true
        }
        super.draw(dirtyRect)
    }
    
    var highlightingDelegate: LineHighlightingTextViewDelegate?
    
    //    var currentLineColor: NSColor = NSColor(calibratedRed: 0.96, green: 0.96, blue: 0.97, alpha: 1)
    var currentLineColor: NSColor = .unemphasizedSelectedTextBackgroundColor
    
    var selectionColor: NSColor {
        get { return selectedTextAttributes[NSAttributedString.Key.backgroundColor] as! NSColor }
        set { selectedTextAttributes[NSAttributedString.Key.backgroundColor] = newValue }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        setup()
    }
    
    private func setup() {
        selectionColor = NSColor(calibratedRed: 0.69, green: 0.84, blue: 1.0, alpha: 1.0)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func setSelectedRange(_ charRange: NSRange, affinity: NSSelectionAffinity, stillSelecting stillSelectingFlag: Bool) {
        super.setSelectedRange(charRange, affinity: affinity, stillSelecting: stillSelectingFlag)
        needsDisplay = true
        highlightingDelegate?.selectionNeedsDisplay()
    }
    
    override public func mouseDown(with event: NSEvent) {
        
        var point = convert(event.locationInWindow, from: nil)
        point.x -= 5.0
        point.y -= 8.0
        let nav = textLayoutManager!.textSelectionNavigation
        
        textLayoutManager!.textSelections = nav.textSelections(interactingAt: point,
                                                               inContainerAt: textLayoutManager!.documentRange.location,
                                                               anchors: [],
                                                               modifiers: [],
                                                               selecting: true,
                                                               bounds: .zero)
        super.mouseDown(with: event)
        // update selection range
//        print("selections: \(textLayoutManager!.textSelections)")
        if let selection = textLayoutManager!.textSelections.first?.textRanges.first,
           let textContentManager = textLayoutManager?.textContentManager {
            let location = textContentManager.offset(from: textContentManager.documentRange.location, to: selection.location)
            let length = textContentManager.offset(from: selection.location, to: selection.endLocation)
            let nsRange = NSRange(location: location, length: length)
//            print("selection: \(nsRange), point: \(point)")
            setSelectedRange(nsRange, affinity: self.selectionAffinity, stillSelecting: false)
        } else { print("if false") }
        print("range values \(selectedRanges.first?.rangeValue)")
        needsDisplay = true
    }
}


protocol LineHighlightingTextViewDelegate {
    func selectionNeedsDisplay()
}



