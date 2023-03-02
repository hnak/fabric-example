variable "fabric-ca_repo_url" {}
variable "db_user" {}
variable "db_password" {}
variable "db_name" {}

resource "aws_ecr_repository" "fabric-ca" {
  name                 = "fabric-ca"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_log_group" "fabric-ca" {
  name              = "/ecs/project/dev/fabric-ca"
  retention_in_days = 30
}

resource "aws_ecs_cluster" "fabric-cluster" {
  name = "fabric-cluster"
}

resource "aws_ecs_task_definition" "fabric-ca" {
  family                   = "fabric-ca-server"
  container_definitions    = jsonencode([{
    name            = "fabric-ca-server"
    image           = var.fabric-ca_repo_url
    portMappings    = [{
      containerPort = 7054
      hostPort      = 7054
    }]
    environment     = [{
      name  = "FABRIC_CA_SERVER_DB_TYPE"
      value = "postgres"
    },
    {
      name  = "FABRIC_CA_SERVER_DB_DATASOURCE"
      value = "host=${aws_db_instance.test-db.address} port=5432 user=${var.db_user} password=${var.db_password} dbname=${var.db_name} sslmode=require"
    }]
    logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-region : "ap-northeast-1"
          awslogs-group : aws_cloudwatch_log_group.fabric-ca.name
          awslogs-stream-prefix : "fabric-ca"
        }
      }
  }])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "fabric-ca" {
  name            = "fabric-ca-server"
  cluster         = aws_ecs_cluster.fabric-cluster.arn
  task_definition = aws_ecs_task_definition.fabric-ca.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    assign_public_ip = true
    security_groups = [aws_security_group.public-web-sg.id]
    subnets         = [aws_subnet.public-web.id]
  }
#   load_balancer {
#     target_group_arn = aws_lb_target_group.fabric-ca.arn
#     container_name   = "fabric-ca-server"
#     container_port   = 7054
#   }
  deployment_controller {
    type = "ECS"
  }
}
