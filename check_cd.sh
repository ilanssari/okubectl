#!/bin/bash 

#alias groot2="KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig"

ok=false
until ${ok}; do
    kubectl get canary/$PROJECT_NAME -n $PROJECT_NAME | grep 'Progressing' && ok=true || ok=false
    sleep 5
done

# wait for the canary analysis to finish
#KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig kubectl wait canary/odemo --for=condition=promoted --timeout=5m -n odemo

# check if the deployment was successful 
#KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig kubectl get canary/odemo -n odemo | grep Succeeded

#KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig kubectl get ns 

status="other"
array=["failed","succeeded"]
#while [ "$status" != "Failed" ] && [ "$status" != "Succeeded" ]

#You could do:

while [[ " ${array[*]} " != *"$status"* ]]
do
  echo "waiting for the canary to be stable"
  sleep 5
  status=$(kubectl -n $PROJECT_NAME get canary/$PROJECT_NAME -o jsonpath={.status.phase})
done

echo "::set-output name=status::$(echo $status)"

