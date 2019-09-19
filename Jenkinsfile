pipeline {
    options {
        disableConcurrentBuilds()
    }
    agent {
        label 'master'
    }
    stages {
        stage('Git Checkout'){
            steps {
                git branch: "master", credentialsId: "jenkins-x-github-ci", url: env.GIT_URL
                sh 'git checkout master && git pull --rebase'
            }
        }
        stage('Google Login'){
            steps {
                sh '/usr/bin/gcloud auth activate-service-account --key-file=/secrets/google-storage/docker-registry-rw.json'
            }
        }
        stage('Map Platform Version to Component Versions'){
            steps {
                sh './versions.sh map && cat versions'
            }
        }
        stage('Commit Version Map'){
            steps {
                withCredentials([usernamePassword(credentialsId: "jenkins-x-github-ci", passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                    sh '''
                    git config user.email "it@contiamo.com" && git config user.name "Contiamo CI"
                    git add versions
                    git commit -m "Updating version map"
                    export GIT_URL_NO_HTTPS=$(echo ${GIT_URL} | sed \'s/https:\\/\\///g\')
                    git push https://\${GIT_USERNAME}:\${GIT_PASSWORD}@\${GIT_URL_NO_HTTPS}
                    '''
                }
            }
        }
    }
    post { 
        always { 
            cleanWs()
        }
    }
}