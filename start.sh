export i=1

if [ "$1" == "" ]
then
	echo "Specify a lab number to start"
	exit 1
fi

if [ ! -d "$1" ]
then
echo "Lab $1 not found."
exit 2

fi


export i=1
while [ $i -le `cat current_students` ] 
do
  rsync -a $1 ubuntu@infralib-$i.learn.entigo.io: && ssh ubuntu@infralib-$i.learn.entigo.io "sudo chown -R user$i:user$i $1 && sudo rm -rf /home/user$i/$1 && sudo mv -f $1 /home/user$i/$1" && echo "Lab $1 for user$i on host is infralib-$i.learn.entigo.io enabled" &
  let i++
  export i;
done





echo "Enabling HTML for $1"
if [ -d images/$1 ]
then
 echo "Found images"
 cp images/$1/* html/$1/
fi
cd html
tar cf - $1 | kubectl exec -i -n html -c html html-0  -- tar xf - -C /usr/share/nginx/html
if [ $? -ne 0 ]
then
  echo "FAILED TO COPY"
  exit 1
fi
wait
echo "Done"
