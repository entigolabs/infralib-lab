#!/bin/bash
ls -1 aws-accounts | while read line
do
echo $line
source aws-accounts/$line
FOO=`aws route53 list-hosted-zones`
ZONE=$(echo $FOO | jq -r .HostedZones[0].Id )
ZONENAME=$(echo $FOO | jq -r .HostedZones[0].Name )
USERNUMBER=$(echo $line | grep -o '[0-9]*')

echo $ZONE $ZONENAME
if [ "$ZONENAME" != "u$USERNUMBER.entigo.dev." ]
then
	echo "WRONG ZONE NAME! '$ZONENAME' is not 'u$USERNUMBER.entigo.dev.'"
fi

if [ "$ZONE" != "/hostedzone/$AWS_ROUTE53_PARENT_ZONE" ]
then
        echo "WRONG ZONE ID $ZONE is not /hostedzone/$AWS_ROUTE53_PARENT_ZONE"
fi


ANS=$(aws route53 list-resource-record-sets --hosted-zone-id $ZONE --query "ResourceRecordSets[?Type=='NS']"  --output text | grep "^RESOURCERECORDS" | awk '{print $2}' | sort )

NS=$(dig u$USERNUMBER.entigo.dev NS | grep "^u$USERNUMBER.entigo.dev" | awk '{print $5}' | sort)

if [ "$ANS" != "$NS" ]
then
  echo "WRONG NS RECORDS"
  echo "$ANS"
  echo "---"
echo "$NS"


fi

IACCOUNT=$(aws sts get-caller-identity | jq -r .Account )
if [ "$IACCOUNT" != "$AWS_ACCOUNT" ]
then
	echo "WRONG ACCOUNT $IACCOUNT is not $AWS_ACCOUNT"
fi

done


