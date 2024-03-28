FROM alpine:3.19

RUN apk --no-cache add lsyncd openssh-client rsync

ENTRYPOINT ["lsyncd", "-nodaemon", "-delay", "0", "/config/lsyncd.lua"]
