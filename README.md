## SetUp

### terraform with asdf
```bash
asdf plugin add terraform
asdf install terraform latest
asdf global terraform <バージョン>
```

### Edit terraform.tfvars
- Get a secret key from your AWS account administrator.


## Deploy
```bash
terraform plan
terraform apply
```

## Push to ECR(fabric-ca)
```bash
# build fabric-ca docker image
cd <fabric-ca direcotry>
make docker
# push to ECR
aws ecr get-login-password | docker login --username AWS --password-stdin https://054911450566.dkr.ecr.ap-northeast-1.amazonaws.com/fabric-ca
docker tag hyperledger/fabric-ca:latest 054911450566.dkr.ecr.ap-northeast-1.amazonaws.com/fabric-ca:latest
docker push 054911450566.dkr.ecr.ap-northeast-1.amazonaws.com/fabric-ca:latest
```