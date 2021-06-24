FROM alpine:3.8

MAINTAINER Rajiv Makhijani <rajiv@soxhub.com>

RUN apk add --update --no-cache ca-certificates

ENV VERSION v3.2.4
ENV FILENAME helm-${VERSION}-linux-amd64.tar.gz

WORKDIR /

ADD https://get.helm.sh/${FILENAME} /tmp

RUN tar -zxvf /tmp/${FILENAME} -C /tmp \
  && mv /tmp/linux-amd64/helm /bin/helm \
  && rm -rf /tmp

RUN /bin/helm repo add stable https://kubernetes-charts.storage.googleapis.com/ && /bin/helm repo update

RUN touch /tmp/foo

ENTRYPOINT ["/bin/helm"]
