pipeline {
    agent any

    environment {
        SSH_CRED_ID = 'github-ssh-key'
        ANSIBLE_PLAYBOOK = 'ansible/update.yml'
	DEPLOY_PLAYBOOK = 'ansible/nodexporter.yml'
        INVENTORY = 'ansible/inventory.ini'
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
		sh "ansible-playbook ${DEPLOY_PLAYBOOK} --syntax-check"

            }
        }
	
	stage('3. Bootstrap SSH Keys') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'vm-sudo-password', 
                                                 passwordVariable: 'VM_PASS', 
                                                 usernameVariable: 'VM_USER')]) {
                    echo 'Deploying SSH keys to new hosts...'
                    sh """
                    ansible-playbook -i ${INVENTORY} ansible/bootstrap.yml \
                    -e "ansible_password=${VM_PASS}" \
                    --extra-vars "ansible_become_password=${VM_PASS}"
                    """
                }
            }
        }
	
        stage('4. Deploy Infrastructure') {
            steps {
		sshagent([SSH_CRED_ID]) {
		    withCredentials([
			string(credentialsId: 'bot-token', variable: 'TG_TOKEN'),
                        string(credentialsId: 'chat-id', variable: 'TG_CHAT_ID'),
			usernamePassword(credentialsId: 'vm-sudo-password', 
                                         passwordVariable: 'VM_PASS', 
                                         usernameVariable: 'VM_USER')
                    ]) {
                        echo 'Starting ansble'
		        sh """
                        ansible-playbook -i ${INVENTORY} ${ANSIBLE_PLAYBOOK} \
                        -e "telegram_token=${TG_TOKEN} telegram_chat_id=${TG_CHAT_ID}"
                        """
			sh "ansible-playbook -i ${INVENTORY} ${DEPLOY_PLAYBOOK} -e 'ansible_become_password=${VM_PASS}'"
		    }
		}
            }
        }

        stage('5. Verification') {
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
