# Building WolfSSL for use in WebAssembly applications
Bringing WebAssembly (Wasm) support for WolfSSL with *WebAssembly system interface* (WASI) support for seamless interoperability with the underlying system.

### Requirements
It is expected that the [WASI-SDK](https://github.com/WebAssembly/wasi-sdk) is installed at the path `/opt/wasi-sdk`, or given via the variable `WASI_SDK_PATH`.

WolfSSL environment must have been configured using `./autogen.sh`.

### Build
The project creates a sample application `wolfssl.wasm`, that executes within a Wasm runtime, such as [WAMR](https://github.com/bytecodealliance/wasm-micro-runtime), [Wasmtime](https://github.com/bytecodealliance/wasmtime), or [Wasmer](https://github.com/wasmerio/wasmer).

To create the sample application, simply call make:

`make -f wasm_static.mk all HAVE_WOLFSSL_BENCHMARK=1 HAVE_WOLFSSL_TEST=1 HAVE_WASI_SOCKET=1`

To clean the static library and compiled objects use the provided clean script:

`make -f wasm_static.mk clean`

### Customization
- To enable debugging output, specify: `DEBUG` at build
- To enable wolfssl benchmark tests, specify: `HAVE_WOLFSSL_BENCHMARK` at build
- To enable wolfcrypt testsuite, specify: `HAVE_WOLFSSL_TEST` at build
- To enable a TLS 1.2 sample with a server and a client, specify: `HAVE_WASI_SOCKET` at build

### Benchmarking

As Wasm cannot leverage assembly or hardware optimizations, the results of the benchmarks can be compared to the native build with the following flags for a fair comparison:

```
./configure --enable-asm=no --enable-singlethreaded=yes
```

### Limitations
- Single Threaded (multiple threaded applications have not been tested)
- AES-NI use with SGX has not been added in yet
