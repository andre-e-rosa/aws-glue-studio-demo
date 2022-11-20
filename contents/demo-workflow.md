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

4. 

### Part 02 - Create a Glue ETL job with AWS Glue Studio

### Part 03 - Query both Data Warehouse (Redshift) and Data Lake (S3) with Redshift Spectrum
