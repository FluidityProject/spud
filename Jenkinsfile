pipeline {

    agent { 
        docker {
	    image 'fluidity/baseimages:xenial'
            label 'dockerhost'
        } 
    }
    environment {
        OMPI_MCA_btl = '^openib'
    }
    stages {
        stage('Configuring') {   
            steps { 
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
	stage('Building libspud for python3') {       
            steps { 
		sh 'cd python; python3 setup.py install --prefix=/home/fluidity; cd ..'
            }
        }
	stage('Testing for python3') {       
            steps { 
                withEnv(['PYTHONPATH=/home/fluidity/lib/python3.5/site-packages',
		         'LD_LIBRARY_PATH=/home/fluidity/lib']) {
		    sh 'cd python; python3 test_libspud_junit.py'
                }
                junit 'python/test_result*xml'
		sh 'rm python/test_result*xml'
            }
        }
	stage('Building documentation') {       
            steps { 
		sh 'make doc'
            }
        }
    }
}
