#!/bin/bash
# set up parameters named in Jenkins
# cloud
# token
# scriptName
# device A
# device B

CLOUD="beta.perfectomobile.com"
TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJMWTVZal9BamtfWUplRUJCUmM1Q3ZqMXkzaFNySTBscVhEbnpwOXFIUjVzIn0.eyJqdGkiOiI2YzNiODJiMy03YjRjLTQ5ODktOTA3Ny0xMTQ2NTMyYWQ1N2YiLCJleHAiOjAsIm5iZiI6MCwiaWF0IjoxNTQ3MjQxOTkxLCJpc3MiOiJodHRwczovL2F1dGgucGVyZmVjdG9tb2JpbGUuY29tL2F1dGgvcmVhbG1zL2JldGEtcGVyZmVjdG9tb2JpbGUtY29tIiwiYXVkIjoib2ZmbGluZS10b2tlbi1nZW5lcmF0b3IiLCJzdWIiOiI1NjM1MzhmYS0xYWQ3LTRiNGUtOGE2Ny05N2NkZjFhY2VkZTkiLCJ0eXAiOiJPZmZsaW5lIiwiYXpwIjoib2ZmbGluZS10b2tlbi1nZW5lcmF0b3IiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiI3Njc5ZjFkZC1jNWQzLTQzOTYtODcxNC1iNzM3OTlhY2JjMDQiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiXX0sInJlc291cmNlX2FjY2VzcyI6eyJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19fQ.RvLpFEJb3diy-ETsWYA0N15qt_dYAllkZYLEHLKpqVk5zcvIjozNDyaX7bgNyPSZ6quqIkbkE73B72n66GEKH33D2w4mlaqfWFsN6kYqVGv1F1KD5qxIqgR2hk52VPDy2f95aZOkUNioBwg_zKO-TXItQH_OPkTmlO223c-6XUPBOblUu3zfmZr2xArRU7uiR-okW8CWdRy86dSY0rEw1yR_mZ75JzDOXrOAFLNgbgYQNcFsdJ_P7wPbnVt-lUk6LR8CFF2OKVmneVlNaBrmFMbmQPxbH9gvKvg4Q1xG155Kdw85tMhG-DDvR86OeXAF3IfFWarTcFcZIPxkmxzY-g"
DEVICE1="95ECD130589BCBAB30B1412A7981091E3922DC60"
DEVICE2="988667325047395643"
JOB_NAME="test123"
BUILD_NUMBER="12"
SCRIPT="PRIVATE:shellTest.xml"

exeScript()
{
    l_scrip=$1
    l_device=$2
    URL_EXE="https://$CLOUD/services/executions?operation=execute&scriptkey=$l_scrip&responseformat=xml&param.DUT=$l_device&param.jobName=$JOB_NAME&param.jobNumber=$BUILD_NUMBER&securityToken=$TOKEN"
    response="$(curl $URL_EXE)"
    execID=$( echo $response | awk -v FS="(executionId>|</executionId)" '{print $2}')
    

}

waitForScript()
{
    
    l_execID=$1
    msg=$2
 
    URL_CHECK_STATUS="https://$CLOUD/services/executions/$l_execID?operation=status&securityToken=$TOKEN"
    scriptResponse="$(curl $URL_CHECK_STATUS)"

    if [[ $scriptResponse == *"errorMessage"* ]] 
    then
        checkError "$scriptResponse"
    fi

    # if script ended in this point can be device in use or script2 ended before script 1
    if [[ $scriptResponse == *"status\":\"Completed\""* ]]
    then
        echo "going to check error"
        checkError "$scriptResponse"
    else
         status="loop"
    fi
    # echo $status
    while [ "$status" != "done" ]
    do
        echo $response
        response="$(curl $URL_CHECK_STATUS)"
        if [[ $response == *"status\":\"Completed\""* ]]
        then
           status="done"
         fi
        sleep 5
        #echo 'in wait loop:'$msg
        #echo 'status:'$status

    done
}

checkError()
{
     l_res=$1
     if [[ $l_res == *"Failed to execute script - Access denied - bad credentials"* ]] 
    then
      echo "Failed to execute script - Access denied - bad credentials"
      exit -1
    elif  [[ $l_res == *"device is in use"* ]] 
    then
        echo "device in use"
    elif  [[ $l_res == *"errorMessage"* ]] 
    then
      echo $l_res
    fi
}

verifyScriptStatus()
{
    pass=0 #true
    l_exeID=$1
    URL_CHECK_STATUS="https://$CLOUD/services/executions/$l_execID?operation=status&securityToken=$TOKEN"
    scriptResponse="$(curl $URL_CHECK_STATUS)"
    #echo " * * * * * * scriptResponse"+$scriptResponse
    if [[ $scriptResponse != *"flowEndCode\":\"Success\""* ]]
    then
      pass=1 #false
     
    fi
    return $pass
}


#execute script 1
exeScript $SCRIPT $DEVICE1
if [[ $response == *"<executionId>"* ]] 
then
    executeScript1=$execID

    #execute script 2
    exeScript $SCRIPT $DEVICE2
    executeScript2=$execID
    waitForScript  $executeScript1 device1
    waitForScript  $executeScript2 device2 

    # verify both scripts 
    # if both ended with error type "error - need to notify"
    verifyScriptStatus executeScript1
    scrip1Status=$?
    if [ $scrip1Status == 1 ]
    then
        verifyScriptStatus executeScript2
        scrip2Status=$?
        if [ $scrip2Status == 1 ]
        then
            echo "Both scripts ended woth ERROR "
            exit -1
        fi
    fi

else
    checkError "$response"
fi