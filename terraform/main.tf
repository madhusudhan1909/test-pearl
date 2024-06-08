provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "example" {
  name = "example-cluster"
}

resource "aws_ecs_task_definition" "example" {
  family                   = "example-task"
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([{
    name      = "example-container"
    image     = "your-docker-image-url"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
      protocol      = "tcp"
    }]
  }])
}

resource "aws_ecs_service" "example" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 1

  network_configuration {
    subnets = ["subnet-05fa270580ea5da44", "subnet-07026d6cdadb34b73"]
    security_groups = ["sg-080632b19e474257b"]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.example]
}

