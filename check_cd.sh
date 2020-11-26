#!/bin/bash 

iterations=$(KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig kubectl -n odemo get canary/odemo -o jsonpath={.status.iterations})
while [[ " $iterations " == "4" ]]
do
  echo "Waiting the canary iterations to finish"
  sleep 10
  iterations=$(KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig kubectl -n odemo get canary/odemo -o jsonpath={.status.iterations})
  errors=$(KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig kubectl -n odemo get canary/odemo -o jsonpath={.status.failedChecks})
  if [[ " $errors " != "0" ]]
  then
    #echo "::set-output name=status::$(echo failed)"
    exit 1
  fi
done


# hna khassek dir sort o dir akhir wahed hit i9dar ikoun chi warning 9dim 
#ok=false
#until ${ok}; do
#  echo "Waiting the Halt status"
#  KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig kubectl get events -n odemo --field-selector involvedObject.kind=Canary,involvedObject.name=odemo,type=Warning | grep 'Halt' && ok=true || ok=false
#  sleep 20
#done

exit 0
#echo "::set-output name=status::$(echo succeded)"

