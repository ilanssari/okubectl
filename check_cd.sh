#!/bin/bash 

iterations=$(kubectl -n $PROJECT_NAME get canary/$PROJECT_NAME -o jsonpath={.status.iterations})

while [ $iterations -gt 1 ]
do
  echo "Waiting the Canary job to start"
  sleep 5
  iterations=$(kubectl -n $PROJECT_NAME get canary/$PROJECT_NAME -o jsonpath={.status.iterations})
done

# counting the iterations

while [ $iterations -lt 2 ]
do
  echo "Waiting the canary iterations to finish"
  sleep 5
  errors=$(kubectl -n $PROJECT_NAME get canary/$PROJECT_NAME -o jsonpath={.status.failedChecks})
  if [ $errors -gt 0 ]
  then
    echo "the hook test failed !"
    echo "::set-output name=status::$(echo failed)"
    exit 1
  fi
  iterations=$(kubectl -n $PROJECT_NAME get canary/$PROJECT_NAME -o jsonpath={.status.iterations})
done

# waiting the halt message

#lastTimestamp=$(kubectl get events -n odemo --field-selector involvedObject.kind=Canary,involvedObject.name=odemo,type=Warning -o jsonpath='{.items[-1:].lastTimestamp}')
#while [ -z "$lastTimestamp" ]
#do
#  sleep 10
#  lastTimestamp=$(kubectl get events -n odemo --field-selector involvedObject.kind=Canary,involvedObject.name=odemo,type=Warning -o jsonpath='{.items[-1:].lastTimestamp}')
#done
#lastTimestampSec=$(date -d"$lastTimestamp" +%s)
#interval="360"
#
#while true
#do
#  echo "waiting the halt message"
#  minTime=$(( $lastTimestampSec + $interval ))
#  nowSec=$(date '+%s')
#  if [ $nowSec -lt $minTime ]
#  then
#    break
#  fi
#  sleep 10
#  lastTimestamp=$(kubectl get events -n odemo --field-selector involvedObject.kind=Canary,involvedObject.name=odemo,type=Warning -o jsonpath='{.items[-1:].lastTimestamp}')
#  lastTimestampSec=$(date -d"$lastTimestamp" +%s)
#done

echo "::set-output name=status::$(echo succeeded)"
exit 0
