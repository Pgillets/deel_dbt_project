FROM ghcr.io/dbt-labs/dbt-bigquery:1.7.latest

# define in docker build
ARG SLACK_TOKEN

ENV SLACK_TOKEN=$SLACK_TOKEN
ENV DBT_PROFILES_DIR=/usr/app/.dbt/
ENV GOOGLE_APPLICATION_CREDENTIALS=/usr/app/.dbt/temp-pedro-28508b49f066.json
ENV TARGET=dev

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir elementary-data==0.10.0

# Copy dbt project in the docker image to build
COPY ./ /usr/app/

# Use root to avoid permission issues
USER root

RUN dbt debug --target=$TARGET
RUN dbt debug --profile=elementary --target=$TARGET

ENTRYPOINT dbt deps && dbt build -t $TARGET && build -s elementary -t $TARGET && edr monitor --profile-target $TARGET --slack-token '$SLACK_TOKEN' --slack-channel-name temp-alerts