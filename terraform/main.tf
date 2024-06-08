provider "aws" {
  region = "us-east-1"
}

# Define variables
variable "image_url" {
  description = "Docker image URL"
  default     = "madhusudhan1909/hello-world-app:latest"
}

variable "subnets" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = ["subnet-05fa270580ea5da44", "subnet-07026d6cdadb34b73"]
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
  default     = ["sg-080632b19e474257b"]
}

resource "aws_ecs_cluster" "example" {
  name = "example-cluster"
}

resource "aws_ecs_task_definition" "example" {
  family                   = "hello-world-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([{
    name      = "hello-world-app"
    image     = var.image_url
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action   = "sts:AssumeRole"
      Effect   = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "example" {
  name            = "hello-world-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.example.name
}

output "ecs_service_name" {
  value = aws_ecs_service.example.name
}


