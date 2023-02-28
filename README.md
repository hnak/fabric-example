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

## Override config file(fabric-ca)
```bash
# Override config
cp -p docker/fabric-ca-server/Dockerfile <fabric-ca direcotry>/images/fabric-ca/
cp -p docker/fabric-ca-server/fabric-ca-server-config.yaml <fabric-ca direcotry>/images/fabric-ca/
```

## Push to ECR(fabric-ca)
```bash
# build fabric-ca docker image
cd <fabric-ca direcotry>
make docker
# push to ECR
export AWS_PROFILE=<your profile> 
aws ecr get-login-password | docker login --username AWS --password-stdin https://054911450566.dkr.ecr.ap-northeast-1.amazonaws.com/fabric-ca
docker push 054911450566.dkr.ecr.ap-northeast-1.amazonaws.com/fabric-ca:latest
```

