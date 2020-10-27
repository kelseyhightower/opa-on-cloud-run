FROM gcr.io/hightowerlabs/opa:0.24.0-dev

ADD configs/gcs-bundle-service.yaml /config.yaml

ENTRYPOINT ["/opa"]
CMD ["run"]
