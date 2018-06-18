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
        stage('Building for python2') {       
            steps { 
                sh 'make -j'
                sh 'make doc'
		sh 'make install'
            }
        }
	stage('Testing fortran library') {
            steps { 
                sh 'make junittest' ;
                junit 'src/tests/test_result*xml'
            }
	}
        stage('Testing for python2') {       
            steps { 
	        withEnv(['PYTHONPATH=/home/fluidity/lib/python2.7/site-packages',
		         'LD_LIBRARY_PATH=/home/fluidity/lib']) {
		    sh 'cd python; python2 test_libspud_junit.py' 
                }
                junit 'python/test_result*xml'
		sh 'rm python/test_result*xml'
            }
        }
/*	stage('Building for python3') {       
            steps { 
		sh 'cd python; python3 setup.py install; cd ..'
            }
        }
	stage('Testing for python3') {       
            steps { 
		sh 'cd python; python3 test_libspud_junit.py' 
                junit 'python/test_result*xml'
		sh 'rm python/test_result*xml'
            }
        } */
	stage('Building documentation') {       
            steps { 
		sh 'make doc'
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
