# IAM Role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
    name = "codepipeline-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Service = "codepipeline.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "codepipeline_attach" {
    role = aws_iam_role.codepipeline_role.name
    policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

# IAM Policy for CodePipeline to use CodeStarConnection
resource "aws_iam_policy" "codestar_connections_policy" {
  name        = "codestar-connections-policy"
  description = "Policy to allow CodePipeline to use CodeStar Connections"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "codestar-connections:UseConnection"
      Resource = "arn:aws:codestar-connections:*:*:connection/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codestar_policy_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codestar_connections_policy.arn
}

# IAM Policy for CodePipeline to upload artifacts to S3
resource "aws_iam_role_policy" "codepipeline_s3_access" {
  name = "codepipeline-s3-access-policy"
  role = "codepipeline-role"  

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      Resource = [
        "arn:aws:s3:::codepipeline-artifacts-talha",        
        "arn:aws:s3:::codepipeline-artifacts-talha/*" 
      ]
    }]
  })
}

# IAM Policy for CodePipeline to trigger CodeBuild
resource "aws_iam_role_policy_attachment" "codebuild_access" {
  role       = aws_iam_role.codepipeline_role.name 
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}


# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

# IAM Policy for CodeBuild to create CloudWatch Logs
resource "aws_iam_role_policy" "codebuild_cloudwatch_policy" {
  name = "codebuild-cloudwatch-logs-policy"
  role = aws_iam_role.codebuild_role.name
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = [
        "arn:aws:logs:eu-west-2:463470963000:log-group:/aws/codebuild/lambda-edge-build:*",
        "arn:aws:logs:eu-west-2:463470963000:log-group:/aws/codebuild/lambda-cloud-build:*",
        "arn:aws:logs:eu-west-2:463470963000:log-group:/aws/codebuild/lambda-sagemaker-training-job-build:*",
        "arn:aws:logs:eu-west-2:463470963000:log-group:/aws/codebuild/lambda-neo-compilation-build:*",
        "arn:aws:logs:eu-west-2:463470963000:log-group:/aws/codebuild/lambda-greengrass-creation-build:*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_cloudwatch_logs" {
  role       = aws_iam_role.codebuild_role.name 
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

# IAM Policy to allow CodeBuild to access S3 pipeline artifacts
resource "aws_iam_role_policy" "codebuild_s3_policy" {
  name = "codebuild-s3-access-policy"
  role = "codebuild-role"  

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::codepipeline-artifacts-talha",          
          "arn:aws:s3:::codepipeline-artifacts-talha/*"  
        ]
      }
    ]
  })
}

# IAM Role for CodeDeploy
resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

# IAM Policy to allow CodePipeline to create CodeDeploy deployments
resource "aws_iam_role_policy" "codepipeline_codedeploy_policy" {
  name = "codepipeline-codedeploy-access-policy"
  role = "codepipeline-role"  

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentGroup",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:GetApplicationRevision"
        ],
        Resource = [
          "arn:aws:codedeploy:eu-west-2:463470963000:deploymentgroup:lambda-apps/*",
          "arn:aws:codedeploy:eu-west-2:463470963000:deploymentconfig:*",
          "arn:aws:codedeploy:eu-west-2:463470963000:application:lambda-apps*"
        ]
      }
    ]
  })
}

# IAM Policy to allow CodeDeploy to access S3 pipeline artifacts
resource "aws_iam_role_policy" "codedeploy_s3_policy" {
  name = "codedeploy-s3-access-policy"
  role = "codedeploy-role"  

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ],
        Resource = [
          "arn:aws:s3:::codepipeline-artifacts-talha",          
          "arn:aws:s3:::codepipeline-artifacts-talha/*"  
        ]
      }
    ]
  })
}


