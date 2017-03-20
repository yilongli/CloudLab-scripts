#include <stdint.h>
#include <stdio.h>

#define unlikely(x) __builtin_expect((x),0)

#define THRESHOLD_TICKS 1000

static __inline __attribute__((always_inline))
uint64_t rdtsc()
{
    return __builtin_ia32_rdtsc();
}

int main(void)
{
    uint64_t iter = 0;
    uint64_t t0 = rdtsc();
    while (1) {
        uint64_t t1 = rdtsc();
        iter++;
        if (unlikely(t1 - t0 > THRESHOLD_TICKS)) {
            printf("Jitter detected, %lu cycles, iteration %lu\n", t1 - t0, iter);
            break;
        }
        t0 = t1;
    }


    return 0;
}
