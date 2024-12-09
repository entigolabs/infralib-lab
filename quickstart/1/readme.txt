#Infralib - Quickstart

Provision Kubernetes on AWS with integrations using the Infralib Agent. 

### 1) Clone the example project and configure it

Clone the **"infralib-lab"** repository that contains the example project.
> $ git clone --depth 1 --branch main https://github.com/entigolabs/infralib-lab.git

Go to the example project directory.
> $ cd infralib-lab/quickstart/iac
> $ find .

Configure the route53 DNS zone to use. The example project will create sub domains into the existing route53 domain. The quickstart assumes the zone is present in the same account as we will run the infralib in.

> export AWS_ROUTE53_PARENT_ZONE="..."

Replace it in the infralib route53 configuration file.
> sed -i "/^parent_zone_id:/s/:.*/: $AWS_ROUTE53_PARENT_ZONE/" config/net/dns.yaml

Verify the zone is configured in the config/net/dns.yaml file.
> cat config/net/dns.yaml


### 2) Use the Infralib Agent

Configure the AWS_REGION you want to use.
> export AWS_REGION="eu-north-1"

Configure access credentials with Administrative privileges.
> export AWS_ACCESS_KEY_ID="..."
> export AWS_SECRET_ACCESS_KEY="..."
Optionally you might have to set AWS_SESSION_TOKEN.
> export AWS_SESSION_TOKEN="..."

Use the Infralib Agent **"run"** command to create the infrastructure code, deploy pipelines and create all the cloud resources.


> $ docker run -it --rm -v "$(pwd)":"/conf" -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION -e AWS_SESSION_TOKEN entigolabs/entigo-infralib-agent ei-agent run  -c /conf/config.yaml

The console should display a similar log and the command will stay running for a while.  **Please continue with the lab without waiting for this command to finish, but do not close or cancel it.**

![dev_net_console.png](dev_net_console.png)

The cloud resource provisioning takes a while. Use this time to study the configuration and observe the operation of the Infralib Agent.

Click on the file names below to show the contents. It is the configuration file that the Infralib Agent "run" command was started with.
> $ cat ~/iac/config.yaml

Currently it has only one source - all the modules will originate from <https://github.com/entigolabs/entigo-infralib-release>.

This Infralib Agent configuration has three steps - **net, infra and apps**. The amount of steps and how they are named is up to the user to decide. However this is a commonly used configuration.

![agent.webp](agent.webp)

**Step: net**

The VPC, subnets, routings and nat gateways are created using the "aws/vpc" module. And it is called the "main" network.

The "aws/route53" module is named as "dns". It creates a public DNS zone using route53 and the TLS certificate for it using Certificate Manager.

The "dns" and "vpc" configurations are placed in separate files to make the configuration easier to read and manage. 

> $ cat ~/iac/config/net/main.yaml
> $ cat ~/iac/config/net/dns.yaml



**Step: infra**

This step is running in the private subnet that we created in the "net" step due to the "**vps.attach**" configuration. 

This enables Terraform to communicate with the resources in the private subnets - even when the Infralib Agent is run externally.

The "aws/eks" module will provision a Kubernetes cluster with nodegroups. Here the **"inputs"** block is used to configure the module, unlike in the "net" step.

For the lab purpose the cluster is made available on the public network - the **eks\_cluster\_public: true** boolean changes it from the default value of false.

The "aws/crossplane" module creates needed permissions for the AWS Crossplane provider so we can create AWS resources using Kubernetes manifests.


**Step: apps**

In this step we install the much needed integrations into the Kubernetes cluster using ArgoCD.

The "argocd" applications ingress annotations are changed for the lab purpose from the defaults. It is made available on the public network.<br/><br/>

Find the CodePipeline job for the "net" step. <https://eu-north-1.console.aws.amazon.com/codesuite/codepipeline/pipelines?region=eu-north-1>

![dev_net_plan.png](dev_net_plan.png)

Click on the pipeline **"dev-net"** to see the pipeline Source, Plan, Approve and Apply stages.

![dev_net_plan_details.png](dev_net_plan_details.png)

Open the "View details" on the **Plan** stage to see the Terraform plan for this step.

![dev_net_plan_log.png](dev_net_plan_log.png)

The Terraform plan only intends to create resources, as a result **the Infralib Agent will approve it automatically**.

![dev_net_apply.png](dev_net_apply.png)

Access the Terraform apply log by opening "View details" on the **Apply** stage.

![dev_net_apply_log.png](dev_net_apply_log.png)

Once the network step is complete the Infralib Agent will create similar pipelines for the **"infra"** and **"apps"** steps.

The **"-destroy"** pipelines are there to be able to remove all the created resources. By default these pipelines are disabled to prevent accidental deletion of resources.

The generated infrastructure code has been placed into a S3 bucket. 

Navigate the S3 service. <https://eu-north-1.console.aws.amazon.com/s3/buckets?region=eu-north-1>

Open the only bucket starting with the "dev" word and followed by account number and region.

![dev_net_s3.png](dev_net_s3.png)

The generated infrastructure code is placed in the **"steps"** folder and each step has its own sub folder.

![dev_net_s3_steps.png](dev_net_s3_steps.png)

The generated infrastructure code is stored here, it also can be updated by the Infralib Agent.

