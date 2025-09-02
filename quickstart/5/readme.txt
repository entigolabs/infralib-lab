#Infralib - Cleanup / Uninstall

Delete all the AWS resources created and uninstall the Infralib Agent.

### 1) Delete the resources created by the pipelines

Run the "destroy" command of the agent. This will enable and execute the destroy pipelines to remove the resources.

> $ docker run -it --rm -v "$(pwd)":"/conf" -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION -e AWS_SESSION_TOKEN entigolabs/entigo-infralib-agent ei-agent destroy --yes -c /conf/config.yaml


### 2) Delete the ECR pull through cached repositories
Some container images are cached by ECR. To remove them use the following script. The script will output the delete commands that you will have to run.

> for repo in $(aws ecr describe-repositories --query 'repositories[*].repositoryName' --output text); do
>   echo "aws ecr delete-repository --repository-name \"$repo\" --force"
> done

### 3) Delete the resources created by the Infralib Agent


Start the agent with the *"delete"* option and --delete-bucket and --delete-service-account flags.
> $ docker run -it --rm -v "$(pwd)":"/conf" -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION -e AWS_SESSION_TOKEN entigolabs/entigo-infralib-agent ei-agent delete --delete-bucket --delete-service-account -c /conf/config.yaml

Press "Y" to confirm the deletion.
