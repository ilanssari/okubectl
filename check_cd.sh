#!/bin/bash 

iterations=$(KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig kubectl -n odemo get canary/odemo -o jsonpath={.status.iterations})

while [ $iterations -gt 1 ]
do
  echo "Waiting the Canary job to start"
  sleep 10
  iterations=$(KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig kubectl -n odemo get canary/odemo -o jsonpath={.status.iterations})
done

# counting the iterations

while [ $iterations -lt 4 ]
do
  echo "Waiting the canary iterations to finish"
  sleep 10
  errors=$(KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig kubectl -n odemo get canary/odemo -o jsonpath={.status.failedChecks})
  if [ $errors -gt 0 ]
  then
    echo "the hook test failed !"
    exit 1
  fi
  iterations=$(KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig kubectl -n odemo get canary/odemo -o jsonpath={.status.iterations})
done

# waiting the halt message

lastTimestamp=$(KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig kubectl get events -n odemo --field-selector involvedObject.kind=Canary,involvedObject.name=odemo,type=Warning -o jsonpath='{.items[-1:].lastTimestamp}')
while [ -z "$lastTimestamp" ]
do
  sleep 10
  lastTimestamp=$(KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig kubectl get events -n odemo --field-selector involvedObject.kind=Canary,involvedObject.name=odemo,type=Warning -o jsonpath='{.items[-1:].lastTimestamp}')
done
lastTimestampSec=$(date -d"$lastTimestamp" +%s)
interval="360"

while true
do
  echo "waiting the halt message"
  minTime=$(( $lastTimestampSec + $interval ))
  nowSec=$(date '+%s')
  if [ $nowSec -lt $minTime ]
  then
    break
  fi
  sleep 10
  lastTimestamp=$(KUBECONFIG=~/.verrazzano/ol/ol-managed-2/kubeconfig kubectl get events -n odemo --field-selector involvedObject.kind=Canary,involvedObject.name=odemo,type=Warning -o jsonpath='{.items[-1:].lastTimestamp}')
  lastTimestampSec=$(date -d"$lastTimestamp" +%s)
done

exit 0
