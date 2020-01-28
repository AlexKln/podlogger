#!/bin/bash

iterations=0
if [ $2 ]; then # scratch space
	iterations=1
	echo "scratch space mode, first pod will fail"
fi

POD_NAME=""

for (( c=0; c<=$iterations; c++ ))
do
	POD_NAME="$(oc get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep -m 1 $1)"
	if [ "${POD_NAME}" == "" ]; then
		break
	fi
	while [[ $(oc get pods "${POD_NAME}" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]] && [[ $(oc get pods "${POD_NAME}" -o 'jsonpath={.status.phase}') == "Pending" ]]; 
		do echo "waiting for pod" && sleep 1; 
			done && oc logs -f "${POD_NAME}"
	if [ $c == 0 ] && [ $iterations == 1 ]; then
		echo "waiting 15 seconds between pods"
		sleep 15
	fi
done