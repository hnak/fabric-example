####################
# S3
####################
resource "aws_s3_bucket" "infra_pipeline" {
  bucket = "fabric-infra-pipeline"
}

resource "aws_s3_bucket_acl" "infra_pipeline_bucket_acl" {
  bucket = aws_s3_bucket.infra_pipeline.id
  acl    = "private"
}

####################
# CodePipeline
####################

resource "aws_codepipeline" "infra_pipeline" {
  name     = "pipeline-fabric-infra-deploy"
  role_arn = aws_iam_role.codepipeline_service_role.arn
 
  artifact_store {
    location = aws_s3_bucket.infra_pipeline.bucket
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
        FullRepositoryId     = "hnak/fabric-infra"
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
        ProjectName = aws_codebuild_project.fabric-infra-build.name
      }
    }
  }
 
}
 
resource "aws_codepipeline_webhook" "infra_webhook" {
  name            = "webhook-fabric-infra-deploy"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.infra_pipeline.name
 
  authentication_configuration {
    secret_token = var.github_personal_access_token
  }
 
  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

resource "github_repository_webhook" "infra_webhook" {
  configuration {
    url          = aws_codepipeline_webhook.infra_webhook.url
    content_type = "json"
    insecure_ssl = false
    secret       = var.github_personal_access_token
  }
  events     = ["push"]
  repository = var.github_infra_repo_name
}
