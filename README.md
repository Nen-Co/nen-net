# Nen Net

A high-performance, statically allocated HTTP and TCP framework for Zig that provides zero-allocation networking with predictable performance.

> **✅ Zig 0.15.1 Compatible** - Fully tested and compatible with the latest Zig release

## 🚀 Features

- **Zero Dynamic Allocation**: Uses static memory pools for predictable performance
- **Inline Functions**: Critical operations are marked inline for maximum performance
- **Static Connection Pools**: Pre-allocated connection and buffer pools
- **HTTP Server**: High-performance HTTP/1.1 server with static routing
- **TCP Framework**: Low-level TCP socket management
- **WebSocket Support**: Built-in WebSocket handling
- **Connection Batching**: Efficient connection management inspired by nen-db patterns
- **Performance Monitoring**: Built-in benchmarking and performance tracking

## 🏗️ Architecture

The framework is designed around several core principles:

1. **Static Memory**: All operations use pre-allocated buffers
2. **Inline Performance**: Critical functions are marked inline
3. **Connection Pooling**: Pre-allocated connection objects
4. **Zero Copy**: Minimize memory copying where possible
5. **Batching**: Group operations for efficiency

## 📦 Installation

### Requirements

- **Zig 0.15.1** or later
- **Git** for cloning the repository

### Quick Start

```bash
# Clone the repository
git clone https://github.com/Nen-Co/nen-net.git
cd nen-net

# Build the library
zig build

# Run tests
zig build test

# Run examples
zig build examples

# Run benchmarks
zig build benchmark
```

### Build Commands

```bash
# Main build
zig build

# Run all tests
zig build test

# Run specific test suites
zig build test-integration
zig build test-perf
zig build test-memory
zig build test-stress

# Run examples
zig build examples

# Run performance benchmarks
zig build benchmark

# Run all tests (includes all test suites)
zig build test-all

# Check code formatting
zig fmt --check .
```

## 🎯 Usage

### Basic HTTP Server

```zig
const net = @import("nen-net");

// Create server with static configuration
var server = net.HttpServer.init(.{
    .port = 8080,
    .max_connections = 1000,
    .request_buffer_size = 8192,
    .response_buffer_size = 16384,
});

// Add routes
try server.addRoute(.GET, "/api/users", handleUsers);
try server.addRoute(.POST, "/api/users", createUser);

// Start server
try server.start();
```

### TCP Client

```zig
const net = @import("nen-net");

// Create TCP client
var client = net.TcpClient.init(.{
    .host = "localhost",
    .port = 8080,
    .buffer_size = 4096,
});

// Connect
try client.connect();

// Send data
try client.send("Hello, Server!");

// Receive response
const response = try client.receive();
```

### WebSocket Server

```zig
const net = @import("nen-net");

// Create WebSocket server
var ws_server = net.WebSocketServer.init(.{
    .port = 8081,
    .max_connections = 100,
});

// Handle WebSocket connections
try ws_server.onConnect(handleWebSocketConnect);
try ws_server.onMessage(handleWebSocketMessage);

// Start server
try ws_server.start();
```

## 🔧 Configuration

```zig
// Server configuration
pub const ServerConfig = struct {
    port: u16 = 8080,
    max_connections: u32 = 1000,
    request_buffer_size: usize = 8192,
    response_buffer_size: usize = 16384,
    connection_timeout_ms: u32 = 30000,
    keep_alive_timeout_ms: u32 = 60000,
    max_request_size: usize = 1048576, // 1MB
    enable_compression: bool = true,
    enable_tls: bool = false,
};
```

## 📊 Performance Targets

- **Connection Handling**: 100,000+ concurrent connections
- **Request Processing**: 1M+ requests/second
- **Memory Overhead**: <5% memory overhead
- **Startup Time**: <10ms initialization
- **Latency**: <1ms request processing

## 🔗 Integration with Nen Ecosystem

This framework is designed to work seamlessly with other Nen libraries:

- **nen-io**: I/O operations and validation
- **nen-db**: Database operations and batching patterns
- **nen-json**: JSON parsing and manipulation
- **nen-cache**: Caching layer integration

## 🧪 Testing

The project includes comprehensive test suites:

```bash
# Run all unit tests
zig build test

# Run specific test suites
zig build test-integration    # Integration tests
zig build test-perf          # Performance tests
zig build test-memory        # Memory tests
zig build test-stress        # Stress tests

# Run all tests (includes all suites)
zig build test-all

# Run examples
zig build examples
```

### Test Coverage

- **Unit Tests**: Core functionality and inline functions
- **Integration Tests**: End-to-end HTTP/TCP workflows
- **Performance Tests**: Timing and performance monitoring
- **Memory Tests**: Memory allocation and efficiency
- **Stress Tests**: High-load and edge case scenarios

## 📈 Benchmarks

Performance benchmarks demonstrate the efficiency of nen-net's static allocation approach:

```bash
# Run performance benchmarks
zig build benchmark

# Run memory usage tests
zig build test-memory

# Run stress tests
zig build test-stress
```

### Benchmark Results

The benchmarks compare nen-net's static allocation approach against standard library dynamic allocation:

- **Memory Allocation**: 800x+ speedup with static allocation
- **Function Calls**: 1.5x speedup with inline functions
- **Buffer Operations**: 600x+ speedup with pre-allocated buffers
- **Configuration Setup**: 2x speedup with structured configuration

## 🔧 Compatibility

### Zig Version Support

- **Zig 0.15.1**: ✅ Fully supported and tested
- **Zig 0.14.x**: ⚠️ May work but not officially supported
- **Zig 0.13.x and earlier**: ❌ Not supported

### Platform Support

- **Linux**: ✅ Fully supported
- **macOS**: ✅ Fully supported  
- **Windows**: ✅ Fully supported
- **FreeBSD**: ✅ Supported
- **NetBSD**: ✅ Supported

### CI/CD Status

The project includes comprehensive CI/CD workflows:

- **Linux Build**: ✅ Automated testing on Ubuntu
- **macOS Build**: ✅ Automated testing on macOS
- **Windows Build**: ✅ Automated testing on Windows
- **Format Check**: ✅ Automated code formatting validation
- **Test Coverage**: ✅ All test suites run automatically

## 🤝 Contributing

Contributions are welcome! Please see CONTRIBUTING.md for guidelines.

### Development Setup

```bash
# Clone and setup
git clone https://github.com/Nen-Co/nen-net.git
cd nen-net

# Install Zig 0.15.1
# Follow instructions at https://ziglang.org/download/

# Verify installation
zig version  # Should show 0.15.1

# Run tests before contributing
zig build test-all
zig fmt --check .
```

## 📄 License

MIT License - see LICENSE file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/Nen-Co/nen-net/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Nen-Co/nen-net/discussions)
- **Documentation**: [docs.nen-net.com](https://docs.nen-net.com)
- **CI/CD Status**: [GitHub Actions](https://github.com/Nen-Co/nen-net/actions)

---

**Built with ❤️ by the Nen team**
