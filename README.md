# Build pipelines for hydrologic simulation and forecasting tools

## Overview

This repository contains material to streamline the build, testing and possible deployment of hydrologic simulation and forecasting tools.

These tools have been re-used in projects undertaken for DWL.

As of 2022-03 this contains one pipeline:

* Under /packages is a pipeline building debian packages of SWIFT2 and its dependencies.
  * The pipeline uses secret pipeline variable to pass a personal access token to check out git repositories over ssh. This is a better alternative than copying ssh keys into docker containters and trying to conceal them.

Other pipelines on the roadmap or wishlist:

* building a docker image for simulation and forecasting with SWIFT2 via a Jupyter front end. This relates notably to runing on EASI with a custom image, because for instance some of the packages (ipywidgets, bqplot) are not and should not be in the default easi image (bloat).

## TODO

* Define a set of docker images with/for swift, starting with an image with debian packages ready to build from source
  * Where to store? csiro docker registry but not sure if/how to access from cloud pipeline.
## Related work

ssh://git@bitbucket.csiro.au:7999/sf/easi-hydro-forecast.git

## Contact

jean-michel.perraud@csiro.au
david.robertson@csiro.au
