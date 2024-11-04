registryurl="https://registry.infralib.learn.entigo.io"

curl -X 'PUT' "$registryurl/api/v2.0/configurations" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "Origin: $registryurl" \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Accept-Language: en-US,en;q=0.9,et-EE;q=0.8,et;q=0.7' \
  -u "admin:Harbor12345" \
  -d '{"quota_per_project_enable": false }' \
    --compressed

curl "$registryurl/api/v2.0/registries" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "Origin: $registryurl" \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Accept-Language: en-US,en;q=0.9,et-EE;q=0.8,et;q=0.7' \
  -u "admin:Harbor12345" \
  --data-raw '{"credential":{"access_key":"","access_secret":"","type":"basic"},"description":"","insecure":false,"name":"hub","type":"docker-hub","url":"https://hub.docker.com"}' \
  --compressed
  
curl "$registryurl/api/v2.0/registries" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "Origin: $registryurl" \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Accept-Language: en-US,en;q=0.9,et-EE;q=0.8,et;q=0.7' \
  -u "admin:Harbor12345" \
  --data-raw '{"credential":{"access_key":"","access_secret":"","type":"basic"},"description":"","insecure":false,"name":"ghcr","type":"github-ghcr","url":"https://ghcr.io"}' \
  --compressed
  
curl "$registryurl/api/v2.0/registries" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "Origin: $registryurl" \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Accept-Language: en-US,en;q=0.9,et-EE;q=0.8,et;q=0.7' \
  -u "admin:Harbor12345" \
  --data-raw '{"credential":{"access_key":"","access_secret":"","type":"basic"},"description":"","insecure":false,"name":"gcr","type":"docker-registry","url":"https://gcr.io"}' \
  --compressed
  
curl "$registryurl/api/v2.0/registries" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "Origin: $registryurl" \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Accept-Language: en-US,en;q=0.9,et-EE;q=0.8,et;q=0.7' \
  -u "admin:Harbor12345" \
  --data-raw '{"credential":{"access_key":"","access_secret":"","type":"basic"},"description":"","insecure":false,"name":"k8s","type":"docker-registry","url":"https://registry.k8s.io"}' \
  --compressed

k8sid=`curl -X 'GET'   'https://registry.infralib.learn.entigo.io/api/v2.0/registries?page=1&page_size=10'   -H 'accept: application/json'   -u "admin:Harbor12345" | jq '.[] | select(.name == "k8s").id'`
gcrid=`curl -X 'GET'   'https://registry.infralib.learn.entigo.io/api/v2.0/registries?page=1&page_size=10'   -H 'accept: application/json'   -u "admin:Harbor12345" | jq '.[] | select(.name == "gcr").id'`
ghcrid=`curl -X 'GET'   'https://registry.infralib.learn.entigo.io/api/v2.0/registries?page=1&page_size=10'   -H 'accept: application/json'   -u "admin:Harbor12345" | jq '.[] | select(.name == "ghcr").id'`
hubid=`curl -X 'GET'   'https://registry.infralib.learn.entigo.io/api/v2.0/registries?page=1&page_size=10'   -H 'accept: application/json'   -u "admin:Harbor12345" | jq '.[] | select(.name == "hub").id'`

curl "$registryurl/api/v2.0/projects" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "Origin: $registryurl" \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Accept-Language: en-US,en;q=0.9,et-EE;q=0.8,et;q=0.7' \
  -u "admin:Harbor12345" \
  --data-raw "{\"project_name\":\"hub\",\"registry_id\":$hubid,\"metadata\":{\"public\":\"true\"},\"storage_limit\":-1}" \
  --compressed

curl "$registryurl/api/v2.0/projects" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "Origin: $registryurl" \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Accept-Language: en-US,en;q=0.9,et-EE;q=0.8,et;q=0.7' \
  -u "admin:Harbor12345" \
  --data-raw "{\"project_name\":\"ghcr\",\"registry_id\":$ghcrid,\"metadata\":{\"public\":\"true\"},\"storage_limit\":-1}" \
  --compressed
  
curl "$registryurl/api/v2.0/projects" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "Origin: $registryurl" \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Accept-Language: en-US,en;q=0.9,et-EE;q=0.8,et;q=0.7' \
  -u "admin:Harbor12345" \
  --data-raw "{\"project_name\":\"gcr\",\"registry_id\":$gcrid,\"metadata\":{\"public\":\"true\"},\"storage_limit\":-1}" \
  --compressed
  
curl "$registryurl/api/v2.0/projects" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "Origin: $registryurl" \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Accept-Language: en-US,en;q=0.9,et-EE;q=0.8,et;q=0.7' \
  -u "admin:Harbor12345" \
  --data-raw "{\"project_name\":\"k8s\",\"registry_id\":$k8sid,\"metadata\":{\"public\":\"true\"},\"storage_limit\":-1}" \
  --compressed


export i=1

while [ $i -le `cat current_students` ]
do
    echo "Creating gitlab student$i"

    curl "$registryurl/api/v2.0/projects" \
      -H 'Content-Type: application/json' \
      -H 'Accept: application/json' \
      -H "Origin: $registryurl" \
      -H 'Sec-Fetch-Site: same-origin' \
      -H 'Sec-Fetch-Mode: cors' \
      -H 'Sec-Fetch-Dest: empty' \
      -H 'Accept-Language: en-US,en;q=0.9,et-EE;q=0.8,et;q=0.7' \
      -u "admin:Harbor12345" \
      --data-raw "{\"project_name\":\"app-u${i}\",\"registry_id\":null,\"metadata\":{\"public\":\"true\"},\"storage_limit\":-1}" \
      --compressed

    curl "$registryurl/api/v2.0/users" \
      -H 'Content-Type: application/json' \
      -H 'Accept: application/json' \
      -H "Origin: $registryurl" \
      -H 'Sec-Fetch-Site: same-origin' \
      -H 'Sec-Fetch-Mode: cors' \
      -H 'Sec-Fetch-Dest: empty' \
      -H 'Accept-Language: en-US,en;q=0.9,et-EE;q=0.8,et;q=0.7' \
      -u "admin:Harbor12345" \
      --data-raw "{\"username\":\"user${i}\",\"email\":\"user${i}.infralib@entigo.com\",\"realname\":\"user${i}\",\"password\":\"KubeLab${i}\",\"comment\":null}" \
      --compressed

    curl "$registryurl/api/v2.0/projects/app-u${i}/members" \
      -H 'Content-Type: application/json' \
      -H 'Accept: application/json' \
      -H "Origin: $registryurl" \
      -H 'Sec-Fetch-Site: same-origin' \
      -H 'Sec-Fetch-Mode: cors' \
      -H 'Sec-Fetch-Dest: empty' \
      -H 'Accept-Language: en-US,en;q=0.9,et-EE;q=0.8,et;q=0.7' \
      -u "admin:Harbor12345" \
      --data-raw "{\"role_id\":1,\"member_user\":{\"username\":\"user${i}\"}}" \
      --compressed
    let i++;
    export i;
done 
