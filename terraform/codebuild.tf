resource "aws_codebuild_project" "fabric-ca-build" {
  name         = "fabric-ca-build"
  description  = "fabric-ca-build"
  service_role = aws_iam_role.codebuild_service_role.arn
 
  artifacts {
    type = "NO_ARTIFACTS"
  }
 
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
 
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_default_region
    }
 
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
    }
 
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.image_repo_name
    }
 
    environment_variable {
      name  = "IMAGE_TAG"
      value = var.image_tag
    }

    environment_variable {
      name  = "DOCKERHUB_USER"
      value = var.dockerhub_user
    }
    environment_variable {
      name  = "DOCKERHUB_PASS"
      value = var.dockerhub_pass
    }
  }
 
  source {
    type            = "GITHUB"
    location        = "https://github.com/hnak/fabric-ca.git"
    git_clone_depth = 1
    buildspec       = "buildspec.yml"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_SOURCE_CACHE"]
  }
  
}