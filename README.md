# sdc-k8s
Running Streamsets Data Collector as Kubernetes container

#create secret 'mysecrets' with DPM org admin username and password

kubectl create secret generic mysecrets --from-literal=dpmuser=<username@orgid> --from-literal=dpmpassword=<password>
