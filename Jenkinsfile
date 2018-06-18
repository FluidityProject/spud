pipeline {

    agent { 
        docker {
	    image 'fluidity/baseimages:xenial'
            label 'azure-linux-2core'
        } 
    }
    environment {
        OMPI_MCA_btl = '^openib'
    }
    stages {
        stage('Configuring') {   
            steps { 
                slackSend "Build started - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                sh './configure --prefix=\$HOME' 
            }
        }    
        stage('Building') {       
            steps { 
                sh 'make -j'
                sh 'make doc'
		sh 'make install'
            }
        }
        stage('Testing') {       
            steps { 
                sh 'make junittest' ;
                junit 'src/tests/test_result*xml'
            }
        }
    }
    post {
        aborted {
            slackSend(color: '#DEADED',
	              message: "Build aborted - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)")
        }
	success {
	    slackSend (color: 'good',
	     message: "Build completed successfully - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)")
        }
	unstable {
	    slackSend(color: 'warning',
	              message: "Build completed with test failures - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)")
            script {
                currentBuild.result = "FAILURE"
            }
        }
	failure {
	    slackSend(color: 'danger',
	              message: "Build failed - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)")
        }
    }
}
