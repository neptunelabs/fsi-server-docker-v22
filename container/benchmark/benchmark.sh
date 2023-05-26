#!/bin/sh

if [ ! -w "/bench/assets" ];
then
  echo "Asset path not writable"
  exit 1
fi
if [ ! -w "/bench/storage" ];
then
  echo "Storage path not writable"
  exit 1
fi

CPU_NAME=$(grep -m 1 'model name' /proc/cpuinfo|sed 's/.*\: //')
CPU_FREQ=$(cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq 2>/dev/null|head -1)
CPU_FREQ=$((CPU_FREQ / 1000))
CPU_THREADS=$(grep -c processor /proc/cpuinfo)

if [ "$CPU_FREQ" -eq "0" ]; then
  echo -e "\n\e[4mFSI Benchmark ${BENCH_VERSION} - ${CPU_NAME} - ${CPU_THREADS} Threads\e[0m"
else
  echo -e "\n\e[4mFSI Benchmark ${BENCH_VERSION} - ${CPU_NAME} @ ${CPU_FREQ}MHz - ${CPU_THREADS} Threads\e[0m"
fi

echo -n "CPU-1            : "
SCPU_BENCH=$(sysbench --threads=1 --verbosity=3 cpu --cpu-max-prime=200000 run | awk -f /bench/awk/cpu.awk)
echo "${SCPU_BENCH} ops/sec"
echo -n "CPU-MAX          : "
MCPU_BENCH=$(sysbench --threads=$(nproc) --verbosity=3 cpu --cpu-max-prime=200000 run | awk -f /bench/awk/cpu.awk)
echo "${MCPU_BENCH} ops/sec"
echo -n "MEMORY           : "
MEM_BENCH=$(sysbench --threads=1 --verbosity=3 memory --memory-block-size=1k --memory-total-size=1000G run | awk -f /bench/awk/memory.awk)
echo "${MEM_BENCH} MiB/sec"

sync
echo 3 > /proc/sys/vm/drop_caches

echo -n "I/O BW Assets    : "
mkdir -p /bench/assets/bench
fio --output-format=json --output=/bench/assets/bench/assets.json /bench/fio/assets.fio > /dev/null
BW_ASSETS=$(jq -r '.jobs[0].read.bw_bytes' /bench/assets/bench/assets.json)
BW_ASSETS=$((BW_ASSETS / 1000000))
IOPS_ASSETS=$(jq -r '.jobs[0].read.iops' /bench/assets/bench/assets.json)
IOPS_ASSETS=$(printf "%.*f" "0" "${IOPS_ASSETS}")
rm -Rf /bench/assets/bench
echo "${BW_ASSETS} MB/sec"
echo "I/O IOPS Assets  : ${IOPS_ASSETS} IOPS"

sync
echo 3 > /proc/sys/vm/drop_caches

echo -n "I/O Storage      : "
mkdir -p /bench/storage/bench
fio --output-format=json --output=/bench/storage/bench/storage.json /bench/fio/storage.fio > /dev/null
BW_STORAGE=$(jq -r '.jobs[0].read.bw_bytes' /bench/storage/bench/storage.json)
BW_STORAGE=$((BW_STORAGE / 1000000))
IOPS_STORAGE=$(jq -r '.jobs[0].read.iops' /bench/storage/bench/storage.json)
IOPS_STORAGE=$(printf "%.*f" "0" "${IOPS_STORAGE}")
rm -Rf /bench/storage/bench
echo "${BW_STORAGE} MB/sec"
echo "I/O IOPS Storage : ${IOPS_STORAGE} IOPS"
