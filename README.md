# Building and Running this DBT Project
`gcloud builds submit`  
This command will trigger Google Cloud build to run 4 steps:
1. rebuild the dbt project image and 
2. save the new image to Google Artifact Registry
3. update the configurations of Google Cloud Run Job
4. update the Google Cloud Scheduler job

The configurations of each step can be found on **cloudbuild.yaml** file.

`gcloud run jobs execute deel-dbt-cloud-run-job`  
This command can be used to run this project on demand.

# DBT Models structure
**models>sources**  
Have the yaml file used to define the 2 Bigquery External Tables used to import the CSV files provided that were uploaded to Google Cloud Storage

**models>staging**  
Have SQL files that define the 1-to-1 tables that will get the data from the External tables and materialize it as Bigquery Tables

**models>dimensions**  
Have the SQL file defining the requested dimension table. It also have a yaml file with tests for the dimension table.

**models>facts**  
Have the SQL file defining the requested fact table

**tests>**  
Have a singular test created to check if there was a change of more than 50% on the financial balance of any Organization. Here the premise that invoices with `status='paid'` and `payment_method='client_balance'` would have a value to be deducted from the Customer Deel Balance. And invoices with `status='refunded'` or `status='credited'` would have a value to be added to the Balance.

# Alerting system via Slack
Here we are using a DBT package called Elementary to integrate DBT to Slack. Any failed tests will result in a Slack message sent to a channel with details from the error that are going to be helpful on debugging. Elementary is an Open Source solution, well established on DBT community.