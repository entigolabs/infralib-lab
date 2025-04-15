#Infralib - Cleanup / Uninstall

Delete all the AWS resources created and uninstall the Infralib Agent.

### 1) Delete the Kubernetes objects assiciated to AWS Resources

Delete applications that create AWS resources.

Delete the uploaded advertisement images from the S3 bucket.
> $ aws s3 rm --recursive s3://$(kubectl get ObjectStorageBucket -n sales-portal -o json img | jq -r .spec.parameters.name)
> $ aws s3api delete-objects --bucket $(kubectl get ObjectStorageBucket -n sales-portal -o json img | jq -r .spec.parameters.name) --delete "$(aws s3api list-object-versions --bucket $(kubectl get ObjectStorageBucket -n sales-portal -o json img | jq -r .spec.parameters.name) --output json --query '{Objects: Versions[].{Key:Key,VersionId:VersionId} || DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"

Delete "sales-portal" application.
> $ kubectl patch app sales-portal -n argocd -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge
> $ kubectl delete app sales-portal -n argocd
> $ kubectl delete ns sales-portal

Remove all the Ingress and PV resources to delete any AWS Load Balancers and EBS volumes.
> $ kubectl delete ingress -A --all
> $ kubectl delete pv --all

Delete external-secrets.
> $ kubectl patch app external-secrets-dev -n argocd -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge
> $ kubectl delete app external-secrets-dev -n argocd
> $ kubectl delete ns external-secrets-dev

Delete external-dns.
> $ kubectl patch app external-dns-dev -n argocd -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge
> $ kubectl delete app external-dns-dev -n argocd
> $ kubectl delete ns external-dns-dev

Delete aws-alb
> $ kubectl patch app aws-alb-dev -n argocd -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge
> $ kubectl delete app aws-alb-dev -n argocd
> $ kubectl delete ns aws-alb-dev


### 2) Delete the resources created by external-dns

Navigate to route53 and delete all the records except NS and SOA type in the newly created "dev.Your parent DNS zone" zone. <https://console.aws.amazon.com/route53/v2/hostedzones>

![r53.png](r53.png)

### 3) Delete the resources created by the pipelines

Run the "destroy" command of the agent. This will enable and execute the destroy pipelines to remove the resources.

> $ docker run -it --rm -v "$(pwd)":"/conf" -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION -e AWS_SESSION_TOKEN entigolabs/entigo-infralib-agent ei-agent destroy --yes --steps infra,net -c /conf/config.yaml


### 4) Delete the ECR pull through cached repositories
Some container images are cached by ECR. To remove them use the following script. The script will output the delete commands that you will have to run.

> for repo in $(aws ecr describe-repositories --query 'repositories[*].repositoryName' --output text); do
>   echo "aws ecr delete-repository --repository-name \"$repo\" --force"
> done

### 5) Delete the resources created by the Infralib Agent


Start the agent with the *"delete"* option and --delete-bucket and --delete-service-account flags.
> $ docker run -it --rm -v "$(pwd)":"/conf" -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION -e AWS_SESSION_TOKEN entigolabs/entigo-infralib-agent ei-agent delete --delete-bucket --delete-service-account -c /conf/config.yaml

Press "Y" to confirm the deletion.
