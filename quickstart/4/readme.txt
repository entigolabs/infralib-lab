#Infralib - Updating


### 1) Install Entigo Training Application.

Infralib is intended for infrastructure management, not end user applications. But in this lab we will install a training application to demonstrate some features it has.

Add a new application that is present in the <https://github.com/martivo/entigo-infralib-training> source.

> $ diff ~/3/config_il.yaml ~/4/config_app.yaml

Copy the updated configuration.
> $ cp ../4/config_app.yaml ./config.yaml

Run the Infralib Agent.
> $ docker run -it --rm -v "$(pwd)":"/conf" -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION -e AWS_SESSION_TOKEN entigolabs/entigo-infralib-agent ei-agent run  -c /conf/config.yaml

While the pipeline runs You can observe the application creation in ArgoCD. 

After the "dev-apps" steps "Plan" stage finishes the **"sales-portal"** application will appear in the ArgoCD. 

When the "Apply" stage of the "dev-apps" step has not started, none of the resources have been created.

![argocd_outofsync.png](argocd_outofsync.png)

After the "Apply" stage starts the objects are being created.

![argocd_syncing.png](argocd_syncing.png)

Finally the object becomes healthy and the pipeline finishes.

![argocd_healthy.png](argocd_healthy.png)


Use the aws cli to copy the generated code into the lab server.

> $ aws s3 cp --recursive --exclude '*/.terraform/*' s3://dev-$AWS_ACCOUNT-$AWS_REGION/steps ./quickstart_s3_4

The application expects the database hostname and database name in the input. It will find the inputs automatically from the "aws/mariadb" Terraform module.

The Infralib Agents reads the added file of the module <https://github.com/martivo/entigo-infralib-training/blob/v2.0.30/modules/k8s/training-application/agent_input_aws.yaml>.

You can see the literal values in the "sales-portal.yaml" file.
> $ cat ./quickstart_s3_4/dev-apps/sales-portal.yaml |  grep --color=always -C 30 " host:\|       name:\| db:"


There are no passwords in the infrastructure code. The "aws/mariadb" Terraform module has saved the database username and password in the AWS SM.

The application leverages External Secrets to get the password and username.
> $ kubectl get externalsecrets -n sales-portal db -o json | jq .spec.data

The "ExternalSecrets" object creates the "Secret" object using the values from AWS SecretsManager. 
> $ kubectl get secret -n sales-portal db -o json | jq .data

Get the URL for the application.
> $ echo "https://$(kubectl get ingress -n sales-portal web -o jsonpath='{.spec.rules[0].host}')"


Try to use the application by adding advertisements.

![application.png](application.png)


### 2) Update the Training Application modules.

Update the training application to the latest version. The newest version comes with an image upload feature. For that an S3 bucket is used and a new workload is installed called "img".

Remove the version lock from the source to enable update to a newer version.

> $ diff ~/4/config_app.yaml ~/4/config_updates.yaml

Copy the updated configuration and use the Infralib Agent **"update"** command.
> $ cp ../4/config_updates.yaml ./config.yaml

> $ docker run -it --rm -v "$(pwd)":"/conf" -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION -e AWS_SESSION_TOKEN entigolabs/entigo-infralib-agent ei-agent update -c /conf/config.yaml

The "dev-infra" and "dev-net" step will only run once to make sure the code is in sync with the infrastructure. Later version changes of this update do not run the pipeline since the "aws/mariadb" modules checksum does not change.

The "dev-apps" step is approved automatically for each version. <https://console.aws.amazon.com/codesuite/codepipeline/pipelines/dev-apps/view>

The new version contains a database schema update, a new "img" workload, updates the "api", "web" and "form" workloads to support the new feature.

Observe the changes using ArgoCD.

Verify that a new bucket is created <https://console.aws.amazon.com/s3/buckets>

After the update is finished try to use the application and add advertisements with pictures. (Try reloading the page when the image upload is not visible.)
> $ echo "https://$(kubectl get ingress -n sales-portal web -o jsonpath='{.spec.rules[0].host}')"

Proceed to "Cleanup / Uninstall". <https://infralib-quickstart.dev.entigo.dev/5>
