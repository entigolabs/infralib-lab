#Infralib - Dependency injection, Custom code and Change management

In this lab custom Terraform code and modules are added to customize the existing project. Find out how Infralib Agent can help with module configuration and automatic approval.

### 1) Use custom Terraform code

Create a Security Group that is specific to this environment using a regular "tf" file.

Some values will be taken from the **"net"** steps **"vpc"** modules output with the help of the **".output"** variable.

> $ cat ~/3/securitygroups.tf

The Infralib Agent templates can also be used inside of the included files, not only in the config file itself.

In this example the "{{ .config.**prefix** }}" is translated to "dev" - the value is taken from the config.yaml **"prefix"** parameter.

The "{{ .output.**net.main**.vpc\_id }}" and "{{ .output.**net.main**.public\_subnet\_cidrs }}" are referring to the **"net"** steps module named **"main"**.

![agent_1.png](agent_1.png)

Infralib modules can define their expected inputs as part of the module code. 

Users do not not have to configure these inputs unless they want to - avoiding mistakes and saving time. 

This is why the "aws/eks" module did not have to configure a "vpc\_id" or "public\_subnets" input in the configuration. But the generated infrastructure code in "main.tf" does contain the inputs with correct values.

![agent_2.png](agent_2.png)

The **".toutput"** template works even when the step names or module names are changed. It will find the inputs regardless whether the other module is in the same step or not. 

**The module that is creating the outputs can originate from another source or be entirely replaced as long as it provides the same output parameters.**

The **".touput"** does not work when a module is called multiple times. Then all the inputs have to be configured using **".output"**.

![agent_4.png](agent_4.png)

**This works for Infralib Helm charts the same way.**

Copy the Terraform code to the **"include"** folder of the "infra" step.

> $ mkdir -p ./config/infra/include
> $ cp ../3/securitygroups.tf ./config/infra/include/

Run the infralib agent.
> $ docker run -it --rm -v "$(pwd)":"/conf" -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION -e AWS_SESSION_TOKEN entigolabs/entigo-infralib-agent ei-agent run  -c /conf/config.yaml

The "dev-infra" pipeline will now contain the custom Terraform code that was added and the Infralib Agent will approve the changes since we only add resources.

> $ aws s3 cp --recursive --exclude '*/.terraform/*' s3://dev-$AWS_ACCOUNT-$AWS_REGION/steps ./quickstart_s3_2

> $ cat ./quickstart_s3_2/dev-infra/securitygroups.tf

To see differences of before and after Infralib Agent has templated the file.
> $ diff ../3/securitygroups.tf ./quickstart_s3_2/dev-infra/securitygroups.tf

Verify the Security Group (**"dev-developers"**) was created <https://console.aws.amazon.com/ec2/home#SecurityGroups:>

### 2) Use infralib module

Add a new source that contains an Infralib database module. Using Infralib modules will automatically fill in the required inputs. 

The creation of a "ClusterSecretStore" for the k8s/external-secrets module is also enabled. This will enable applications to access any secret in AWS SM using "ExternalSecrets".

> $ diff ~/iac/config.yaml ~/3/config_il.yaml

Please notice in the comparison that we no longer have to define most of the inputs for the "database" module.


Copy the updated configuration, remove the "securitygroups.tf" file and commit changes to Git.
> $ cp ../3/config_il.yaml ./config.yaml
> $ rm ./config/infra/include/securitygroups.tf

Run the infralib agent.
> $ docker run -it --rm -v "$(pwd)":"/conf" -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION -e AWS_SESSION_TOKEN entigolabs/entigo-infralib-agent ei-agent run  -c /conf/config.yaml


**The "securitygroups.tf" file was removed.** This causes resource deletion and as a result the Infralib Agent will **NOT** automatically approve the "dev-infra" pipeline. 

![agent_manual_approval.png](agent_manual_approval.png)

The Infralib Agent can be configured to behave differently, but this is the default behaviour. This process works with Kubernetes objects too.

![agent_5.png](agent_5.png)

Approve the change manually from the AWS Code Pipeline "dev-infra" pipeline. <https://console.aws.amazon.com/codesuite/codepipeline/pipelines/dev-infra/view>

The details of the plan are visible in the "Plan" output of the pipeline. 

Open the "Approve" stage "Review" view.

![code_pipeline_review.png](code_pipeline_review.png)

Approve the pipeline.

![code_pipeline_approve.png](code_pipeline_approve.png)

The Gitlab pipeline will finish once the "dev-infra" step Apply stage finishes.

![gitlab_done.png](gitlab_done.png)


Verify that the RDS database and access credentials in Secrets Manager was created and the Security Group was deleted.

RDS <https://console.aws.amazon.com/rds/home#databases:> 

Secrets Manager <https://console.aws.amazon.com/secretsmanager/listsecrets>

Security Group (**"dev-developers"**) <https://console.aws.amazon.com/ec2/home#SecurityGroups:>

Use the aws cli to copy the generated code into the lab server.

> $ aws s3 cp --recursive --exclude '*/.terraform/*' s3://dev-$AWS_ACCOUNT-$AWS_REGION/steps ./quickstart_s3_3

The module "database" has been added to the "main.tf" file with the inputs filled. **Only "allocated_storage: 21" was configured in the Infralib Agent configuration.**
> $ cat ./quickstart_s3_3/dev-infra/main.tf

To dig deeper into Infralib and Infralib Agent continue to "Updates". <https://infralib-quickstart.dev.entigo.dev/4>

The weak can give up and go to "Cleanup / Uninstall". <https://infralib-quickstart.dev.entigo.dev/5>

