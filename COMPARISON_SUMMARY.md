# Nen-Net vs Standard Library - Quick Comparison

## TL;DR

**Nen-Net**: High-performance, statically allocated networking framework with inline functions
**Standard Library**: Low-level networking building blocks with dynamic allocation

## Key Differences

### 🚀 Performance
- **Nen-Net**: Targets 1M req/s, 100K concurrent connections, <1ms latency
- **Standard Library**: No performance guarantees, depends on implementation

### 💾 Memory Management
- **Nen-Net**: Zero dynamic allocation, fixed memory footprint
- **Standard Library**: Dynamic allocation, variable memory usage

### 🔧 API Level
- **Nen-Net**: High-level, unified API (HTTP + TCP + WebSocket)
- **Standard Library**: Low-level, separate modules for each protocol

### ⚡ Optimization
- **Nen-Net**: Critical functions marked `inline`, connection pooling
- **Standard Library**: Generic implementation, manual optimization required

## When to Use What

| Use Case | Choose |
|----------|---------|
| **High-performance production app** | Nen-Net ✅ |
| **Learning/prototyping** | Standard Library ✅ |
| **Embedded systems** | Nen-Net ✅ |
| **Custom protocols** | Standard Library ✅ |
| **Rapid development** | Nen-Net ✅ |
| **Low-level control** | Standard Library ✅ |

## Code Example

**Nen-Net (Simple):**
```zig
var server = try nen_net.quickServer(8080, &[_]nen_net.Route{
    .{ .method = "GET", .path = "/", .handler = homeHandler },
});
try server.start();
```

**Standard Library (Complex):**
```zig
var server = net.Server.init(.{});
while (true) {
    var connection = try server.accept();
    var http_server = http.Server.init(connection, read_buffer);
    var request = try http_server.receiveHead();
    // Manual handling...
}
```

## Run Benchmark

```bash
zig build benchmark
```

This will show actual performance differences between the two approaches.
