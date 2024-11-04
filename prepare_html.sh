#!/bin/bash
docker rm -f kube-apps-html
docker build --no-cache -t kube-apps-lab-html .
docker run -d --rm --name kube-apps-html  kube-apps-lab-html:latest 
rm -rf html
docker cp kube-apps-html:/usr/share/nginx/html ./ 
docker rm -f kube-apps-html
cp -r images/* html/

if [ "$1" != "" ]
then
  tar cf - html/*.* | kubectl exec -i -n html -c html html-0  -- tar xf - -C /usr/share/nginx/
fi
