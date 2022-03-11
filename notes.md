
## Log Dec 2021

Overall, azure devops is a frustrating experience on many levels. Too many instances where an approach is conceptually clear enough, but the implementations in AZDO is at best a slow, tortuous process with a perplexingly obtuse system and documenation.

Tried to set up service connections, but on-prem bitbucket server is not supported by the YAML format in azdo (why?)

So, then trying to pass a "secret pipeline variable" (despite my double about the whole security model)

https://docs.microsoft.com/en-us/azure/devops/pipelines/process/variables?view=azure-devops&tabs=yaml%2Cbatch#secret-variables

Thankfully bitbucket doc on PAT is rather to the point https://confluence.atlassian.com/bitbucketserver/personal-access-tokens-939515499.html

HOWEVER, for some reasons BB PAT generation tends to create them with slash characters "/" which is a special character for URLs so [need to be replace with "%2F"](https://stackoverflow.com/a/57732424/2752565)

Format: git clone https://username:blahblahblah@bitbucketserver.com/scm/projectname/teamsinspace.git

e.g. 

`git clone https://per202:abcdeabcdeabcdeabcdeabcde%2Feabcde%2Fabcde@bitbucket.csiro.au/scm/sf/numerical-sl-cpp.git`




`docker build -t swift2-easi-debbuild .`

Interesting read while looking for how to specifgy sustom cmake_mdule_path

[Making a deb package with CMake/CPack and hosting it in a private APT repositor](https://decovar.dev/blog/2021/09/23/cmake-cpack-package-deb-apt/)

Building the uchronia deb package:

```
CMake Error at CMakeLists.txt:23 (find_package):
  By not providing "FindNetCDF.cmake" in CMAKE_MODULE_PATH this project has
  asked CMake to find a package configuration file provided by "NetCDF", but
  CMake did not find one.

  Could not find a package configuration file provided by "NetCDF" with any
  of the following names:

    NetCDFConfig.cmake
    netcdf-config.cmake
```

To clean up installs under /use/local: 

```
cd ${GITHUB_REPOS}/moirai
cd build
$SUDO_CMD make uninstall

cd ${GITHUB_REPOS}/rcpp-interop-commons
cd build
$SUDO_CMD make uninstall

cd ${GITHUB_REPOS}/threadpool
# Threadpool needed by wila and swift. No makefile target for install, so:
$SUDO_CMD rm -rf ${INSTALL_PREFIX}/include/threadpool*

cd ${GITHUB_REPOS}/wila
cd build
$SUDO_CMD make uninstall

cd ${CSIRO_BITBUCKET}/numerical-sl-cpp
cd build
$SUDO_CMD make uninstall

cd ${CSIRO_BITBUCKET}/datatypes/datatypes
cd build
$SUDO_CMD make uninstall

cd ${CSIRO_BITBUCKET}/swift/libswift
cd build
$SUDO_CMD make uninstall

sudo ldconfig
```
