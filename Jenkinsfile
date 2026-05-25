pipeline {
    agent any

    environment {
        SSH_CRED_ID = 'github-ssh-key'
        ANSIBLE_PLAYBOOK = 'ansible/update.yml'
    }

    stages {
        stage('1. Checkout SCM') {
            steps {
                echo 'Getting latest version GitHub'
                checkout scm
            }
        }

        stage('2. Quality Gate (Syntax Check)') {
            steps {
                echo 'Check syntax'
                sh "ansible-playbook ${ANSIBLE_PLAYBOOK} --syntax-check"
            }
        }

        stage('3. Deploy Infrastructure') {
            steps {
                echo 'Starting ansble'
                sh "ansible-playbook ${ANSIBLE_PLAYBOOK}"
            }
        }

        stage('4. Verification') {
            steps {
                echo 'Check'
                sh 'curl -f http://prometheus:9090/-/healthy'
            }
        }
    }

    post {
        success {
            echo 'Updated'
        }
        failure {
            echo 'Failure'
        }
    }
}
