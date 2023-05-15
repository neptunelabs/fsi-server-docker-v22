FROM alpine:3.18

ENV BENCH_VERSION=1.0.5

RUN apk add --no-cache sysbench fio jq libaio

ADD awk /bench/awk
ADD fio /bench/fio
ADD --chmod=755 benchmark.sh /bench/benchmark.sh

ENTRYPOINT [ "/bench/benchmark.sh" ]
