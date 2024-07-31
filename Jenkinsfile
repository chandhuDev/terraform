pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID  = credentials('aws_key')
        AWS_SECRET_ACCESS_KEY  = credentials('aws_secret')
        AWS_REGION = 'us-east-2'
        AWS_FILE = credentials('aws_secret_file')
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/chandhuDev/terraform'
            }
        }
        stage('Check Sudoers') {
            steps {
                script {
                    writeFile file: 'variable.tfvars' , text : "${env.AWS_FILE}"
                }
            }
        }

        stage('terraform apply') {
            steps {
                sh(script: '''
                    cat variable.tfvars
                    sudo yum install -y yum-utils
                    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
                    sudo yum -y install terraform

                    cat terraform --version
                    find ./terraform -type f -name 'main.tf' -exec sed -i 's/us-east-1/us-east-2/g' {} +

                    sed -i 's/us-east-1/us-east-2/g' ${AWS_FILE} && sed -i 's/ami-0fe630eb857a6ec83/ami-0aa8fc2422063977a/' ${AWS_FILE}
                    cd terraform
                    sed -i 's/terrform-tf.state/terrform-tf.st/g' main.tf
                    sed -i '89,97 s/^/#/' main.tf
                    sed -n '89,97 p' main.tf
                    terraform init
                    terraform fmt
                    terraform plan -var-file=${AWS_FILE}
                    terraform apply -var-file=${AWS_FILE} -auto-approve
               ''')
            }
        }
        stage('terraform destroy') {
            steps {
                sh(script: '''
                cd terraform
                terraform destroy -var-file=${AWS_FILE} -auto-approve
                ''')
            }
        }
    }
}
