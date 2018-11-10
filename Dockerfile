FROM alpine:latest

ADD coturn.sh coturn.sh

RUN apk add coturn curl && \
    chmod +x coturn.sh

CMD ["./coturn.sh"]

