
resource "aws_ecs_cluster" "reto" {
  name = "reto-banbif-cluster"

  tags = {
    Project     = "reto-examen"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}


resource "aws_vpc" "reto" {
  cidr_block           = "10.50.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "reto-banbif-vpc"
  }
}

resource "aws_subnet" "publica" {
  vpc_id                  = aws_vpc.reto.id
  cidr_block              = "10.50.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "reto-banbif-subnet-publica"
  }
}

resource "aws_internet_gateway" "reto" {
  vpc_id = aws_vpc.reto.id

  tags = {
    Name = "reto-banbif-igw"
  }
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.reto.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.reto.id
  }

  tags = {

    Name = "reto-banbif-rutas-publicas"
  }
}

resource "aws_route_table_association" "publica" {
  subnet_id      = aws_subnet.publica.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_security_group" "ecs" {

  name        = "reto-banbif-ecs-sg"
  description = "Acceso publico al endpoint Spring Boot"

  vpc_id = aws_vpc.reto.id

  ingress {
    description = "HTTP Spring Boot"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Salida a Internet"
    from_port   = 0

    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {

    Name = "reto-banbif-ecs-sg"
  }


}



resource "aws_iam_role" "ecs_execution" {
  name = "reto-banbif-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project = "reto-examen"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "reto" {
  name              = "/ecs/reto-banbif"
  retention_in_days = 7

  tags = {
    Project = "reto-examen"
  }
}



resource "aws_ecs_task_definition" "reto" {
  family                   = "reto-banbif-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "reto-examen"
      image     = "161987605856.dkr.ecr.us-east-1.amazonaws.com/reto-examen:1.0"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.reto.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Project = "reto-examen"
  }
}

resource "aws_ecs_service" "reto" {
  name            = "reto-banbif-service"
  cluster         = aws_ecs_cluster.reto.id
  task_definition = aws_ecs_task_definition.reto.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.publica.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution,
    aws_route_table_association.publica
  ]

  tags = {
    Project = "reto-examen"
  }
}