# Create CodeBuild Project for Lambda at the Edge (Greengrass)
resource "aws_codebuild_project" "lambda_edge_build" {
    name = "lambda-edge-build"
    service_role = aws_iam_role.codebuild_role.arn

    source {
        type = "GITHUB"
        location = "https://github.com/talhazaman2001/edge-healthcare-project.git"
        buildspec = "Lambda-Greengrass-LSTM/lambda-edge-buildspec.yml"
    }

    artifacts {
      type = "S3"
      location = aws_s3_bucket.codepipeline_artifacts.bucket
    }

    environment {
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/standard:5.0"
      type = "LINUX_CONTAINER"
      privileged_mode = true
    }
}

# Create CodeBuild Project for Lambda in the Cloud
resource "aws_codebuild_project" "lambda_cloud_build" {
    name = "lambda-cloud-build"
    service_role = aws_iam_role.codebuild_role.arn

    source {
        type = "GITHUB"
        location = "https://github.com/talhazaman2001/edge-healthcare-project.git"
        buildspec = "Lambda-WebSocket/lambda-cloud-buildspec.yml"
    }

    artifacts {
      type = "S3"
      location = "${aws_s3_bucket.codepipeline_artifacts.bucket}"
    }

    environment {
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/standard:5.0"
      type = "LINUX_CONTAINER"
      privileged_mode = true
    }
}

# Create CodeBuild Project for Lambda SageMaker Training Job
resource "aws_codebuild_project" "lambda_sagemaker_training_job_build" {
    name = "lambda-sagemaker-training-job-build"
    service_role = aws_iam_role.codebuild_role.arn

    source {
        type = "GITHUB"
        location = "https://github.com/talhazaman2001/edge-healthcare-project.git"
        buildspec = "Lambda-SageMaker-Training-Job/lambda-sagemaker-training-buildspec.yml"
    }

    artifacts {
      type = "S3"
      location = "${aws_s3_bucket.codepipeline_artifacts.bucket}"
    }

    environment {
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/standard:5.0"
      type = "LINUX_CONTAINER"
      privileged_mode = true
    }
}

# Create CodeBuild Project for Lambda SageMaker Neo Compilation Job
resource "aws_codebuild_project" "lambda_neo_compilation_build" {
    name = "lambda-neo-compilation-build"
    service_role = aws_iam_role.codebuild_role.arn

    source {
        type = "GITHUB"
        location = "https://github.com/talhazaman2001/edge-healthcare-project.git"
        buildspec = "Lambda-Neo-Compilation/lambda-neo-compilation-buildspec.yml"
    }

    artifacts {
      type = "S3"
      location = "${aws_s3_bucket.codepipeline_artifacts.bucket}"
    }

    environment {
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/standard:5.0"
      type = "LINUX_CONTAINER"
      privileged_mode = true
    }
}

# Create CodeBuild Project for Lambda Greengrass Creation
resource "aws_codebuild_project" "lambda_greengrass_creation_build" {
    name = "lambda-greengrass-creation-build"
    service_role = aws_iam_role.codebuild_role.arn

    source {
        type = "GITHUB"
        location = "https://github.com/talhazaman2001/edge-healthcare-project.git"
        buildspec = "Lambda-Greengrass-Creation/greengrass-creation-buildspec.yml"
    }

    artifacts {
      type = "S3"
      location = "${aws_s3_bucket.codepipeline_artifacts.bucket}"
    }

    environment {
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/standard:5.0"
      type = "LINUX_CONTAINER"
      privileged_mode = true
    }
}

# Create CodeDeploy Application for Lambda at Edge and in Cloud
resource "aws_codedeploy_app" "lambda_codedeploy_apps" {
    name = "lambda-apps"
    compute_platform = "Lambda"
}

# CodeDeploy Deployment Group for Lambda at Edge
resource "aws_codedeploy_deployment_group" "lambda_edge_deployment_group" {
    app_name = aws_codedeploy_app.lambda_codedeploy_apps.name
    deployment_group_name = "LambdaEdgeBlueGreenDeploymentGroups"
    deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"
    service_role_arn = aws_iam_role.codedeploy_role.arn 

    auto_rollback_configuration {
      enabled = true
      events = ["DEPLOYMENT_FAILURE"]
    }

    deployment_style {
      deployment_option = "WITH_TRAFFIC_CONTROL"
      deployment_type = "BLUE_GREEN"
    }
}

