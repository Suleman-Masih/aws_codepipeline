################ task execution role #######################

resource "aws_iam_role" "task_execution_role" {
  name                = "${var.prefix.environment}-${var.prefix.name}-ecs-task-role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess", "arn:aws:iam::aws:policy/AmazonSSMFullAccess"]
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}



########################## Task role ############################

data "aws_iam_policy_document" "ecs_service" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_service" {
  name               = "${var.prefix.environment}-${var.prefix.name}-ecs-service-role"
  assume_role_policy = join("", data.aws_iam_policy_document.ecs_service.*.json)
}

data "aws_iam_policy_document" "ecsexec" {
  statement {
    sid    = ""
    effect = "Allow"

    actions = [
      "ssm:*",
      "secretsmanager:GetSecretValue",
      "ecs:ExecuteCommand",
      "ec2:DescribeTags",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:UpdateContainerInstancesState",
      "ecs:Submit*",
      "application-autoscaling:*",
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:EnableAlarmActions",
      "iam:CreateServiceLinkedRole"
    ]

    resources = [
      "*",
    ]
  }

}





#-----------------------------------------------
#   Code Build IAM role
#-----------------------------------------------
resource "aws_iam_policy" "codebuild_policy" {
  name        = "${var.prefix.environment}-${var.prefix.name}-codebuild-policy"
  description = "IAM policy for ${var.prefix.environment}-${var.prefix.name} CodeBuild project"

  policy = <<-POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObject"
      ],
      "Resource": ["arn:aws:s3:::artifact-bucket/*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codepipeline:PutJobSuccessResult",
        "codepipeline:PutJobFailureResult"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "codebuild_role" {
  name = "${var.prefix.environment}-${var.prefix.name}-codebuild-role"

  assume_role_policy = <<-POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  policy_arn = aws_iam_policy.codebuild_policy.arn
  role       = aws_iam_role.codebuild_role.name
}


#--------------------------------------------------------
#             CodeDeploy
#--------------------------------------------------------


resource "aws_iam_role" "codedeploy_ecs_role" {
  name = "codedeploy-ecs-role"

  assume_role_policy = <<-POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["codedeploy.amazonaws.com", "ecs-tasks.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "codedeploy_ecs_policy_attachment" {
  name       = "codedeploy-ecs-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole" # Use an existing CodeDeploy managed policy or create a custom one
  roles      = [aws_iam_role.codedeploy_ecs_role.name]
}