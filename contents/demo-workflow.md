# Demo workflow

### Part 01 - Analyzing data on Redshift

1. Go back to the browser tab where you have the **AWS CloudShell** session opened.
2. Call the following shell script:

```bash
psql-host-rmshell.sh
```

You should get connected to the ***PSQL Host*** bastion instance:

![AWS CloudShell call PSQL Host](/assets/images/20-aws-cloudshell-call-psql-host.png)

3. Call the following bash script, to connect to the **Redshift** cluster with the ***psql*** client:

```bash
psql-redshift-datech-hol.sh
```

![AWS CloudShell call PSQL Redshift](/assets/images/21-aws-cloudshell-call-psql-redshift.png)

4. Show the definition of table `nytaxi`, which contains New York taxi rides data loaded in it:

```sql
\d nytaxi
```

The result should be similar to this:

```
                      Table "public.nytaxi"
        Column         |            Type             | Modifiers 
-----------------------+-----------------------------+-----------
 vendorid              | integer                     | 
 pickup_datetime       | timestamp without time zone | 
 dropoff_datetime      | timestamp without time zone | 
 store_and_fwd_flag    | character(1)                | 
 ratecodeid            | integer                     | 
 pulocationid          | integer                     | 
 dolocationid          | integer                     | 
 passenger_count       | integer                     | 
 trip_distance         | numeric(10,2)               | 
 fare_amount           | numeric(10,2)               | 
 extra                 | numeric(10,2)               | 
 mta_tax               | numeric(10,2)               | 
 tip_amount            | numeric(10,2)               | 
 tolls_amount          | numeric(10,2)               | 
 ehail_fee             | character varying(10)       | 
 improvement_surcharge | numeric(10,2)               | 
 total_amount          | numeric(15,2)               | 
 payment_type          | integer                     | 
 trip_type             | integer                     | 
 congestion_surcharge  | numeric(10,2)               |
```

5. Verify the periods of statistics loaded in this table:

```sql
SELECT
    EXTRACT(year FROM pickup_datetime) pickup_year,
    EXTRACT(month FROM pickup_datetime) pickup_month,
    COUNT(*) total_taxi_rides
    FROM nytaxi
    GROUP BY 
        EXTRACT(year FROM pickup_datetime),
        EXTRACT(month FROM pickup_datetime)
    ORDER BY 1, 2;
```

The result should be similar to this:

```
pickup_year | pickup_month | total_taxi_rides 
-------------+--------------+------------------
        2018 |            1 |           793395
        2018 |            2 |           769804
        2018 |            3 |           836963
        2018 |            4 |           800120
        2018 |            5 |           797282
        2018 |            6 |           739351
        2018 |            7 |           684442
        2018 |            8 |           666324
        2018 |            9 |           666626
        2018 |           10 |           710482
        2018 |           11 |           656594
        2018 |           12 |           685389
        2019 |            1 |           630889
        2019 |            2 |           575678
        2019 |            3 |           601071
        2019 |            4 |           514392
        2019 |            5 |           504898
        2019 |            6 |           471038
        2019 |            7 |           470712
        2019 |            8 |           449693
        2019 |            9 |           449015
        2019 |           10 |           476385
        2019 |           11 |           449506
        2019 |           12 |           450602
        2020 |            1 |           447757
        2020 |            2 |           398647
        2020 |            3 |           223403
        2020 |            4 |            35610
        2020 |            5 |            57360
        2020 |            6 |            63110
        2020 |            7 |            72254
        2020 |            8 |            81064
        2020 |            9 |            87981
        2020 |           10 |            95115
        2020 |           11 |            88611
        2020 |           12 |            83128
(36 rows)
```

6. We're going to export data from **2018** and **2019** periods to a *Data Lake* on a **S3** bucket, deleting this portion of data from **Redshift**, after exporting it.

> :memo: **Note:**    
> Let this **AWS CloudShell** tab opened in your browser. You're going to use it later during the *Demo*.

### Part 02 - Create a Glue ETL job with AWS Glue Studio

1. In another browser tab, in the **AWS Management Console**, open **AWS Glue** service:

![AWS Glue open](/assets/images/10-aws-glue-open.png)

