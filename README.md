# Nen Net

A high-performance, statically allocated HTTP and TCP framework for Zig that provides zero-allocation networking with predictable performance.

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

```bash
# Run all tests
zig build test

# Run specific test categories
zig build test-unit
zig build test-integration
zig build test-performance

# Run examples
zig build examples
```

## 📈 Benchmarks

```bash
# Run performance benchmarks
zig build benchmark

# Run memory usage tests
zig build test-memory

# Run stress tests
zig build test-stress
```

## 🤝 Contributing

Contributions are welcome! Please see CONTRIBUTING.md for guidelines.

## 📄 License

MIT License - see LICENSE file for details.

## 🆘 Support

- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Documentation**: [docs.nen-net.com](https://docs.nen-net.com)

---

**Built with ❤️ by the Nen team**
