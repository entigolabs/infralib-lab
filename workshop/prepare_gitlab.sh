# #gitlab
# if [ "$1" != "" ]
# then
#     curl --header "PRIVATE-TOKEN: $1" -X POST  "https://gitlab.infralib.learn.entigo.io/api/v4/admin/ci/variables" --form "key=DOCKER_REGISTRY" --form "value=registry.infralib.learn.entigo.io" --form "variable_type=env_var"
#     if [ $? -ne 0 ]
#     then
#     echo "Failed request"
#     exit 1
#     fi
#     curl --header "PRIVATE-TOKEN: $1" -X POST  "https://gitlab.infralib.learn.entigo.io/api/v4/admin/ci/variables" --form "key=DOCKERHUB_PROXY" --form "value=registry.infralib.learn.entigo.io/hub/" --form "variable_type=env_var"
#     if [ $? -ne 0 ]
#     then
#     echo "Failed request"
#     exit 1
#     fi
#     curl --header "PRIVATE-TOKEN: $1" -X POST  "https://gitlab.infralib.learn.entigo.io/api/v4/admin/ci/variables" --form "key=GHCR_PROXY" --form "value=registry.infralib.learn.entigo.io/ghcr/" --form "variable_type=env_var"
#     if [ $? -ne 0 ]
#     then
#     echo "Failed request"
#     exit 1
#     fi
#     curl --header "PRIVATE-TOKEN: $1" -X POST  "https://gitlab.infralib.learn.entigo.io/api/v4/admin/ci/variables" --form "key=GCR_PROXY" --form "value=registry.infralib.learn.entigo.io/gcr/" --form "variable_type=env_var"
#     if [ $? -ne 0 ]
#     then
#     echo "Failed request"
#     exit 1
#     fi
#     curl --header "PRIVATE-TOKEN: $1" -X POST  "https://gitlab.infralib.learn.entigo.io/api/v4/admin/ci/variables" --form "key=GITHUB_TOKEN" --form "value=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" --form "masked=true" --form "variable_type=env_var"
#     if [ $? -ne 0 ]
#     then
#     echo "Failed request"
#     exit 1
#     fi
#     
#     
#     curl --header "PRIVATE-TOKEN: $1" -X POST  "https://gitlab.infralib.learn.entigo.io/api/v4/admin/ci/variables" --form "key=KUBERNETES_INGRESS_CLASS" --form "value=alb" --form "variable_type=env_var" --form "masked=false"
#     if [ $? -ne 0 ]
#     then
#     echo "Failed request"
#     exit 1
#     fi
#     RUNNER_TOKEN=`curl --header "PRIVATE-TOKEN: $1" -X POST "https://gitlab.infralib.learn.entigo.io/api/v4/user/runners" --data "runner_type=instance_type" --data "run_untagged=true" --data "access_level=not_protected" --data "description=k8s-runner" | jq -r .token`
#     echo "RUNNER_TOKEN $RUNNER_TOKEN"
#     helm repo add gitlab https://charts.gitlab.io
#     helm upgrade -i --namespace gitlab gitlab-runner -f gitlab-runner.yaml --set runnerToken=$RUNNER_TOKEN gitlab/gitlab-runner --version 0.68.1
#     if [ $? -ne 0 ]
#     then
#     echo "Failed helm install request"
#     exit 1
#     fi
# fi

export i=12

