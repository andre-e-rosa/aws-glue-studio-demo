# Pre-requirements

### Setup environment to run this *Demo*

To run this *Demo*, you should have the following:
- An [AWS account](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html?nc2=h_ct&src=header_signup).
- An [AWS Identity and Access Management (IAM)](https://aws.amazon.com/iam/) user, with *admin* privileges to access resources used in this solution and to run commands from [AWS Command Line Interface (AWS CLI)](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html). Verify how to [create an IAM admin user and user group](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html).
- A basic understanding of ***bash*** scripting and ***SQL*** statements.

After configuring the previous prerequisites, follow these steps:

1. Login to the **AWS Management Console**, with the **IAM** *admin* user you created previously. Verify if the selected **AWS** region is ***Oregon***. If not, change the selection to this region, like in the below picture:
![AWS Region Oregon](/assets/images/02-aws-region-oregon.png)
2. At the **AWS Management Console** header, at the right side of the *Service Search Box*, click on the **AWS CloudShell** icon (surrounded by a bold square).
> :memo: **Note:**    
> Open **AWS CloudShell** in another tab, right clicking on it and selecting the proper option. Let the current tab with an **AWS Management Console** page opened: we will need to come back here later, during this *Demo* execution. Follow the below example:
> ![AWS CloudShell icon](/assets/images/03-aws-cloudshell-icon.png)
3. If a welcome splash screen appears, check the box *Do not show again* and click on the ***Close*** button.
4. Wait for the environment to be provisioned. When it's done, you should see a screen like the one below:
![AWS CloudShell ready](/assets/images/04-aws-cloudshell-ready.png)
5. At the right side of **AWS CloudShell** header, there is a gear icon besides the ***Actions*** button:

![AWS CloudShell settings](/assets/images/05-aws-cloudshell-settings.png)

6. Click on this gear icon to open an **AWS CloudShell** setup screen. In this screen, disable the option *Enable Safe Paste* and click on ***Confirm*** to save this new configuration.   
![AWS CloudShell change settings](/assets/images/06-aws-cloudshell-change-settings.png)

> :memo: **Note:**    
> Let this **AWS CloudShell** tab opened in your browser. You're going to use it later during the *Demo*.
7. In the opened **AWS CloudShell** prompt, using **AWS CLI**, configure the credentials of the **IAM** user created for this *Demo*, with the needed privileges. Visit the documentation to know how to quickly [configure basic settings (security credentials, default output format, and the default AWS Region)](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).

### Deploy the *Demo* architecture

Follow the below steps to deploy this *Demo*:
1. In the same **AWS CloudShell** prompt,  download the solution artifacts from this GitHub repository:   
```bash
git clone https://github.com/andre-e-rosa/aws-glue-studio-demo.git
```
2. Move to the bash scripts directory:   
```bash
cd aws-glue-studio-demo/scripts/bash
```   
3. Run the following bash script, to deploy and setup the *Demo*:
```bash
./deploy-demo.sh
```
4. When the deployment finishes, an [AWS CloudFormation](https://aws.amazon.com/cloudformation/) stack is created. Open this service in the first browser tab with the **AWS Management Console** already opened:   
![AWS CloudFormation open](/assets/images/07-aws-cloudformation-open.png)
5. Select the stack named **aws-glue-studio-demo**. Then, select the ***Outputs*** tab. Take note of all these parameters, as they will be used throughout the *Demo*:   
![AWS CloudFormation outputs](/assets/images/08-aws-cloudformation-outputs.png)

### Setup additional components for this *Demo*

Additionally to the resources deployed by the **AWS CloudFormation** stack, manually setup the following components:

1. There is an **EC2** instance provisioned with a ***psql*** client installed, tagged as *PSQL Host*, to be able to connect to **Redshift** database. Create a bash shell script, to execute an **AWS CLI** command which invokes **SSM Session Manager** to connect to this instance, issuing the following commands in the browser tab with the **AWS CloudShell** prompt:
```bash
cd ~
mkdir bin
echo '#!/bin/bash' > bin/psql-host-rmshell.sh
echo 'export AWS_PAGER=""' >> bin/psql-host-rmshell.sh
echo 'HOST_ID=`aws ec2 describe-instances --filters Name=tag:Name,Values="PSQL Host" Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].[InstanceId]" --output text`' >> bin/psql-host-rmshell.sh
echo "aws ssm start-session --target \$HOST_ID --document-name SSM-SessionManagerRunShell-Custom" >> bin/psql-host-rmshell.sh
chmod +x bin/psql-host-rmshell.sh
```
The final script will be similar to the one below:   
![AWS CloudFormation outputs](/assets/images/09-aws-cloudshell-script.png)   
2. Go back to the previous tab in the **CloudFormation** dashboard. In the **AWS Management Console**, open **AWS Glue** service:   
![AWS CloudFormation outputs](/assets/images/10-aws-glue-open.png)   
3. At the **AWS Glue** Dashboard, in the left panel, select the option ***Crawlers***.   
4. You should see the ***Crawlers*** panel, like in the example below. Click on **Create crawler** button:   
![AWS CloudFormation outputs](/assets/images/11-aws-glue-create-crawler.png)   
> :memo: **Note:**    
> - This ***Crawler*** needs to connect to the **Redshift** cluster, to get *nytaxi* table schema definition and catalog it at [AWS Glue Data Catalog](https://docs.aws.amazon.com/glue/latest/dg/components-overview.html#data-catalog-intro).
> - To be able to do that, it will use a **Glue Connection** already defined for this *Demo*, using a *JDBC* connector for **Redshift**, named `redshift-ny-taxi`.
> - Below you can see this **Glue Connection** definition:   
> ![Glue Connection Redshift](/assets/images/12-aws-glue-connection-redshift.png)   
5. In the form opened to you, follow the instructions inside each step below, in order, filling the specified fields with related values (the other fields not mentioned, let them with default values):   
---
- **Step 1: Set crawler properties**

| Field        | Value       |
|--------------|-------------|
| Crawler name | `RSCrawler` |

Click on **Next** button.   

- **Step 2: Choose data sources and classifiers**

At **Data sources** section, click on **Add a data source** and fill this information in the opened form:

|     Field    |        Value         |
|--------------|----------------------|
| Data source  | `JDBC`               |
| Connection   | `redshift-ny-taxi`   |
| Include path | `dbdw/public/nytaxi` |

The filled form should look like this:

![AWS Glue Crawler Data Source](/assets/images/13-aws-glue-crawler-data-source.png)

Click on **Add a JDBC data source** button.

Click on **Next** button.

- **Step 3: Configure security settings**

|   Field  |                                                           Value                                                                |
|----------|--------------------------------------------------------------------------------------------------------------------------------|
| IAM role | Choose the one which has a name associated with the value of parameter `LabGlueRole`, obtained from **CloudFormation** outputs |

Click on **Next** button.

- **Step 4: Set output and scheduling**

|      Field      |     Value       |
|-----------------|-----------------|
| Target database | `datechdb`      |
| Frequency       | `Run on demand` |

Click on **Next** button.

- **Step 5: Review and create**

Review the information you filled to create the Crawler. If everything is fine, click on Create crawler button.

---
6. You'll be redirected to the ***Crawlers*** panel. Check mark the crawler `RSCrawler` from the list and click on **Run** button:

