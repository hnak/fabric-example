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
      value = "ap-northeast-1"
    }
 
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "054911450566"
    }
 
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "fabric-ca"
    }
 
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
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
  
  vpc_config {
    vpc_id = aws_vpc.dev-env.id
 
    subnets = [
      aws_subnet.public-web.id
    ]
 
    security_group_ids = [
      aws_security_group.public-web-sg.id,
    ]
  }
}

# resource "aws_codebuild_webhook" "fabric-ca-build" {
#   project_name = aws_codebuild_project.fabric-ca-build.name
  
#   authentication_configuration {
#     secret_token = var.github_personal_access_token
#   }

#   filter_group {
#     filter {
#       exclude_matched_pattern = false
#       pattern                 = "PUSH"
#       type                    = "EVENT"
#     }
#     filter {
#       exclude_matched_pattern = false
#       pattern                 = "main"
#       type                    = "HEAD_REF"
#     }
#   }
# }