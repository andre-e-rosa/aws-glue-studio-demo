# Cleaning up

After running this *Demo*, and to avoid unnecessary charges (storage and computing costs), do the following:

1. Move back to the **AWS CloudShell** session opened. Hit any key to recall the session.

![AWS CloudShell reload](/assets/images/42-aws-cloudshell-reload.png)

2. Move to the directory where the bash scripts were deployed:

```bash
cd ~/aws-glue-studio-demo/scripts/bash
```

3. Then, run this bash script, to delete the *Demo* stack:

```bash
./undeploy-demo.sh
```

The above script will run the following tasks:   
- Delete all objects in the deployed **S3** buckets.
- Delete the **CloudFormation** stack `aws-glue-studio-demo`.  

The content of this script can be visualized in [this link](/scripts/bash/undeploy-demo.sh).
