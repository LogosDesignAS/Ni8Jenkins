pipeline {
    agent { label 'agent2' }
    stages {
    	// Print all versions of the packages
        stage('Versions') {
            steps {
                sh '''
                	# Print Docker Package Versions
			echo $NODE_NAME - $(nproc) cores
			uname -a
			echo ============================================================
			cmake --version
			echo ============================================================
			gcc --version
			echo ============================================================
			cppcheck --version
			echo ============================================================
			git --version
			echo ============================================================
			wget --version 
			echo ============================================================
			cpio --version
			echo ============================================================
			unzip -v
			echo ============================================================
			rsync --version
			echo ============================================================
			bc --version
			echo ============================================================
			mkimage -V
			echo ============================================================
			echo "buildroot version: "$BUILDROOT_VERSION
			echo ============================================================
                '''
            }
        }
        // Fetch the buildroot external
        stage('Fetching') {
            steps {
                sh '''
                	# Fetch Software from bitbucket master branch (Buildroot external) (Using SSH)
			cd git/

			# Initialise the SSH agent
			eval "$(ssh-agent -s)"
			# This should point to the bitbucket SSH private key
			eval "$(ssh-add $HOMEDIR/.ssh/id_ed25519)"

			# Clone ni8buildroot 
			git clone git@bitbucket.org:logospaymentsolutions/ni8buildroot.git
			cd ni8buildroot

			# Checkout the main branch
			git checkout main

			# Create a Symbolic link to the ni8buildroot -> buildroot-external
			ln -s $HOMEDIR/git/ni8buildroot $HOMEDIR/buildroot-external
			cd ../../

			# Create Symbolic Links
			#ln -s buildroot-$BUILDROOT_VERSION-dl buildroot-dl
			ln -s buildroot-$BUILDROOT_VERSION buildroot

			cd buildroot/

                '''
            }
        }
        // Run static Code Analysis here on: U-boot, OP-TEE and Logos Lib?

        // Run Unit Test on Logos Lib and ?
        
        // We need to build buildroot for both production and development, but first development
        stage('Building Buildroot Development') {
            steps {
                sh '''
		        # Shell Script for building the development version of buildroot

			# Give argument to specify the configuration file for either production or development
			make BR2_EXTERNAL=$HOMEDIR/buildroot-external logosnicore8dev_defconfig

			# The Build it all
			make

			# Because of a known build error the build fails at the end
			# A workaround is to force a rebuild
			make
			
                '''
            }
            // Save the Artifacts (Generated images)
            post {
                success {
                    script {
		 	archiveArtifacts artifacts: 'output/images/*', fingerprint: true
                    }
                }
            }
        }
        
        // In the future we might want to run qemu here testing the kernel and application?
        
        stage('Creating SDK') {
            steps {
                sh '''
                	make sdk
                '''
            }
           // Save the Artifacts (SDK)
            post {
                success {
                    script {
		 	archiveArtifacts artifacts: 'output/host/*', fingerprint: true
                    }
                }
            }
        }
        
        /*
        *	Run Smoketest
        *	Eg. SSH into a Raspberry Pi connected to Nicore8 and any carrier board
        *	Run a Python Script that uses the serial connection to:  Load the built bootloader, OP-TEE and kernel. 
        * 	Run simple test to verify that verify still are functional. Minimal number of tests are carried out in a
        * 	Smoketest
        */
        
        
        // Cleanup and Repeat for production
	stage('Cleanup') {
            steps {
                sh '''
                	make clean
                	cd ..
                	rm -r $HOMEDIR/git/ni8buildroot
                '''
            }

        }
        
        
    }
}
