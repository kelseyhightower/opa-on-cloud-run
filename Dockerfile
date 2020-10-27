FROM gcr.io/hightowerlabs/opa:0.24.0-dev

ADD config.yaml /config.yaml

ENTRYPOINT ["/opa"]
CMD ["run"]
