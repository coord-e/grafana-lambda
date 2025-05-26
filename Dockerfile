FROM docker.io/grafana/grafana:12.0.1

COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=ghcr.io/coord-e/lambda-metrics-forwarder-extension:bf0985eb16185f3c93115c95c0b750ee00608dcb /lambda-metrics-forwarder-extension /opt/extensions/

ENV METRICS_FORWARDER_SCRAPE_URL=http://localhost:8080/metrics

ENV GF_SERVER_HTTP_PORT=8080
ENV AWS_LWA_READINESS_CHECK_PATH=/api/health
ENV AWS_LWA_ASYNC_INIT=true

ENV GF_AUTH_SIGV4_AUTH_ENABLED=true
ENV GF_LIVE_MAX_CONNECTIONS=0
ENV GF_PATHS_DATA=/tmp

USER root
RUN apk add --no-cache aws-cli

USER grafana
RUN grafana cli plugins install grafana-amazonprometheus-datasource 2.0.0

COPY ./lambda_entrypoint.sh /lambda_entrypoint.sh
ENTRYPOINT ["/lambda_entrypoint.sh"]
