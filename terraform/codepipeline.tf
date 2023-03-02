####################
# S3
####################
resource "aws_s3_bucket" "pipeline" {
  bucket = "fabric-ca-pipeline"
}

resource "aws_s3_bucket_acl" "pipeline_bucket_acl" {
  bucket = aws_s3_bucket.pipeline.id
  acl    = "private"
}

####################
# SSM
####################
resource "aws_ssm_parameter" "github_personal_access_token" {
  name        = "github-personal-access-token"
  description = "github-personal-access-token"
  type        = "String"
  value       = var.github_personal_access_token
}

####################
# CodePipeline
####################
resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "pipeline" {
  name     = "pipeline-fabric-ca-server-deploy"
  role_arn = aws_iam_role.codepipeline_service_role.arn
 
  artifact_store {
    location = aws_s3_bucket.pipeline.bucket
    type     = "S3"
  }
 
  stage {
    name = "Source"
 
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = "hnak/fabric-ca"
        BranchName           = "main"
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }
 
  stage {
    name = "Build"
 
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
 
      configuration = {
        ProjectName = aws_codebuild_project.fabric-ca-build.name
      }
    }
  }
 
  stage {
    name = "Deploy"
 
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"
 
      configuration = {
        ClusterName = aws_ecs_cluster.fabric-cluster.arn
        ServiceName = aws_ecs_service.fabric-ca.name
        FileName    = "imagedef.json"
      }
    }
  }
}
 
resource "aws_codepipeline_webhook" "webhook" {
  name            = "webhook-fabric-ca-deploy"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.pipeline.name
 
  authentication_configuration {
    secret_token = var.github_personal_access_token
  }
 
  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

resource "github_repository_webhook" "webhook" {
  configuration {
    url          = aws_codepipeline_webhook.webhook.url
    content_type = "json"
    insecure_ssl = false
    secret       = var.github_personal_access_token
  }
  events     = ["push"]
  repository = var.github_repository_name
}
