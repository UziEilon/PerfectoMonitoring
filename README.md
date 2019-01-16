# PerfectoMonitoring

Perfecto Monitor solution contains 3 components
* Perfecto Scripts - Scripts on real devices
* Jenkis - scheduler, execute Perfecto scripts, send notifications to user in case of errors
* Perfecto Dashboard - Monitoring live dashboard reports


This project contains:
* Jenkins lib: Explain how to configure and store the shall scripts which execute the scripts from jenkin
* Notifications: Java code which send notification based on errors 

## Jenkins config:
Add the following parameters:
* Cloud
* Token
* Script

![import](resources/JenkinsParams.png?raw=true "params")

In order to execute the scripts (in parallel on two devices) add device1 and device2 as parameters too.
![import](resources/paramsList.png?raw=true "paramsList")

Copy the Jenkins/exec.sh script into the Jenkins
![import](resources/build.png?raw=true "build")

## Perfecto Dashboard 
Perfecto reporting tool shows the execution dashboard, this view used to show the monitoring status
![import](resources/report.png?raw=true "report")
