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
       
        stage('Fetching Buildroot') {
            steps {
                sh '''
                    mkdir -p ${WORKSPACE}/git

                    #Fetch Buildroot
                    curl -sSL "https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz" -o /${WORKSPACE}/buildroot-${BUILDROOT_VERSION}.tar.gz

                    tar -xzf ${WORKSPACE}/buildroot-${BUILDROOT_VERSION}.tar.gz -C ${WORKSPACE}
                    rm /${WORKSPACE}/buildroot-${BUILDROOT_VERSION}.tar.gz
                '''
            }
        }
        
        
        // Fetch the buildroot external
        stage('Fetching Buildroot External') {
            steps {
                sh '''
                	# Fetch Software from bitbucket master branch (Buildroot external) (Using SSH)
                    cd ${WORKSPACE}/git

                    # Initialise the SSH agent
                    eval "$(ssh-agent -s)"
                    # This should point to the bitbucket SSH private key
                    eval "$(ssh-add $HOMEDIR/.ssh/id_ed25519)"

                    # Clone ni8buildroot
                    git clone git@bitbucket.org:logospaymentsolutions/ni8buildroot.git
                    cd ${WORKSPACE}/git/ni8buildroot

                    # Checkout the dev branch
                    git checkout dev

                    # Create a Symbolic link to the ni8buildroot -> buildroot-external
                    ln -s ${WORKSPACE}/git/ni8buildroot ${WORKSPACE}/buildroot-external
                    cd ../../

                    # Create Symbolic Links
                    #ln -s buildroot-$BUILDROOT_VERSION-dl buildroot-dl
                    ln -s ${WORKSPACE}/buildroot-$BUILDROOT_VERSION buildroot

                    cd ${WORKSPACE}/buildroot/
                '''
            }
        }
        // Run static Code Analysis here on: U-boot, OP-TEE and Logos Lib?
	stage('Static Code Analysis') {
            steps {
                sh '''
                    echo "Perform Static Code Analysis - TODO: Add Static Code analysis functionality"
                '''
            }

        }

        // Run Unit Test on Logos Lib and ?
        stage('Unit Tests') {
            steps {
                sh '''
                    echo "Perform Unit Tests - TODO: Add Unit Test functionality"
                '''
            }

        }
        
        // We need to build buildroot for both production and development, but first development
        stage('Building Buildroot Development') {
            steps {
            	script {
            		try {
				sh '''
                    # Shell Script for building the development version of buildroot
                    cd ${WORKSPACE}/buildroot/

                    # Give argument to specify the configuration file for either production or development
                    make BR2_EXTERNAL=${WORKSPACE}/buildroot-external logosnicore8dev_defconfig

                    # The Build it all
                    make
				'''
			} catch (Exception e) {
			  	sh '''
                    # Go to Directory
                    cd ${WORKSPACE}/buildroot/

                    # Print Error
                        #echo 'Exception occurred: ' + e.toString()

                        # Known error: try make again to resolve it and continue build
                        make
      				'''
      				currentBuild.result = 'SUCCESS'
  			}
		}
            }
        }
        
        // In the future we might want to run qemu here testing the kernel and application?
        
        stage('Creating SDK - Development') {
            steps {
                sh '''
                    # Navigate to the build directory
                    cd ${WORKSPACE}/buildroot/

                    # Make SDK
                    make sdk
                '''
            }
        }
       // Upload build files to tftp server
	stage('Upload Files to TFTP - Dev') {
            steps {
                sh '''
                       # Navigate to the build output directory
                    cd ${WORKSPACE}/buildroot/output

                    # TODO: Add code to commit files to the tftp
                '''
            }

        }
        
        /*
        *	Run Smoketest
        *	Eg. SSH into a Raspberry Pi connected to Nicore8 and any carrier board
        *	Run a Python Script that uses the serial connection to:  Load the built bootloader, OP-TEE and kernel. 
        * 	Run simple test to verify that verify still are functional. Minimal number of tests are carried out in a
        * 	Smoketest
        */
	stage('Smoketest - Dev') {
            steps {
                sh '''
                    echo "Connect to another agent to run the smoketest - TODO: Add smoketest functionality"
                '''
            }

        }
        
        
        // Cleanup and Repeat for production
	stage('Cleanup - Dev') {
            steps {
                sh '''
                    # Navigate to the build directory
                    cd ${WORKSPACE}/buildroot/

                    # Clean up
                    make clean
                '''
            }

        }
        
         // We need to build buildroot for both production and development,now build for production
        stage('Building Buildroot Production') {
            steps {
            	script {
            		try {
				sh '''
                    # Shell Script for building the development version of buildroot
                    cd ${WORKSPACE}/buildroot/

                    # Give argument to specify the configuration file for either production or development
                    make BR2_EXTERNAL=${WORKSPACE}/buildroot-external logosnicore8_defconfig

                    # The Build it all
                    make
				'''
			} catch (Exception e) {
			  	sh '''
                    # Go to Directory
                    cd ${WORKSPACE}/buildroot/

                    # Print Error
                        #echo 'Exception occurred: ' + e.toString()

                        # Known error: try make again to resolve it and continue build
                        make
      				'''
      				currentBuild.result = 'SUCCESS'
  			}
		}
            }
        }
        
        // In the future we might want to run qemu here testing the kernel and application?
        
        stage('Creating SDK - Prod') {
            steps {
                sh '''
                	# Navigate to the build directory
                	cd ${WORKSPACE}/buildroot/
                	
                	# Make SDK
                	make sdk
                '''
            }
        }
       // Upload build files to tftp server
	stage('Upload Files to TFTP - Prod') {
            steps {
                sh '''
                       # Navigate to the build output directory
                        cd ${WORKSPACE}/buildroot/output

                        # TODO: Add code to commit files to the tftp
                '''
            }

        }
        
        /*
        *	Run Smoketest
        *	Eg. SSH into a Raspberry Pi connected to Nicore8 and any carrier board
        *	Run a Python Script that uses the serial connection to:  Load the built bootloader, OP-TEE and kernel. 
        * 	Run simple test to verify that verify still are functional. Minimal number of tests are carried out in a
        * 	Smoketest
        */
	stage('Smoketest - Prod') {
            steps {
                sh '''
			        echo "Connect to another agent to run the smoketest - TODO: Add smoketest functionality"
                '''
            }

        }
        
        
        // Cleanup after building both the Production and development image
	stage('Cleanup - Prod') {
            steps {
                sh '''
                       # Navigate to the build directory
                        cd ${WORKSPACE}/buildroot/

                        # Clean up
                        make clean
                        cd ..
                '''
            }

        }

             // We need to build buildroot for both production and development,now build for production
            stage('Building Buildroot Toolbox') {
                steps {
                    script {
                        try {
                    sh '''
                        # Shell Script for building the development version of buildroot
                        cd ${WORKSPACE}/buildroot/

                        # Give argument to specify the configuration file for either production or development
                        make BR2_EXTERNAL=${WORKSPACE}/buildroot-external logosnicore8toolboxdev_defconfig

                        # The Build it all
                        make
                    '''
                } catch (Exception e) {
                    sh '''
                        # Go to Directory
                        cd ${WORKSPACE}/buildroot/

                        # Print Error
                            #echo 'Exception occurred: ' + e.toString()

                            # Known error: try make again to resolve it and continue build
                            make
                        '''
                        currentBuild.result = 'SUCCESS'
                }
            }
                }
            }

            // In the future we might want to run qemu here testing the kernel and application?

            stage('Creating SDK - Toolbox') {
                steps {
                    sh '''
                        # Navigate to the build directory
                        cd ${WORKSPACE}/buildroot/

                        # Make SDK
                        make sdk
                    '''
                }
            }
           // Upload build files to tftp server
        stage('Upload Files to TFTP - Toolbox') {
                steps {
                    sh '''
                           # Navigate to the build output directory
                        cd ${WORKSPACE}/buildroot/output

                        # TODO: Add code to commit files to the tftp
                    '''
                }

            }

        stage('Generate report') {
                steps {
                    sh '''
                        # Install make 4.4 since 4.3 doesn't work with pkg-stats
                        cd ${WORKSPACE}/buildroot
                       /home/jenkins/make-4.4/make pkg-stats
                       /home/jenkins/make-4.4/make legal-info
                    '''
                }

            }

        stage('Upload report to tftp') {
                steps {
                    sh '''
                           # Navigate to the build output directory
                        cd ${WORKSPACE}/buildroot/output
                        
                        cp output/pkg-stats.html /srv/www/ni8/buildroot_report/

                        cp -R output/legal-info /srv/www/ni8/buildroot_report/
                        
                        # TODO: Add code to commit files to the tftp
                    '''
                }

            }

            /*
            *	Run Smoketest
            *	Eg. SSH into a Raspberry Pi connected to Nicore8 and any carrier board
            *	Run a Python Script that uses the serial connection to:  Load the built bootloader, OP-TEE and kernel.
            * 	Run simple test to verify that verify still are functional. Minimal number of tests are carried out in a
            * 	Smoketest
            */
        stage('Smoketest - Toolbox') {
                steps {
                    sh '''
                echo "Connect to another agent to run the smoketest - TODO: Add smoketest functionality"
                    '''
                }

            }


            // Cleanup after building both the Production and development image
        stage('Cleanup - Toolbox') {
                steps {
                    sh '''
                           # Navigate to the build directory
                        cd ${WORKSPACE}/buildroot/

                        # Clean up
                        make clean
                        cd ..
                        rm -r ${WORKSPACE}/git/ni8buildroot
                        rm -r ${WORKSPACE}/buildroot
                        rm -r ${WORKSPACE}/buildroot-$BUILDROOT_VERSION
                        rm -r ${WORKSPACE}/buildroot-external
                    '''
                }
         }
    }
	// Save the Artifacts (Generated images)
	post {
		// Save artifacts to tftp server - moved to other stage
		/*
		success {
		    script {
		 	archiveArtifacts artifacts: '${WORKSPACE}/buildroot/output/images/emmc.img', fingerprint: true
		    }
		}
		*/
		// Cleanup when failure happens
		failure {
		      script {
				sh '''
                    echo "The Build has failed, cleanup"
                        # Navigate to the build directory
                    cd ${WORKSPACE}/buildroot/

                    # Clean up
                    make clean
                    cd ..
                    rm -r ${WORKSPACE}/git/ni8buildroot
                    rm -r ${WORKSPACE}/buildroot
                    rm -r ${WORKSPACE}/buildroot-$BUILDROOT_VERSION
                    rm -r ${WORKSPACE}/buildroot-external
				'''
			}  
		}
	}
}
