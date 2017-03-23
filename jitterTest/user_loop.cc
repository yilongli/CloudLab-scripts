#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

#define unlikely(x) __builtin_expect((x),0)

#define THRESHOLD_TICKS 30000
#define THRESHOLD_COUNT 100

static __inline __attribute__((always_inline))
uint64_t rdtsc()
{
    uint32_t tsc_aux;
    return __builtin_ia32_rdtscp(&tsc_aux);
}

uint64_t jitter[THRESHOLD_COUNT] = {};
uint64_t timestamp[THRESHOLD_COUNT] = {};

int main(int argc, char* argv[])
{
    pid_t ppid;
    if (argc == 1) {
        // Not running in snapshot mode.
        ppid = 0;
    } else if (argc == 2) {
        // Running in snapshot mode. The first argument is the process ID of
        // `perf record`. 0 means `perf record` is our parent process.
        ppid = atol(argv[1]);
        if (ppid == 0) {
            ppid = getppid();
        }
        printf("perf record pid %d", ppid);
    } else {
        printf("Incorrect number of arguments");
        return 1;
    }

    uint32_t cnt = 0;
    uint64_t t0 = rdtsc();
    while (1) {
        uint64_t t1 = rdtsc();
        if (unlikely(t1 - t0 > THRESHOLD_TICKS)) {
            jitter[cnt] = t1 - t0;
            timestamp[cnt] = t1;
            cnt++;
            if (cnt >= THRESHOLD_COUNT) {
                if (ppid > 0) {
                    kill(ppid, SIGUSR2);
                }
                for (uint32_t i = 0; i < THRESHOLD_COUNT; i++) {
                    printf("jitter %u: %lu cycles, timestamp %lu\n",
                            i, jitter[i], timestamp[i]);
                }
                return 0;
            }
        }
        t0 = t1;
    }
}
