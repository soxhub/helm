FROM alpine:3.3

MAINTAINER Rajiv Makhijani <rajiv@soxhub.com>

RUN apk add --update --no-cache ca-certificates

ENV VERSION v2.0.2
ENV FILENAME helm-${VERSION}-linux-amd64.tar.gz

WORKDIR /

ADD http://storage.googleapis.com/kubernetes-helm/${FILENAME} /tmp

RUN tar -zxvf /tmp/${FILENAME} -C /tmp \
  && mv /tmp/linux-amd64/helm /bin/helm \
  && rm -rf /tmp

ENTRYPOINT ["/bin/helm"]
