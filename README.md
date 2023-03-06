## system architecture
![system architecture](./system_overview.drawio.svg)

## SetUp

### terraform backend S3 bucket
- if the terraform backend S3 bucket does not exist, create it.(defaultName = terraform-tfstate-fabric-dev)

### terraform with asdf
```bash
asdf plugin add terraform
asdf install terraform latest
asdf global terraform <バージョン>
```

### Edit terraform.tfvars
- Get a secret key from your AWS account administrator.

## Deploy
### from local
- It must be run locally the first time to load environment variables.
```bash
terraform init
terraform plan
terraform apply
```
### by merge reository (Github)
- Deployment is automatically performed when this repository is updated

### form local push to ECR(fabric-ca)
```bash
# build fabric-ca docker image
cd <fabric-ca direcotry>
make docker
# push to ECR
export AWS_PROFILE=<your profile> 
aws ecr get-login-password | docker login --username AWS --password-stdin https://054911450566.dkr.ecr.ap-northeast-1.amazonaws.com/fabric-ca
docker tag hyperledger/fabric-ca:latest 054911450566.dkr.ecr.ap-northeast-1.amazonaws.com/fabric-ca:latest
docker push 054911450566.dkr.ecr.ap-northeast-1.amazonaws.com/fabric-ca:latest
```

