#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
#include <errno.h>

#include "wolfssl/ssl.h"
#include "wolfssl/wolfcrypt/settings.h"
#include "wolfssl/wolfcrypt/types.h"
#include "wolfcrypt/benchmark/benchmark.h"

#ifdef __wasi__
#ifdef HAVE_WASI_SOCKET
#include "wasi_socket_ext.h"
#endif
#endif

typedef struct func_args {
    int    argc;
    char** argv;
    int    return_code;
} func_args;

int main(int argc, char** argv) {
    func_args args = { 0 };
    memset(&args,0,sizeof(args));

    switch(argv[1][1]) {

#ifdef HAVE_WOLFSSL_TEST
        case 't':
            printf("Crypt Test:\n");
            wolfcrypt_test(&args);
            printf("Crypt Test: Return code %d\n", args.return_code);
            break;
#endif /* HAVE_WOLFSSL_TEST */

#ifdef HAVE_WOLFSSL_BENCHMARK
       case 'b':
            printf("\nBenchmark Test:\n");
            benchmark_test(&args);
            printf("Benchmark Test: Return code %d\n", args.return_code);
            break;
#endif /* HAVE_WOLFSSL_BENCHMARK */
        default:
            printf("Unrecognized option set!\n");
            break;
    }

    return 0;
}