FROM ghcr.io/dbt-labs/dbt-bigquery:1.4.latest

# # define in docker build
# ARG BQ_PROJECT_ID
# ARG BQ_DATASET
# ARG DBT_PROJECT_DIR
# ARG WEB_EVENTS_START_DATE

# ENV DBT_PROJECT_DIR=$DBT_PROJECT_DIR
# ENV BQ_PROJECT_ID=$BQ_PROJECT_ID
# ENV BQ_DATASET=$BQ_DATASET
# ENV WEB_EVENTS_START_DATE=$WEB_EVENTS_START_DATE

# default env values, can be overridden
# ENV BQ_LOCATION="europe-west1"
ENV DBT_PROFILES_DIR=/usr/app/.dbt/
ENV GOOGLE_APPLICATION_CREDENTIALS=/usr/app/.dbt/temp-pedro-28508b49f066.json
ENV TARGET=dev

USER root

# Copy dbt project in the docker image to build
COPY ./ /usr/app/
# COPY auth /usr/app/auth/

# Use root to avoid permission issues
USER root

RUN dbt debug --target=$TARGET
RUN dbt --version

ENTRYPOINT dbt deps && dbt build --target=$TARGET