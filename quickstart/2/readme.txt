#Infralib - Bootstrap to the Cloud

Run the Infrlaib Agent on the managed services of the cloud.

### 1) Bootstrap the Infralib Agent

When the Git service runs on the infrastructure that is managed by Infralib Agent, then an outage could prevent the execution of the infrastructure pipelines. 

Bootstrap the Infralib Agent itself into the cloud so it can be used without a workstation or Git service. This method can also be used if the project does not have a Git service at all.

![agent_2.png](agent_2.png)

Use the **"bootstrap"** command instead of the **"run"** command.

> $ docker run -it --rm -v "$(pwd)":"/conf" -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION -e AWS_SESSION_TOKEN entigolabs/entigo-infralib-agent ei-agent bootstrap  -c /conf/config.yaml

The bootstrap also starts the "run" command of the Infralib Agent in the cloud.

Now it is possible to run the pipelines and the Infralib Agent using only the cloud provider services. <https://console.aws.amazon.com/codesuite/codepipeline/pipelines>

![agent_bootstrap.png](agent_bootstrap.png)

The Infralib Agent log can be observed from the **"agent-run"** pipeline by using the "View details" of the "AgentRun" stage. Please notice that now the steps are executed in parallel not sequentally, making the Infralib Agent run command faster.

To update the Infralib modules, the **"agent-update"** pipeline can be used. At the moment there are no updates to be applied.

The **"config"** folder and file are also synced to the Object Storage bucket. The bucket has versioning enabled, so there is also a version history of the configuration.

![s3_files.png](s3_files.png)


To dig deeper into Infralib and Infralib Agent continue to "Dependency injection, Custom code and Change management". <https://infralib-quickstart.dev.entigo.dev/3>

The weak can give up and go to "Cleanup / Uninstall". <https://infralib-quickstart.dev.entigo.dev/5>
