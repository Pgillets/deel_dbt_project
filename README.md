# To rebuild the dbt project image, the Cloud Run Job and the Scheduler job:
gcloud builds submit
# To run the image via Cloud Run
gcloud run jobs execute deel-dbt-cloud-run-job