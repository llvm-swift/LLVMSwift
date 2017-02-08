import Foundation

/// Represents a stream that can write text with a specific set of ANSI colors
protocol ColoredStream: TextOutputStream {
    mutating func write(_ string: String, with: [ANSIColor])
}

extension ColoredStream {
    /// Default conformance to TextOutputStream
    mutating func write(_ string: String) {
        write(string, with: [])
    }
}

/// An output stream that prints to an underlying stream including ANSI color
/// codes.
class ColoredANSIStream<StreamTy: TextOutputStream>: ColoredStream {

    typealias StreamType = StreamTy

    var currentColors = [ANSIColor]()
    var stream: StreamType
    let colored: Bool

    /// Creates a new ColoredANSIStream that prints to an underlying stream.
    ///
    /// - Parameters:
    ///   - stream: The underlying stream
    ///   - colored: Whether to provide any colors or to pass text through
    ///              unmodified. Set this to false and ColoredANSIStream is
    ///              a transparent wrapper.
    init(_ stream: inout StreamType, colored: Bool = true) {
        self.stream = stream
        self.colored = colored
    }

    /// Initializes with a stream, always colored.
    ///
    /// - Parameter stream: The underlying stream receiving writes.
    required init(_ stream: inout StreamType) {
        self.stream = stream
        self.colored = true
    }

    /// Adds a color to the in-progress colors.
    func addColor(_ color: ANSIColor) {
        guard colored else { return }
        stream.write(color.rawValue)
        currentColors.append(color)
    }

    /// Resets this stream back to the default color.
    func reset() {
        if currentColors.isEmpty { return }
        stream.write(ANSIColor.reset.rawValue)
        currentColors = []
    }

    /// Sets the current ANSI color codes to the passed-in colors.
    func setColors(_ colors: [ANSIColor]) {
        guard colored else { return }
        reset()
        for color in colors {
            stream.write(color.rawValue)
        }
        currentColors = colors
    }

    /// Writes the string to the output with the provided colors.
    ///
    /// - Parameters:
    ///   - string: The string to write
    ///   - colors: The colors used on the string
    func write(_ string: String, with colors: [ANSIColor]) {
        self.setColors(colors)
        stream.write(string)
        self.reset()
    }
}
