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