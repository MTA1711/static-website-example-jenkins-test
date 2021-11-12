// @Library('test-shared-library')_

pipeline {
    environment {
        IMAGE_NAME  = "web_application"
        IMAGE_TAG   = "latest"
        STAGING_ENV = "mta1711-web-application-qa"
        PROD_ENV    = "mta1711-web-application-prod"
    }
    agent none
    stages {
        stage('Build image') {
            agent any
            steps {
                script {
                    sh 'docker build -t mta1711/$IMAGE_NAME:$IMAGE_TAG .'
                }
            }
        }

        stage('Run container based on built image') {
            agent any
            steps {
                script {
                    sh '''
                        docker run --name $IMAGE_NAME -d -p 80:5000 -e PORT=5000 mta1711/$IMAGE_NAME:$IMAGE_TAG
                        sleep 5
                    '''
                }
            }
        }

        stage('Test image') {
            agent any
            steps {
                script {
                    sh '''
                        curl localhost > index.txt
                        grep -q "Welcome" index.txt
                        rm index.txt
                    '''
                }
            }
        }

        stage('clean container') {
            agent any
            steps {
                script {
                    sh '''
                        docker stop $IMAGE_NAME
                        docker rm $IMAGE_NAME
                    '''
                }
            }
        }

        stage('Push image in QA and deploy it') {
            agent any
            environment {
                HEROKU_API_KEY  = credentials('heroku_api_key')
            }
            when {
                expression {GIT_BRANCH == 'origin/master'}
            }
            steps {
                script {
                    sh '''
                        heroku container:login
                        heroku create $STAGING_ENV || echo "project already exist"
                        heroku container:push -a $STAGING_ENV web
                        heroku container:release -a $STAGING_ENV web
                    '''
                }
            }
        }

        stage('Push image in prod and deploy it') {
            agent any
            environment {
                HEROKU_API_KEY  = credentials('heroku_api_key')
            }
            when {
                expression {GIT_BRANCH == 'origin/master'}
            }
            steps {
                script {
                    sh '''
                        heroku container:login
                        heroku create $PROD_ENV || echo "project already exist"
                        heroku container:push -a $PROD_ENV web
                        heroku container:release -a $PROD_ENV web
                    '''
                }
            }
        }
    }
    // post {
    //     always {
    //         script {
    //             slackNotifier currentBuild.result
    //         }
    //     }
    // }
}