![dev_net_s3_code.png](dev_net_s3_code.png)

Monitor the pipeline logs and explore the created resources (VPC, Certificate Manager, Route53, Elastic Kubernetes Service).

 **Please wait for the Infralib Agent "run" command in the terminal to finish executing before proceeding. It will take about 30 minutes total.**

![agent_run_done.png](agent_run_done.png)
 
![code_pipeline_done.png](code_pipeline_done.png)
 
When everything is completed - the Infralib Agent has provisioned the infrastructure code and the infrastructure.

The default naming scheme of the resources is **prefix - step name -  module name**. This makes it easy to track the created resources and find their configurations.


**A summary of the created resources:**

A VPC called "dev-net-main". <https://eu-north-1.console.aws.amazon.com/vpcconsole/home?region=eu-north-1#vpcs:>.

Subnets for public, private and databases in two zones with the required routes and NAT gateways. <https://eu-north-1.console.aws.amazon.com/vpcconsole/home?region=eu-north-1#subnets:>

A new DNS zone for the domain **"dev.uN.entigo.dev"**.

Added the DNS zone NS records into it's parent zone. <https://us-east-1.console.aws.amazon.com/route53/v2/hostedzones?region=eu-north-1#>

A wildcard certificate for the domain <https://eu-north-1.console.aws.amazon.com/acm/home?region=eu-north-1#/certificates/list>

The AWS EKS Kubernetes cluster is provisioned with Add Ons and Node Groups <https://eu-north-1.console.aws.amazon.com/eks/home?region=eu-north-1#>

The essential integratsions are also installed into the Kubernetes cluster.


To investigate the generated infrastructure code more conveniently use the aws cli to copy it to the lab server. The ".terraform" folder is excluded, it is used for caching the Terraform modules and providers.
> $ aws s3 cp --recursive --exclude '*/.terraform/*' s3://dev-$AWS_ACCOUNT-$AWS_REGION/steps ~/lab_1

Network step
> $ ls -l ~/lab_1/dev-net/
> $ cat ~/lab_1/dev-net/main.tf
Infra step
> $ ls -l ~/lab_1/dev-infra/
> $ cat ~/lab_1/dev-infra/main.tf
Apps step
> $ ls -l ~/lab_1/dev-apps/
> $ cat ~/lab_1/dev-apps/external-dns-dev.yaml


### 4) Get access to the AWS EKS cluster

Configure the "kubectl" context with aws cli to access the created Kubernetes cluster

> $ aws eks update-kubeconfig --region $AWS_REGION --name dev-infra-eks

Some of the Kubernetes resources are still being created, use the following commands to make sure they are fully operational. The commands will output "Condition met" when the resources are ready for use.

Wait for the AWS ALB controller to be started so Ingress objects can create AWS Application Load Balancers.
> $ kubectl wait --for=create namespace/aws-alb-dev --timeout=300s
> $ kubectl wait -n aws-alb-dev --for=create deploy/aws-alb-dev-aws-load-balancer-controller --timeout=300s
> $ kubectl wait -n aws-alb-dev --for=condition=ready pod --selector=app.kubernetes.io/instance=aws-alb-dev --timeout=300s

Wait for the External-dns integration to be started so the DNS records for the Ingress objects can be created in AWS Route53.
> $ kubectl wait --for=create namespace/external-dns-dev --timeout=300s
> $ kubectl wait -n external-dns-dev --for=create deploy/external-dns-dev --timeout=300s
> $ kubectl wait -n external-dns-dev --for=condition=ready pod --selector=app.kubernetes.io/instance=external-dns-dev --timeout=300s

Wait for the ArgoCD Ingress Load Balancer to be provisioned to be able to access ArgoCD web interface.
> $ kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' -n argocd  ingress/argocd-server --timeout=300s
> $ aws elbv2 wait load-balancer-available --region $AWS_REGION --names $(kubectl get ingress -n argocd argocd-server -o json | jq -r .status.loadBalancer.ingress[0].hostname | cut -d"-" -f1-3)

![kubectl.png](kubectl.png)

### 5) Get access to ArgoCD

Fetch the generated ArgoCD admin password and log in to the web interface.

> $ kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d | xargs echo 

Go to <https://argocd.dev.uN.entigo.dev>. The username is "admin" and the password is in the output of the previous command.

Notice that in ArgoCD all the needed integrations are already installed as requested in the configuration.

ArgoCD web UI also relies on multiple integrations itself:

  "aws/route53" - for DNS zone and TLS Certificates.
  
  "k8s/aws-alb" - To create Application Load Balancer in AWS for Ingress object.
  
  "k8s/external-dns" - create the required DNS record for Ingress object.

![dev_argocd.png](dev_argocd.png)

Open the **"external-dns-dev"** ArgoCD application and see that the AWS IAM resources are also created. This confirms the AWS Crossplane provider is operational too.

![dev_argocd_external_dns.png](dev_argocd_external_dns.png)

The created role and policy can be seen in the AWS Console under IAM and roles. <https://us-east-1.console.aws.amazon.com/iam/home?region=eu-north-1#/roles>

![dev_iam.png](dev_iam.png)

Continue to Lab 2. <https://html.infralib.learn.entigo.io/2>