2. At the left panel in the **AWS Glue** Dashboard, under the option **AWS Glue Studio**, select ***Jobs***:

![AWS Glue Studio jobs](/assets/images/22-aws-glue-studio-jobs.png)

3. A new browser tab will open. In the ***Jobs*** panel opened, on the ***Create job*** section, select option ***Visual with a source and target***. Select **Amazon Redshift** as the source and **Amazon S3** as the target (see example below). When done, click on **Create** button:

![AWS Glue Studio create job](/assets/images/23-aws-glue-studio-create-job.png)

4. In the job diagram opened, at the header, edit the name of the job, clicking on the name `Untitled job` and substitute it by `redshift-s3-etl`.

![AWS Glue Studio rename job](/assets/images/24-aws-glue-studio-rename-job.png)

5. At the diagram, select ***Redshift cluster*** node. In the right panel, which shows configuration properties of a selected node, select ***Data source properties - Redshift*** tab. In this tab, fill the following fields with these specific values (the other fields not mentioned, let them with default values):

|                     Field                     |                             Value                              |
|-----------------------------------------------|----------------------------------------------------------------|
| JDBC source                                   | `Data Catalog table`                                           |
| Database                                      | `datechdb`                                                     |
| Table                                         | `dbdw_public_nytaxi`                                           |
| Temporary directory                           | `s3://<value of CloudFormation output "TempS3Bucket">/nytaxi/` |
| IAM role associated with the Redshift cluster | select the one which starts with name `LabRSDMSRole`           |

The final result should be similar to the below example:

![AWS Glue Studio Redshift node](/assets/images/25-aws-glue-studio-redshift-node.png)

6. Click on the ***ApplyMapping*** transform node. In the **Transform** tab, it's possible to change the name of the attribute keys from the source (columns) and change the data type, when creating these keys in the target datastore (**Amazon S3**).

![AWS Glue Studio ApplyMapping node](/assets/images/26-aws-glue-studio-applymapping-node.png)

7. At the head of the ***Visual*** diagram, click on the ***Action*** dropdown list and select the ***SQL Query*** transform operation.

![AWS Glue Studio SQL Query node](/assets/images/27-aws-glue-studio-sql-query-node-add.png)

8. Select the ***SQL Query*** node created on the diagram. At the right panel of node properties, select ***Node properties*** tab and confirm that ***Node parents*** has only the node ***ApplyMapping*** selected. Close the warning message `[SQL] input updated` that appears.

![AWS Glue Studio SQL Query node properties](/assets/images/28-aws-glue-studio-sql-query-node-properties.png)

> :memo: **Note:**    
> The ***Filter*** transform can filter only text and numeric fields. Because we want to filter a timestamp field, we can't use this transform. The ***SQL Query*** transform will give us flexibility to filter data using a ***SQL*** query.

9. With the ***SQL Query*** node still selected, at the right panel of node properties, select ***Transform*** tab and configure the following parameters:

|     Parameter      |     Value                                               |
|--------------------|---------------------------------------------------------|
|     SQL aliases    | `nytaxi_tab`                                            |
|     Code block     | `select * from nytaxi_tab` <br><br> &nbsp;&nbsp;&nbsp;&nbsp; `where pickup_datetime >= '2018-01-01 00:00:00' and` <br><br> &nbsp;&nbsp;&nbsp;&nbsp; `pickup_datetime <= '2019-12-31 23:59:59'` |

![AWS Glue Studio SQL Query node transform](/assets/images/29-aws-glue-studio-sql-query-node-transform.png)

> :warning: **Warning:**    
> Remember to let a line with a space **[1]**, at the bottom of the ***Code block*** box field, to avoid execution errors of this code block. 

10. At the diagram, select ***S3 bucket*** node. At the right panel of node properties, select ***Node properties*** tab and confirm that ***Node parents*** has only the node ***SQL query*** selected.

![AWS Glue Studio S3 node properties](/assets/images/30-aws-glue-studio-s3-node-properties.png)

11. With the ***S3 bucket*** node still selected, at the right panel of node properties, select the ***Data target properties - S3*** tab. In this tab, fill the following fields with these specific values (the other fields not mentioned, let them with default values):