# CodeDeploy Deployment Group for Lambda in Cloud
resource "aws_codedeploy_deployment_group" "lambda_cloud_deployment_group" {
    app_name = aws_codedeploy_app.lambda_codedeploy_apps.name
    deployment_group_name = "LambdaCloudBlueGreenDeploymentGroups"
    deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"
    service_role_arn = aws_iam_role.codedeploy_role.arn 

    auto_rollback_configuration {
      enabled = true
      events = ["DEPLOYMENT_FAILURE"]
    }

    deployment_style {
      deployment_option = "WITH_TRAFFIC_CONTROL"
      deployment_type = "BLUE_GREEN"
    }
}

# CodeDeploy Deployment Group for Lambda SageMaker training Job
resource "aws_codedeploy_deployment_group" "lambda_sagemaker_training_job_deployment_group" {
    app_name = aws_codedeploy_app.lambda_codedeploy_apps.name
    deployment_group_name = "LambdaSageMakerTrainingJobBlueGreenDeploymentGroups"
    deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"
    service_role_arn = aws_iam_role.codedeploy_role.arn 

    auto_rollback_configuration {
      enabled = true
      events = ["DEPLOYMENT_FAILURE"]
    }

    deployment_style {
      deployment_option = "WITH_TRAFFIC_CONTROL"
      deployment_type = "BLUE_GREEN"
    }
}

# CodeDeploy Deployment Group for Lambda Neo Compilation Job 
resource "aws_codedeploy_deployment_group" "lambda_neo_compilation_deployment_group" {
    app_name = aws_codedeploy_app.lambda_codedeploy_apps.name
    deployment_group_name = "LambdaNeoCompilationBlueGreenDeploymentGroups"
    deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"
    service_role_arn = aws_iam_role.codedeploy_role.arn 

    auto_rollback_configuration {
      enabled = true
      events = ["DEPLOYMENT_FAILURE"]
    }

    deployment_style {
      deployment_option = "WITH_TRAFFIC_CONTROL"
      deployment_type = "BLUE_GREEN"
    }
}

# CodeDeploy Deployment Group for Lambda Greengrass Creation 
resource "aws_codedeploy_deployment_group" "lambda_greengrass_creation_deployment_group" {
    app_name = aws_codedeploy_app.lambda_codedeploy_apps.name
    deployment_group_name = "LambdaGreengrassCreationBlueGreenDeploymentGroups"
    deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"
    service_role_arn = aws_iam_role.codedeploy_role.arn 

    auto_rollback_configuration {
      enabled = true
      events = ["DEPLOYMENT_FAILURE"]
    }

    deployment_style {
      deployment_option = "WITH_TRAFFIC_CONTROL"
      deployment_type = "BLUE_GREEN"
    }
}


# Create CodeStar Connection
resource "aws_codestarconnections_connection" "github_connection" {
    name = "my-github-connection"
    provider_type = "GitHub"
}

