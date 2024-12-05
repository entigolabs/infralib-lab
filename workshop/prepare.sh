#!/bin/bash
set -o xtrace


unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
unset AWS_SESSION_TOKEN


aws sso login --profile entigo-prod-training-admin
aws eks update-kubeconfig --name infralib-infra-eks --profile entigo-prod-training-admin

export OIDC=`aws eks describe-cluster --name infralib-infra-eks --query "cluster.identity.oidc.issuer" --output text --profile entigo-prod-training-admin  | sed 's/https:\/\///'`

if [ "$OIDC" == "" ]
then
  echo "Could not get EKS cluster OIDC"
  exit 2
fi

kubectl get nodes
if [ $? -ne 0 ]
then
  echo "No connection to kubernetes."
  exit 1
fi

kubectl create ns html
cat html.yaml | sed "s#OIDCVALUE#$OIDC#g" | kubectl apply -n html -f-


kubectl create ns gitlab
kubectl apply -n gitlab -f gitlab.yaml 

export i=1

while [ 1 -lt 2 ]
do
  uhost="infralib-$i.learn.entigo.io"
  echo "user$i host is $uhost"
  ssh-keygen -f ~/.ssh/known_hosts -R "$uhost"
  ssh-keyscan -H infralib-$i.learn.entigo.io >> ~/.ssh/known_hosts 2> /dev/null
  scp aws-accounts/user$i ubuntu@$uhost:aws-credentials
  ssh ubuntu@$uhost "sudo apt-get update -y && sudo apt-get -y install git vim curl nano bash-completion binutils jq htop python3-pip && sudo pip3 install awscli --upgrade"
  ssh ubuntu@$uhost "curl -LO https://dl.k8s.io/v1.31.2/kubernetes-client-linux-amd64.tar.gz && tar xvzf kubernetes-client-linux-amd64.tar.gz && chmod +x kubernetes/client/bin/kubectl && sudo mv kubernetes/client/bin/kubectl /usr/bin/kubectl"
  ssh ubuntu@$uhost "sudo chmod 744 /home/ubuntu"
  ssh ubuntu@$uhost "sudo useradd -m -G sudo -s /bin/bash -U user$i || exit 0" || break
  ssh ubuntu@$uhost "echo \"usermod --password '\$(sudo openssl passwd -1 KubeLab$i)' user$i\" >> userpw.sh"
  ssh ubuntu@$uhost "echo \"user$i  ALL=(ALL) NOPASSWD:ALL\" > 91-lab-user && sudo chown root:root 91-lab-user && sudo mv -f 91-lab-user /etc/sudoers.d/"
  ssh ubuntu@$uhost "sudo chmod +x /home/ubuntu/userpw.sh && sudo /home/ubuntu/userpw.sh && sudo mv /home/ubuntu/aws-credentials /home/user$i/aws-credentials"
  ssh ubuntu@$uhost "sudo sed -i \"s/#PasswordAuthentication yes/PasswordAuthentication yes/g\" /etc/ssh/sshd_config && sudo sed -i \"s/PasswordAuthentication no/PasswordAuthentication yes/g\"  /etc/ssh/sshd_config.d/60-cloudimg-settings.conf &&  sudo systemctl restart sshd"
  ssh ubuntu@$uhost "sudo apt update && sudo apt -y install jq curl && curl -fsSL https://get.docker.com/ | sudo sh && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 && chmod +x ./kind && sudo mv ./kind /usr/bin/kind"
  ssh ubuntu@$uhost "curl -Lo k9s_Linux_x86_64.tar.gz https://github.com/derailed/k9s/releases/download/v0.32.4/k9s_Linux_amd64.tar.gz && tar xvzf k9s_Linux_x86_64.tar.gz && sudo mv k9s /usr/bin/"
  ssh ubuntu@$uhost "curl -Lo kubectl-neat_linux.tar.gz https://github.com/itaysk/kubectl-neat/releases/download/v2.0.2/kubectl-neat_linux.tar.gz && tar xvzf kubectl-neat_linux.tar.gz && sudo mv kubectl-neat /usr/bin/"
  ssh ubuntu@$uhost "sudo gpasswd -a user$i docker"


  let i++
  export i;
done
echo $i > current_students

./prepare_html.sh 1
./start.sh 1
./start.sh 2
./start.sh 3
./start.sh 4
./start.sh 5

  
kubectl exec -n gitlab gitlab-0 -it -- grep 'Password:' /etc/gitlab/initial_root_password
