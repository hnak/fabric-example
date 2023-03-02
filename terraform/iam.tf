### IAM Role ###
resource "aws_iam_role" "ecs_task_execution_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          }
          Sid = ""
        },
      ]
      Version = "2012-10-17"
    }
  )
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
  description = "Allows ECS tasks to call AWS services on your behalf."
  name        = "ecsTaskExecutionRole"
  path        = "/"
}

resource "aws_iam_role" "codebuild_service_role" {
  name               = "role-codebuild-service-role"
  assume_role_policy = file("./roles/codebuild_assume_role.json")
}
 
resource "aws_iam_role" "codepipeline_service_role" {
  name               = "role-codepipeline-service-role"
  assume_role_policy = file("./roles/codepipeline_assume_role.json")
}

resource "aws_iam_role_policy" "codebuild_service_role" {
  name   = "build-policy"
  role   = aws_iam_role.codebuild_service_role.name
  policy = file("./roles/codebuild_build_policy.json")
}
 
resource "aws_iam_role_policy" "codepipeline_service_role" {
  name   = "pipeline-policy"
  role   = aws_iam_role.codepipeline_service_role.name
  policy = file("./roles/codepipeline_pipeline_policy.json")
}