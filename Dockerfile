FROM docker.io/grafana/grafana:11.5.1

COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.0 /lambda-adapter /opt/extensions/lambda-adapter

ENV GF_SERVER_HTTP_PORT=8080
ENV AWS_LWA_READINESS_CHECK_PATH=/api/health

USER root
RUN apk add --no-cache aws-cli

USER grafana
RUN grafana cli plugins install grafana-amazonprometheus-datasource 2.0.0

COPY ./lambda_entrypoint.sh /lambda_entrypoint.sh
ENTRYPOINT ["/lambda_entrypoint.sh"]
