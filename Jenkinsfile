pipeline{
    agent {label 'linux'}

    environment{
        AWS_ACCOUNT_ID = "AdminAccess-853219709078"
        AWS_REGION = "ap-south-1"
        ECR_REPO_NAME = "my-demo-app"
        ECS_CLUSTER_NAME = my-dem-cluster
        
        IMAGE_NAME = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${env.BUILD_ID}"
    }

     stages {
        // This stage runs for ALL branches
        stage('Build & Push to ECR') {
            steps {
                script {
                    echo "Building and pushing image: ${env.IMAGE_NAME}"
                    // Build the Docker image
                    sh "docker build -t ${env.IMAGE_NAME} ."

                    // Login to ECR
                    sh "aws ecr get-login-password --region ${env.AWS_REGION} | docker login --username AWS --password-stdin ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com"

                    // Push the image
                    sh "docker push ${env.IMAGE_NAME}"
                }
            }
        }

        // --- DEPLOY TO DEVELOPMENT ---
        // This stage ONLY runs when the branch is 'develop'
        stage('Deploy to Dev') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    echo "Deploying to Development Environment..."
                    // We use a heredoc to write a JSON file for the task definition
                    // This allows us to inject variables like the image name and environment name
                    sh """
                    cat > task-definition.json <<EOF
                    {
                        "family": "my-demo-task-dev",
                        "networkMode": "awsvpc",
                        "containerDefinitions": [
                            {
                                "name": "my-demo-container",
                                "image": "${env.IMAGE_NAME}",
                                "portMappings": [
                                    {
                                        "containerPort": 3000,
                                        "protocol": "tcp"
                                    }
                                ],
                                "environment": [
                                    {
                                        "name": "ENVIRONMENT_NAME",
                                        "value": "Dev"
                                    }
                                ]
                            }
                        ],
                        "requiresCompatibilities": [
                            "FARGATE"
                        ],
                        "cpu": "256",
                        "memory": "512"
                    }
                    EOF
                    """
                    // Register the new task definition revision with AWS
                    sh "aws ecs register-task-definition --cli-input-json file://task-definition.json --region ${env.AWS_REGION}"

                    // Update the ECS service to use the new task definition, forcing a new deployment
                    sh "aws ecs update-service --cluster ${env.ECS_CLUSTER} --service my-demo-service-dev --task-definition my-demo-task-dev --force-new-deployment --region ${env.AWS_REGION}"
                }
            }
        }

        // --- DEPLOY TO PRODUCTION ---
        // This stage ONLY runs when the branch is 'main'
        stage('Deploy to Prod') {
            when {
                branch 'main'
            }
            stages { // We can nest stages for more complex workflows
                stage('Approval Gate') {
                    steps {
                        // This crucial step pauses the pipeline and waits for human confirmation.
                        // The timeout ensures it doesn't wait forever.
                        timeout(time: 15, unit: 'MINUTES') {
                            input message: "Deploy to Production Environment?", submitter: 'admin' // Or your username
                        }
                    }
                }
                stage('Perform Production Deployment') {
                    steps {
                        script {
                            echo "Deploying to Production Environment..."
                            // The task definition is almost identical, but points to the Prod environment
                            sh """
                            cat > task-definition.json <<EOF
                            {
                                "family": "my-demo-task-prod",
                                "networkMode": "awsvpc",
                                "containerDefinitions": [
                                    {
                                        "name": "my-demo-container",
                                        "image": "${env.IMAGE_NAME}",
                                        "portMappings": [
                                            {
                                                "containerPort": 3000,
                                                "protocol": "tcp"
                                            }
                                        ],
                                        "environment": [
                                            {
                                                "name": "ENVIRONMENT_NAME",
                                                "value": "Prod"
                                            }
                                        ]
                                    }
                                ],
                                "requiresCompatibilities": [
                                    "FARGATE"
                                ],
                                "cpu": "256",
                                "memory": "512"
                            }
                            EOF
                            """
                            sh "aws ecs register-task-definition --cli-input-json file://task-definition.json --region ${env.AWS_REGION}"
                            sh "aws ecs update-service --cluster ${env.ECS_CLUSTER} --service my-demo-service-prod --task-definition my-demo-task-prod --force-new-deployment --region ${env.AWS_REGION}"
                        }
                    }
                }
            }
        }
    }
}