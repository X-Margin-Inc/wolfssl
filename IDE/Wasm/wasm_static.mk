WOLFSSL_ROOT ?= $(shell readlink -f ../..)
WASI_SDK_PATH ?= /opt/wasi-sdk
Wolfssl_C_Extra_Flags := -DWOLFSSL_WASM
Wolfssl_C_Extra_Flags += -DHAVE_CAMELLIA -DWOLFSSL_SHA224 -DWOLFSSL_SHA512 -DWOLFSSL_SHA384 -DHAVE_HKDF -DNO_DSA -DTFM_ECC256 -DECC_SHAMIR \
	 						-DWC_RSA_PSS -DWOLFSSL_DH_EXTRA -DWOLFSSL_BASE64_ENCODE -DWOLFSSL_SHA3 -DHAVE_POLY1305 -DHAVE_ONE_TIME_AUTH \
							-DHAVE_CHACHA -DHAVE_HASHDRBG -DHAVE_OPENSSL_CMD -DHAVE_CRL -DHAVE_TLS_EXTENSIONS -DHAVE_SUPPORTED_CURVES \
							-DHAVE_FFDHE_2048 -DHAVE_SUPPORTED_CURVES # -DWOLFSSL_TLS13
Wolfssl_C_Extra_Flags += -O3

Wolfssl_C_Files :=$(WOLFSSL_ROOT)/wolfcrypt/src/aes.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/arc4.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/asn.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/blake2b.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/camellia.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/coding.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/chacha.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/chacha20_poly1305.c\
					$(WOLFSSL_ROOT)/src/crl.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/des3.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/dh.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/tfm.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/ecc.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/error.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/hash.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/kdf.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/hmac.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/integer.c\
					$(WOLFSSL_ROOT)/src/internal.c\
					$(WOLFSSL_ROOT)/src/wolfio.c\
					$(WOLFSSL_ROOT)/src/keys.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/logging.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/md4.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/md5.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/memory.c\
					$(WOLFSSL_ROOT)/src/ocsp.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/pkcs7.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/pkcs12.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/poly1305.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/wc_port.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/wolfmath.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/pwdbased.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/random.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/ripemd.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/rsa.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/dsa.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/sha.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/sha3.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/sha256.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/sha512.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/signature.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/sp_c32.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/sp_c64.c\
					$(WOLFSSL_ROOT)/src/ssl.c\
					$(WOLFSSL_ROOT)/src/tls.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/wc_encrypt.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/wolfevent.c\

Wolfssl_Include_Paths := -I$(WOLFSSL_ROOT)/ \
						 -I$(WOLFSSL_ROOT)/wolfcrypt/

ifeq ($(HAVE_WOLFSSL_TEST), 1)
	Wolfssl_Include_Paths += -I$(WOLFSSL_ROOT)/wolfcrypt/test
	Wolfssl_C_Files += $(WOLFSSL_ROOT)/wolfcrypt/test/test.c
	Wolfssl_C_Extra_Flags += -DHAVE_WOLFSSL_TEST
endif

ifeq ($(HAVE_WOLFSSL_BENCHMARK), 1)
	Wolfssl_C_Files += $(WOLFSSL_ROOT)/wolfcrypt/benchmark/benchmark.c
	Wolfssl_Include_Paths += -I$(WOLFSSL_ROOT)/wolfcrypt/benchmark/
	Wolfssl_C_Extra_Flags += -DHAVE_WOLFSSL_BENCHMARK
endif

ifeq ($(HAVE_WASI_SOCKET), 1)
	WAMR_PATH ?= /opt/wamr
	Wolfssl_C_Files += $(WAMR_PATH)/core/iwasm/libraries/lib-socket/src/wasi/wasi_socket_ext.c
	Wolfssl_C_Files += server-tls.c client-tls.c
	Wolfssl_Include_Paths += -I$(WAMR_PATH)/core/iwasm/libraries/lib-socket/inc -I.
	Wolfssl_C_Extra_Flags += -DHAVE_WASI_SOCKET
endif

ifeq ($(DEBUG), 1)
	Wolfssl_C_Extra_Flags += -DDEBUG -DDEBUG_WOLFSSL
endif

.PHONY: all
all:
	mkdir -p build
	$(WASI_SDK_PATH)/bin/clang \
		--target=wasm32-wasi \
		--sysroot=$(WASI_SDK_PATH)/share/wasi-sysroot/ \
		-Wl,--allow-undefined-file=$(WASI_SDK_PATH)/share/wasi-sysroot/share/wasm32-wasi/defined-symbols.txt \
		-Wl,--strip-all \
		$(Wolfssl_C_Extra_Flags) \
		$(Wolfssl_Include_Paths) \
		-o build/wolfssl.wasm $(Wolfssl_C_Files) main.c 

.PHONY: clean
clean:
	rm -rf build