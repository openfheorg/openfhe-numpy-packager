import os
import subprocess
import sys
from setuptools import setup, find_packages
from setuptools.dist import Distribution
# from setuptools.command.install import install

class BinaryDistribution(Distribution):
    def has_ext_modules(self):
        return True

def get_ci_vars(filepath):
    ci_vars = {}
    with open(filepath, 'r') as f:
        for line in f:
            # leading/trailing whitespace
            line = line.strip()
            # empty lines or comments
            if not line or line.startswith('#'):
                continue

            if '=' in line:
                key, value = line.split('=', 1)
                ci_vars[key.strip()] = value.strip()

    return ci_vars

# get values from ci-vars.sh
filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ci-vars.sh")
ci_vars = get_ci_vars(filepath)
###
get_version = (
    'bash -c "source ./scripts/common-functions.sh && get_wheel_version \\"{}\\" \\"{}\\" \\"{}\\" \\"{}\\""'
).format(ci_vars["OS_RELEASE"], ci_vars["OPENFHE_NUMPY_TAG"], ci_vars["WHEEL_MINOR_VERSION"], ci_vars["WHEEL_TEST_VERSION"])

get_long_descr = (
    'bash -c "source ./scripts/common-functions.sh && get_long_description \\"{}\\" \\"{}\\""'
).format(ci_vars["OS_NAME"], ci_vars["OS_RELEASE"])

###################################################################################

version=subprocess.run(get_version, shell=True, capture_output=True, text=True).stdout.strip()
long_description=subprocess.run(get_long_descr, shell=True, capture_output=True, text=True).stdout.strip()
setup(
    name='openfhe-numpy',
    version=version,
    description='Numpy Matrix extention for OpenFHE C++ library.',
    long_description=long_description,
    long_description_content_type='text/markdown',  # format
    author='OpenFHE Team',
    author_email='contact@openfhe.org',
    url='https://github.com/openfheorg/openfhe-numpy',
    license='BSD-2-Clause',
    packages=find_packages(where='build/wheel-root'),
    package_dir={'': 'build/wheel-root'},
    include_package_data=True,
    package_data={
        'openfhe_numpy': ['*.so', 'build-config.txt'],
    },
    install_requires=[
        'openfhe>=1.3.0,<1.4.0',
        'numpy>=1.24'
    ],
    python_requires=f">={sys.version_info.major}.{sys.version_info.minor}",
    distclass=BinaryDistribution,
    classifiers=[
        "Operating System :: POSIX :: Linux",
        # add other classifiers as needed
    ],
    zip_safe=False,
)

