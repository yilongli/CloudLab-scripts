#include <string.h>
#include <iostream>
#include <fstream>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <vector>
#include <thread>
#include <unistd.h>
#include <sys/syscall.h>
#include <atomic>
#include <sys/time.h>
#include <time.h>

// All rdtsc code is copied from RAMCloud's Cycles class
static __inline __attribute__((always_inline))
uint64_t rdtsc()
{
    uint32_t lo, hi;
    __asm__ __volatile__("rdtsc" : "=a" (lo), "=d" (hi));
    return (((uint64_t)hi << 32) | lo);
}

double getCyclesPerSec() {
    double cyclesPerSec = 0;

    // Compute the frequency of the fine-grained CPU timer: to do this,
    // take parallel time readings using both rdtsc and gettimeofday.
    // After 10ms have elapsed, take the ratio between these readings.

    struct timeval startTime, stopTime;
    uint64_t startCycles, stopCycles, micros;
    double oldCycles;

    // There is one tricky aspect, which is that we could get interrupted
    // between calling gettimeofday and reading the cycle counter, in which
    // case we won't have corresponding readings.  To handle this (unlikely)
    // case, compute the overall result repeatedly, and wait until we get
    // two successive calculations that are within 0.1% of each other.
    oldCycles = 0;
    while (1) {
        if (gettimeofday(&startTime, NULL) != 0) {
            std::cout << "couldn't read clock" << std::endl;
            exit(1);
        }
        startCycles = rdtsc();
        while (1) {
            if (gettimeofday(&stopTime, NULL) != 0) {
                std::cout << "couldn't read clock" << std::endl;
                exit(1);
            }
            stopCycles = rdtsc();
            micros = (stopTime.tv_usec - startTime.tv_usec) +
                    (stopTime.tv_sec - startTime.tv_sec)*1000000;
            if (micros > 10000 * 100) { // 1 second
                cyclesPerSec = static_cast<double>(stopCycles - startCycles);
                cyclesPerSec = 1000000.0*cyclesPerSec/
                        static_cast<double>(micros);
                break;
            }
        }
        double delta = cyclesPerSec/1000.0;
        if ((oldCycles > (cyclesPerSec - delta)) &&
                (oldCycles < (cyclesPerSec + delta))) {
            return cyclesPerSec;
        }
        oldCycles = cyclesPerSec;
    }

    return cyclesPerSec;
}

double getCyclesPerSec2(clockid_t clock, uint64_t periodMs = 10) {
    double cyclesPerSec = 0;

    // Compute the frequency of the fine-grained CPU timer: to do this,
    // take parallel time readings using both rdtsc and gettimeofday.
    // After 10ms have elapsed, take the ratio between these readings.

    struct timespec startTime, stopTime;
    uint64_t startCycles, stopCycles, nanos;
    double oldCycles;

    // There is one tricky aspect, which is that we could get interrupted
    // between calling gettimeofday and reading the cycle counter, in which
    // case we won't have corresponding readings.  To handle this (unlikely)
    // case, compute the overall result repeatedly, and wait until we get
    // two successive calculations that are within 0.1% of each other.
    oldCycles = 0;
    while (1) {
        if (clock_gettime(clock, &startTime) != 0) {
            std::cout << "couldn't read clock" << std::endl; exit(1);
        }
        startCycles = rdtsc();
        while (1) {
            if (clock_gettime(clock, &stopTime) != 0) {
                std::cout << "couldn't read clock" << std::endl; exit(1);
            }
            stopCycles = rdtsc();
            nanos = (stopTime.tv_nsec - startTime.tv_nsec) +
                    (stopTime.tv_sec - startTime.tv_sec)*1000000000;
            if (nanos > periodMs * 1000000) {
                cyclesPerSec = static_cast<double>(stopCycles - startCycles);
                cyclesPerSec = 1e9*cyclesPerSec/static_cast<double>(nanos);
                break;
            }
        }
        double delta = cyclesPerSec/1000.0;
        if ((oldCycles > (cyclesPerSec - delta)) &&
                (oldCycles < (cyclesPerSec + delta))) {
            return cyclesPerSec;
        }
        oldCycles = cyclesPerSec;
    }

    return cyclesPerSec;
}

uint64_t toNanoseconds(uint64_t cycles, double cyclesPerSec) {
    return (uint64_t) (1e09*static_cast<double>(cycles)/cyclesPerSec + 0.5);
}

int main(int argc, const char** argv) {
    double old = getCyclesPerSec();
    //getCyclesPerSec2(CLOCK_REALTIME, 10);
    //getCyclesPerSec2(CLOCK_REALTIME, 100);
    double rt = getCyclesPerSec2(CLOCK_REALTIME, 1000);
    double bt = getCyclesPerSec2(CLOCK_BOOTTIME, 1000);
    double mono = getCyclesPerSec2(CLOCK_MONOTONIC, 1000);
    double mono_raw = getCyclesPerSec2(CLOCK_MONOTONIC_RAW, 1000);
    double proc_cputime = getCyclesPerSec2(CLOCK_PROCESS_CPUTIME_ID, 1000);
    double thrd_cputime = getCyclesPerSec2(CLOCK_THREAD_CPUTIME_ID, 1000);
    printf("%15.0f %15.0f %15.0f %15.0f %15.0f %15.0f %15.0f\n", old, rt, bt, mono, mono_raw, proc_cputime, thrd_cputime);
    return 0;
}
