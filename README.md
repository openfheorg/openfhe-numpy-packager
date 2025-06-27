# This repo is a collection of scripts to build a python wheel for openfhe-numpy.


## How to build a new wheel

### Docker build

1. Adjust repo versions/settings in [ci-vars.sh](https://github.com/openfheorg/openfhe-numpy-packager/blob/main/ci-vars.sh) as needed. The changes will be grabbed by the build script.
2. Run [build_openfhe_numpy_wheel_docker_ubu_24.sh](https://github.com/openfheorg/openfhe-numpy-packager/blob/main/build_openfhe_numpy_wheel_docker_ubu_24.sh) for Ubuntu 24.04 or the build script for your operaing system (if available)  
   - The script builds a new docker and the wheel in it.
   - When the wheel is ready, the script creates a new directory (`wheel_<operating system name>`. ex. "wheel_ubuntu_24.04" for Ubuntu 24.04) on your local machine and copies the *.whl and *.tar.gz files from the docker to that directory.

### Manual build

1. Prerequisites:  
   Before building, make sure you have installed all dependencies **(do not clone these repos)**:
   - For [openfhe-development](https://github.com/openfheorg/openfhe-development).
   - For [openfhe-python](https://pybind11.readthedocs.io/en/stable/installing.html) you need to have only 2 packages installed: python3 and python3-pip.
2. Build:  
   - Adjust repo versions/settings in [ci-vars.sh](https://github.com/openfheorg/openfhe-numpy-packager/blob/main/ci-vars.sh) as needed. The changes will be grabbed by the build script.
   - Run [build_openfhe_numpy_wheel.sh](https://github.com/openfheorg/openfhe-numpy-packager/blob/main/build_openfhe_numpy_wheel.sh).
   - The package built for distribution will be available in **./build/dist**.
   - The wheel includes a file **openfhe/build-config.txt** with all settings from ci-vars.sh used to build the wheel. 