|            Field            |                                                Value                                                  |
|-----------------------------|-------------------------------------------------------------------------------------------------------|
| Format                      | `Parquet`                                                                                             |
| Compression Type            | `Snappy`                                                                                              |
| S3 Target Location          | `s3://<value of CloudFormation output "DatalakeS3Bucket">/nytaxi/`                                    |
| Data Catalog update options | `Create a table in the Data Catalog and on subsequent runs, update the schema and add new partitions` |
| Database                    | `spectrumdb`                                                                                          |
| Table name                  | `nytaxi`                                                                                              |

![AWS Glue Studio S3 node data target](/assets/images/31-aws-glue-studio-s3-node-data-target.png)

12. The final diagram should look like the below one:

![AWS Glue Studio diagram](/assets/images/32-aws-glue-studio-diagram.png)

13. At the head of the diagram editor, select the ***Job details*** tab. In the ***Basic properties*** section, fill the following fields with these specific values (the other fields not mentioned, let them with default values):

|       Field       |                                                           Value                                                          |
|-------------------|------------------------------------------------------------------------------------------------------------------------|
| IAM Role          | Select the one which has a name associated with the value of parameter `LabGlueRole`, obtained from **CloudFormation** outputs |
| Number of retries | 0                                                                                                                        |

![AWS Glue Studio job details](/assets/images/33-aws-glue-studio-job-details.png)

Now, expand the section ***Advanced properties***. In the new opened panel, fill the following fields with these specific values (the other fields not mentioned, let them with default values):

|        Field       |                                  Value                                   |
|--------------------|--------------------------------------------------------------------------|
| Script path        | `s3://<value of CloudFormation output "TempS3Bucket">/scripts/`          |
| Spark UI logs path | `s3://<value of CloudFormation output "TempS3Bucket">/sparkHistoryLogs/` |
| Temporary path     | `s3://<value of CloudFormation output "TempS3Bucket">/temporary/`        |

![AWS Glue Studio job advanced properties](/assets/images/34-aws-glue-studio-job-advanced-properties.png)

14.	At this point, we can **Save** the job. Looking at the ***Script*** tab, it's possible to see the ***Python*** script generated.

![AWS Glue Studio job script](/assets/images/35-aws-glue-studio-job-script.png)

15. At the top of the dashboard, click on **Save** button, again. Then, click on **Run** button.

![AWS Glue Studio job run](/assets/images/36-aws-glue-studio-job-run.png)

16. Select the ***Runs*** tab to verify the running status of the job. Keep tracking it, until it reaches the run status *Succeeded*.

![AWS Glue Studio job succeeded](/assets/images/37-aws-glue-studio-job-run-succeeded.png)

> :memo: **Note:**    
> This job can take around **4 minutes** to finish. 

17. Move back to the previous browser tab, where the service **AWS Glue** is already selected.
18. At the **AWS Glue** Dashboard, in the left panel, select the option ***Databases*** under ***Data Catalog*** section.
19. You should see the ***Databases*** panel. Click on `spectrumdb` database from the list.

![AWS Glue Data Catalog database spectrumdb](/assets/images/38-aws-glue-data-catalog-database-spectrumdb.png)

20. In the description page of `spectrumdb` database, at the footer, check the ***Tables*** panel. You will see the `nytaxi` table generated by the **AWS Glue Studio** *ETL* job. Click on the name of this table.

![AWS Glue Data Catalog spectrumdb table](/assets/images/39-aws-glue-data-catalog-spectrumdb-table.png)

21. You'll see the Table Properties page for `nytaxi` table. Here, in the ***Table details*** tab, you can verify the **S3** bucket path where data files for this table are located, looking at attribute ***Location***. Click on the link inside this attribute:

![AWS Glue Data Catalog spectrumdb table properties](/assets/images/40-aws-glue-data-catalog-spectrumdb-table-properties.png)

22. You'll be redirected to the files location page on **S3**. Verify the ***Parquet*** files created in *Data Lake* **S3** bucket.

![AWS Glue Data Catalog S3 location](/assets/images/41-aws-glue-data-catalog-s3-location.png)

### Part 03 - Query both Data Warehouse (Redshift) and Data Lake (S3) with Redshift Spectrum