while [ $i -le `cat current_students` ]
do
    echo "Creating gitlab student$i"
    if [ "$1" != "" ]
    then
      id=`curl --header "PRIVATE-TOKEN: $1" -X POST "https://gitlab.infralib.learn.entigo.io/api/v4/groups?name=app-u${i}&path=app-u${i}" | jq -r .id`
      if [ "$id" != "" ]
      then
        curl --header "PRIVATE-TOKEN: $1" -X POST  "https://gitlab.infralib.learn.entigo.io/api/v4/groups/$id/variables" --form "key=DOCKER_USER" --form "value=user${i}" --form "variable_type=env_var" --form "masked=false"
        curl --header "PRIVATE-TOKEN: $1" -X POST  "https://gitlab.infralib.learn.entigo.io/api/v4/groups/$id/variables" --form "key=DOCKER_PASS" --form "value=KubeLab${i}" --form "variable_type=env_var" --form "masked=true"
        userid=`curl --header "PRIVATE-TOKEN: $1" -X POST "https://gitlab.infralib.learn.entigo.io/api/v4/users?email=user${i}.infralib@entigo.com&password=KubeLab${i}&username=user${i}&name=user${i}&reset_password=false&skip_confirmation=true&shared_runners_minutes_limit=0" | jq -r .id`
        curl --header "PRIVATE-TOKEN: $1" -X POST --data "user_id=$userid&access_level=50" "https://gitlab.infralib.learn.entigo.io/api/v4/groups/$id/members"
        #curl --header "PRIVATE-TOKEN: $1" -X POST "https://gitlab.infralib.learn.entigo.io/api/v4/projects?name=api&namespace_id=$id&auto_infralib_enabled=false"
        #curl --header "PRIVATE-TOKEN: $1" -X POST "https://gitlab.infralib.learn.entigo.io/api/v4/projects?name=web&namespace_id=$id&auto_infralib_enabled=false"
        #curl --header "PRIVATE-TOKEN: $1" -X POST "https://gitlab.infralib.learn.entigo.io/api/v4/projects?name=form&namespace_id=$id&auto_infralib_enabled=false"
        #curl --header "PRIVATE-TOKEN: $1" -X POST "https://gitlab.infralib.learn.entigo.io/api/v4/projects?name=db&namespace_id=$id&auto_infralib_enabled=false"
        curl --header "PRIVATE-TOKEN: $1" -X POST "https://gitlab.infralib.learn.entigo.io/api/v4/projects?name=iac&namespace_id=$id&auto_infralib_enabled=false"
      fi
    else
      echo "Not doing any API calls since first parameter is empty"
    fi
    rm -rf clone-*
#     git clone https://user${i}:KubeLab${i}@gitlab.infralib.learn.entigo.io/app-u${i}/api.git clone-u${i}-api
#     cp -r api/. clone-u${i}-api
#     cd clone-u${i}-api && git add --all && git commit -a -m"Initial commit" && git push
#     cd ..
#     git clone https://user${i}:KubeLab${i}@gitlab.infralib.learn.entigo.io/app-u${i}/web.git clone-u${i}-web
#     cp -r web/. clone-u${i}-web
#     cd clone-u${i}-web && git add --all && git commit -a -m"Initial commit" && git push
#     cd ..
#     git clone https://user${i}:KubeLab${i}@gitlab.infralib.learn.entigo.io/app-u${i}/form.git clone-u${i}-form
#     cp -r form/. clone-u${i}-form
#     cd clone-u${i}-form && git add --all && git commit -a -m"Initial commit" && git push
#     cd ..
#     git clone https://user${i}:KubeLab${i}@gitlab.infralib.learn.entigo.io/app-u${i}/db.git clone-u${i}-db
#     cp -r db/. clone-u${i}-db
#     cd clone-u${i}-db && git add --all && git commit -a -m"Initial commit" && git push
#     cd ..
    sleep 1
    git clone https://user${i}:KubeLab${i}@gitlab.infralib.learn.entigo.io/app-u${i}/iac.git clone-u${i}-iac
    if [ $? -ne 0 ]
    then
      echo "FAILED TO CLONE https://user${i}:KubeLab${i}@gitlab.infralib.learn.entigo.io/app-u${i}/iac.git clone-u${i}-iac"
      exit 1
    fi
    cp -r iac/. clone-u${i}-iac
    
    PARENT_ZONE=`cat aws-accounts/user${i} | grep "AWS_ROUTE53_PARENT_ZONE" | cut -d'"' -f2`
    sed -i "s/\(parent_zone_id: \).*/\1$PARENT_ZONE/" clone-u${i}-iac/config/net/dns.yaml
    
    cd clone-u${i}-iac && git add --all && git commit -a -m"Initial commit" && git push
    if [ $? -ne 0 ]
    then
      echo "FAILED TO COMMIT https://user${i}:KubeLab${i}@gitlab.infralib.learn.entigo.io/app-u${i}/iac.git clone-u${i}-iac"
      exit 1
    fi
    cd ..
    let i++;
    export i;
done 



