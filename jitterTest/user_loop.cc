#include <stdint.h>
#include <stdio.h>

#define THRESHOLD_TICKS 1000

static __inline __attribute__((always_inline))
uint64_t rdtsc()
{
    uint32_t lo, hi;
    __asm__ __volatile__("rdtsc" : "=a" (lo), "=d" (hi));
    return (((uint64_t)hi << 32) | lo);
}

int main(void)
{
    uint64_t iter = 0;
    uint64_t t0 = rdtsc();
    while (1) {
        uint64_t t1 = rdtsc();
        iter++;
        if (t1 - t0 > THRESHOLD_TICKS) {
            printf("Jitter detected, %lu cycles, iteration %lu\n", t1 - t0, iter);
            break;
        }
        t0 = t1;
    }


    return 0;
}
