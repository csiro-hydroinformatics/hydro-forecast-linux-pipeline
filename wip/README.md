# Work in Progress

## 2022-04

Trying to get a docker image of a jupyter-lab server running, with swift/python stack installed not from source but from debian/python packages

Relates to easi-hydro-forecast repository

the repo hydro-fc-packaging already has a pipeline that produces universal artifacts. Borrowed from WAA tool, so to download the artifacts also reusing the WAA script.

Creating a new azure PAT for the digital water organisation: swift_pkgs_dnld

then dlswift.sh

Now create a base image; swift with python bindings installed.

```sh
cd ~/src/hydro-fc-packaging/wip/pyswift
cp -r ~/swift_setup/swift_setup/latest ./pkgs
sudo docker build . # don't know why sudo required here this time around. Connection to server with base image refused otherwise. Weird.
```

`docker build -t swift-jlab .`

`docker run -v $HOME/tmp/test:/home/jovyan/work -p 8888:8888 -t swift-jlab`
BUT Whether I run this as sudo or not, the mapped volume fails to be read/written to

```sh
docker run \
  --name swift-jlab-test \
  --mount source=swift-nb,target=/home/jovyan/work \
  --user $(id -u):$(id -g) \
  -p 8888:8888 \
  -t swift-jlab
```

docker rm $(docker ps -a -q)

```sh
AZ_REPO=$(lsb_release -cs)
echo $AZ_REPO
sudo apt-get install azure-cli
az login
az extension add --name azure-devops
```

```sh
az artifacts universal download --organization "https://dev.azure.com/OD222236-DigWaterAndLandscapes/" --project "072b5225-8b0e-4eff-9dba-2f116e1b3464" --scope project --feed "hydro_forecast_deb" --name "swift_deb" --version "0.1.18" --path .
```

