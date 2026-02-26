# MCat

MCat is a macOS menu bar application that runs a TCP echo server. The name is a portmanteau of "Menu bar" and "cat" (as in netcat). When a TCP client sends text to the server, MCat echoes it back and displays the received text in the macOS menu bar.

## Features

- Runs as a menu bar-only app (no Dock icon, no window)
- TCP echo server powered by SwiftNIO
- Displays the last received message in the macOS menu bar
- Configurable host and port (default: `::0:9999`)
- Handles Unicode, emoji, and multi-byte text

## Requirements

- macOS 15.0+
- Xcode 26+
- Swift 6

## Build and Run

1. Open `MCat/MCat.xcodeproj` in Xcode.
2. Select the `MCat` scheme and a macOS target.
3. Build and run (Cmd+R).

The app launches into the menu bar -- look for the "MCat running on ::0:9999" status item at the top of your screen.

## Usage

Send text to the server with any TCP client. The text will be echoed back and displayed in the menu bar.

```bash
# Using netcat
echo "Hello" | nc localhost 9999

# Interactive session
nc localhost 9999
```

You can also use `telnet`, `socat`, or any TCP client library.

## Architecture

```
MCatApp (entry point)
  |
  +-- AppDelegate
  |     |-- Creates NSStatusItem (menu bar display)
  |     |-- Starts NCServer on a background thread
  |     |-- Observes NCServer.message via Combine ($message publisher)
  |
  +-- NCServer
        |-- ServerBootstrap (SwiftNIO) binds to host:port
        |-- EchoHandler (ChannelInboundHandler)
              |-- Reads incoming TCP data
              |-- Trims whitespace, updates server.message
              |-- Writes the text back to the client with a trailing newline
```

### Key Files

| File | Description |
|------|-------------|
| `MCat/MCat/MCatApp.swift` | App entry with `@main`, `AppDelegate` that wires the status item to the server |
| `MCat/MCat/NCServer.swift` | TCP echo server using SwiftNIO `ServerBootstrap` and `EchoHandler` |
| `MCat/MCat/MCatMenu.swift` | Stub SwiftUI view (unused) |
| `MCat/MCat/Info.plist` | Sets `LSUIElement=true` to hide the Dock icon |

### Dependencies

- [SwiftNIO](https://github.com/apple/swift-nio) -- Non-blocking, event-driven networking framework

## Testing

The project includes unit tests and end-to-end tests (15 tests total).

### Unit Tests (`MCatTests.swift`)

- Default and custom initialization of `NCServer`
- Message property updates
- Calling `stop()` before `start()` does not crash

### End-to-End Tests (`NCServerE2ETests.swift`)

Each test starts a real TCP server on a random ephemeral port and connects using BSD sockets:

- Echo of simple strings, Unicode, and emoji
- Whitespace-only and empty input returns `"Invalid or empty"`
- Trailing whitespace is trimmed
- Long string echo (1000 characters)
- Multiple sequential connections
- `server.message` is updated after echo

### Running Tests

```bash
# From the command line
xcodebuild test -project MCat/MCat.xcodeproj -scheme MCat -destination 'platform=macOS'

# Or use Cmd+U in Xcode
```

## License

See the project for license details.
