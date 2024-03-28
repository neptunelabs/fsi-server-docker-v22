FROM alpine:3.19

ENV BENCH_VERSION=1.0.7

RUN apk add --no-cache sysbench fio jq libaio

ADD awk /bench/awk
ADD fio /bench/fio
ADD benchmark.sh /bench/1.sh

RUN tr -d '\r' < /bench/awk/cpu.awk >/bench/1.awk && mv /bench/1.awk /bench/awk/cpu.awk
RUN tr -d '\r' < /bench/awk/memory.awk >/bench/1.awk && mv /bench/1.awk /bench/awk/memory.awk
RUN tr -d '\r' < /bench/1.sh >/bench/benchmark.sh && rm /bench/1.sh && chmod +x /bench/benchmark.sh

ENTRYPOINT [ "/bench/benchmark.sh" ]