# CodePipeline to automate entire deployment process
resource "aws_codepipeline" "lambda_pipeline" {
    name = "lambda-pipeline"
    role_arn = aws_iam_role.codepipeline_role.arn

    artifact_store {
      type = "S3"
      location = "${aws_s3_bucket.codepipeline_artifacts.bucket}"
    }

    stage {
        name = "Source"
        
        action {
            name = "GitHubSource"
            category = "Source"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = ["SourceOutput"]
            configuration = {
                ConnectionArn = "arn:aws:codestar-connections:eu-west-2:463470963000:connection/5bcc636d-e780-4617-a94e-957c222cf902"
                FullRepositoryId = "talhazaman2001/edge-healthcare-project"
                BranchName = "main"
            }
        }
    }

    stage {
        name = "Build"
        
        action {
            name = "Lambda_Edge_Build"
            category = "Build"
            owner = "AWS"
            provider = "CodeBuild"
            version = "1"
            input_artifacts = ["SourceOutput"]
            output_artifacts = ["BuildOutputEdge"]
            configuration = {
                ProjectName = "${aws_codebuild_project.lambda_edge_build.name}"
            }
        }
        
        action {
            name = "Lambda_Cloud_Build"
            category = "Build"
            owner = "AWS"
            provider = "CodeBuild"
            version = "1"
            input_artifacts = ["SourceOutput"]
            output_artifacts = ["BuildOutputCloud"]
            configuration = {
                ProjectName = "${aws_codebuild_project.lambda_cloud_build.name}"
            }
        }

        action {
          name = "Lambda_SageMaker_Training_Job_Build"
          category = "Build"
          owner = "AWS"
          provider = "CodeBuild"
          version = "1"
          input_artifacts = ["SourceOutput"]
          output_artifacts = ["BuildOutputSageMaker"]
          configuration = {
            ProjectName = "${aws_codebuild_project.lambda_sagemaker_training_job_build.name}"
          }
        }

        action {
          name = "Lambda_Neo_Compilation_Job_Build"
          category = "Build"
          owner = "AWS"
          provider = "CodeBuild"
          version = "1"
          input_artifacts = ["SourceOutput"]
          output_artifacts = ["BuildOutputNeo"]
          configuration = {
            ProjectName = "${aws_codebuild_project.lambda_neo_compilation_build.name}"
          }
        }

        action {
          name = "Lambda_Greengrass_Creation_Build"
          category = "Build"
          owner = "AWS"
          provider = "CodeBuild"
          version = "1"
          input_artifacts = ["SourceOutput"]
          output_artifacts = ["BuildOutputGreengrass"]
          configuration = {
            ProjectName = "${aws_codebuild_project.lambda_greengrass_creation_build.name}"
          }
        }       
    }

    stage {
        name = "Deploy"
      
        action {
            name = "Lambda_Edge_Deploy"
            category = "Deploy"
            owner = "AWS"
            provider = "CodeDeploy"
            version = "1"
            input_artifacts = ["BuildOutputEdge"]
            configuration = {
                ApplicationName = aws_codedeploy_app.lambda_codedeploy_apps.name
                DeploymentGroupName = "${aws_codedeploy_deployment_group.lambda_edge_deployment_group.deployment_group_name}"
            }
        }

        action {
            name = "Lambda_Cloud_Deploy"
            category = "Deploy"
            owner = "AWS"
            provider = "CodeDeploy"
            version = "1"
            input_artifacts = ["BuildOutputCloud"]
            configuration = {
                ApplicationName = aws_codedeploy_app.lambda_codedeploy_apps.name
                DeploymentGroupName = "${aws_codedeploy_deployment_group.lambda_cloud_deployment_group.deployment_group_name}"
            }
        }

        action {
          name = "Lambda_SageMaker_Training_Job_Deploy"
          category = "Deploy"
          owner = "AWS"
          provider = "CodeDeploy"
          version = "1"
          input_artifacts = ["BuildOutputSageMaker"]
          configuration = {
            ApplicationName = aws_codedeploy_app.lambda_codedeploy_apps.name
            DeploymentGroupName = "${aws_codedeploy_deployment_group.lambda_sagemaker_training_job_deployment_group.deployment_group_name}"
          }
        }

        action {
          name = "Lambda_Neo_Compilation_Job_Deploy"
          category = "Deploy"
          owner = "AWS"
          provider = "CodeDeploy"
          version = "1"
          input_artifacts = ["BuildOutputNeo"]
          configuration = {
            ApplicationName = aws_codedeploy_app.lambda_codedeploy_apps.name
            DeploymentGroupName = "${aws_codedeploy_deployment_group.lambda_neo_compilation_deployment_group.deployment_group_name}"
          }
        }

        action {
          name = "Lambda_Greengrass_Creation_Deploy"
          category = "Deploy"
          owner = "AWS"
          provider = "CodeDeploy"
          version = "1"
          input_artifacts = ["BuildOutputGreengrass"]
          configuration = {
            ApplicationName = aws_codedeploy_app.lambda_codedeploy_apps.name
            DeploymentGroupName = "${aws_codedeploy_deployment_group.lambda_greengrass_creation_deployment_group.deployment_group_name}"
          }
        }
    }
}

