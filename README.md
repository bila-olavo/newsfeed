# Newsfeed

This example contains a simple solution to deploy apps using Docker, Kubernetes, Terraform on Google Cloud Platform for a non-production environment, however, can be an initial step for production.

## Prerequisites

* [Docker](https://docs.docker.com/install/)
* [Gcloud command-line interface](https://cloud.google.com/sdk/gcloud/)
* [Kubernetes Control (kubectl)](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Terraform](https://www.terraform.io/downloads.html)

# Apps Info

This project contains three services:

* `quotes` which serves a random quote from `quotes/resources/quotes.json`
* `newsfeed` which aggregates several RSS feeds together
* `front-end` which calls the two previous services and displays the results.

## Prerequisites to run local

* [Docker](https://docs.docker.com/install/)
* [Leiningen](http://leiningen.org/) (can be installed using `brew install leiningen`)

## Running tests

You can run the tests of all apps by using `make test`

## Building

First you need to ensure that the common libraries are installed: run `make libs` to install them to your local `~/.m2` repository. This will allow you to build the JARs.

To build all the JARs and generate the static tarball, run the `make clean all` command from this directory. The JARs and tarball will appear in the `build/` directory.

# Running as Docker

## Static assets

### Build Docker Image

`docker build --tag frontend-static:1.0  --file front-end/public/Dockerfile .`

### Running Container

`docker run --rm --name frontend-static --publish 8000:8000 frontend-static:1.0`

Note: This will serve the assets on port 8000.

---

All the apps take environment variables to configure them and expose the URL `/ping` which will just return a 200 response that you can use with e.g. a load balancer to check if the app is running.

*Environment variables*:

* `APP_PORT`: The port on which to run the app
* `STATIC_URL`: The URL on which to find the static assets
* `QUOTE_SERVICE_URL`: The URL on which to find the quote service
* `NEWSFEED_SERVICE_URL`: The URL on which to find the newsfeed service
* `NEWSFEED_SERVICE_TOKEN`: The authentication token that allows the app to talk to the newsfeed service. This should be treated as an application secret. The value should be: `T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX`

## Quote Service

### Build Docker Image

`docker build --tag quotes:1.0 --file quotes/Dockerfile .`

### Running Container

`docker run --rm --name quotes --hostname quotes --env APP_PORT=8080 quotes:1.0`

Note: This will serve service on port 8080.

## Newsfeed

### Build Docker Image

`docker build --tag newsfeed:1.0 --file newsfeed/Dockerfile .`

### Running Container

`docker run --rm --name newsfeed --hostname newsfeed --env APP_PORT=8081 newsfeed:1.0 `

Note: This will serve service on port 8081.

## Front-end 

### Build Docker Image

`docker build --tag frontend:1.0 --file front-end/Dockerfile .`

### Running Container

`docker run --rm --name frontend --env APP_PORT=8082 --env STATIC_URL=http://0.0.0.0:8000 --env QUOTE_SERVICE_URL=http://quotes:8080 --env NEWSFEED_SERVICE_URL=http://newsfeed:8081 --env  NEWSFEED_SERVICE_TOKEN="T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX" --link quotes:quotes --link  newsfeed:newsfeed --publish 8082:8082 frontend:1.0`

Note: This will serve service on port 8082.


```
Local URL: http://localhost:8082

```

# Running on GKE (Google Kubernetes Engine)


## Step 1:

`cd` to `iac/` open the file `variables.tf` replace all variables accordingly.

## Step 2:

`cd` to `iac/` trigger the iac (infra as code) `terraform init` , `plan` and `apply` for creating the resources on GCP: 

```
terraform init
terraform plan
terraform apply
```
## Step 3:

Config `kubectl` and `Gcloud-sdk` make sure that you are able to connect to k8s cluster and GCP:

```
kubectl cluster-info
```
## Step 4:

Create namespace `staging` for using in this example

```
kubectl create namespace staging
```

## Step 5:
Tagging and Pushing the docker images from your local machine to the registry

### Static Assets:

```
docker tag frontend-static:1.0 gcr.io/YOUR_PROJECT_ID/frontend-static:1.0
gcloud docker -- push gcr.io/YOUR_PROJECT_ID/frontend-static:1.0
```

### Quote Service:

```
docker tag quotes:1.0 gcr.io/YOUR_PROJECT_ID/quotes:1.0
gcloud docker -- push gcr.io/YOUR_PROJECT_ID/quotes:1.0
```

### Newsfeed:

```
docker tag newsfeed:1.0 gcr.io/YOUR_PROJECT_ID/newsfeed:1.0
gcloud docker -- push gcr.io/YOUR_PROJECT_ID/newsfeed:1.0
```
### Front-end:

```
docker tag frontend:1.0 gcr.io/YOUR_PROJECT_ID/frontend:1.0
gcloud docker -- push gcr.io/YOUR_PROJECT_ID/frontend:1.0
```

## Step 6:

Preparing the k8s objects for applying

Go to every `k8s` folder edit the yaml file `deployment.yaml` replace the value of the field `image` to your Docker image e.g: ` gcr.io/YOUR_PROJECT_ID/APP_NAME:1.0`

## Step 7:

Applying the objects to k8s cluster

### Static Assets:

`cd` to `front-end/public/k8s`

```
kubectl create -f deployment.yaml
kubectl create -f service.yaml
kubectl create -f ingress.yaml
```

### Quote Service:

`cd` to `quotes/k8s`

```
kubectl create -f deployment.yaml
kubectl create -f service.yaml
```

### Newsfeed:

`cd` to `newsfeed/k8s`

```
kubectl create -f deployment.yaml
kubectl create -f service.yaml
```

### Front-end:

`cd` to `front-end/k8s` edit the yaml file `deployment.yaml` replace the environment variable `STATIC_URL` with URL of Static Assets.

```
kubectl create -f secrets.yaml
kubectl create -f deployment.yaml
kubectl create -f service.yaml
kubectl create -f ingress.yaml
```

Note: you can get static assets url: `"kubectl get ingress frontend-static-ingress -n staging"` column `"ADDRESS"`, check via CURL: `http://ADDRESS/css/bootstrap.min.css` 

## Step final:

Execute `"kubectl get frontend-ingress -n staging"` copy the column `"ADDRESS"` and paste it on your browser `"http://ADDRESS"`, hopefully you are able to see the `newsfeed` running. 