resource "aws_ecs_cluster" "cluster" {
  name = "ctf"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "ctf-ubuntu"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ctf.arn
  cpu                      = 256
  memory                   = 1024
  container_definitions = jsonencode([
    {
      name      = "ctf-ubuntu"
      image     = "${aws_ecr_repository.ctf_ubuntu.repository_url}:latest"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 22
          port          = "tcp"
          hostPort      = 22
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "ctf",
          "awslogs-stream-prefix" = "ctf"
          "awslogs-region"        = "ca-central-1"
        }
      }
    }
  ])
}

resource "aws_ecr_repository" "ctf_ubuntu" {
  name = "ctf_ubuntu"
}

resource "aws_ecs_service" "ctf" {
  name            = "ctf"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 15
  # iam_role        = aws_iam_role.ctf.arn
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.ctf.arn
    container_name   = "ctf-ubuntu"
    container_port   = 22
  }

  network_configuration {
    subnets          = ["subnet-3fb16045"]
    assign_public_ip = true
    security_groups  = ["sg-0be0917a7b442fac0"]
  }
}

resource "aws_iam_role" "ctf" {
  name        = "ctf"
  description = "for 1password ctf"

  assume_role_policy = data.aws_iam_policy_document.ctf_assumption.json
}
#
data "aws_iam_policy_document" "ctf_assumption" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"

      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "ctf_access" {
  statement {
    sid    = "AllowAccessToECRForPullingImages"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:ListTagsForResource",
    ]
    resources = [aws_ecr_repository.ctf_ubuntu.arn]
  }

  statement {
    sid    = "AllowAccessToECRForPullingImages2"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudWatchAccess"
    effect = "Allow"
    actions = [
      "logs:GetLogEvents",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
    "logs:DescribeLogGroups"]
    resources = ["*"]
  }

}

resource "aws_iam_role_policy_attachment" "ctf_permissions" {
  role       = aws_iam_role.ctf.name
  policy_arn = aws_iam_policy.ctf.arn
}

resource "aws_iam_policy" "ctf" {
  name        = "ctf"
  description = "A list of the limited, hopefully, permissions for the prefect instance"
  policy      = data.aws_iam_policy_document.ctf_access.json
}

