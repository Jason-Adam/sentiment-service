#!/usr/bin/env sh

# get application name from project directory
APP_NAME="${PWD##*/}"
GCP_PROJECT="$(gcloud config get-value project)"
IMG_TAG="$(git rev-parse --short HEAD)"
IMG=gcr.io/"$GCP_PROJECT"/"$APP_NAME"

echo "
##########################################
Starting App Deployment
##########################################
"

echo "Current Configuration"
echo "---------------------"
echo "APP_NAME: $APP_NAME"
echo "GCP_PROJECT: $GCP_PROJECT"
echo "IMG: $IMG"
echo "IMG_TAG: $IMG_TAG"

echo "
##########################################
Building and Pushing Docker Image
##########################################
"
docker build -t "$IMG":"$IMG_TAG" -t "$IMG":latest . && \
    docker push "$IMG":"$IMG_TAG" && \
    docker push "$IMG":latest

echo "
##########################################
Deploying Secrets
##########################################
"
if [ "$(cat dev.env)" ]
then
	kubectl create secret generic "$APP_NAME" \
		--from-env-file=dev.env \
		--dry-run=client -o yaml | kubectl apply -f -
else
	echo "no secrets were provided"
	echo "if your app requires secrets, please ensure you have a dev.env file in the root of the app"
fi

echo "
##########################################
Deploying to Kubernetes
##########################################
"
# Yaml substitution function
yaml_substitute() {
	sed "s/{ { APP_NAME } }/$APP_NAME/g" $1 | sed "s/{ { IMG } }/gcr.io\/$GCP_PROJECT\/$APP_NAME:$IMG_TAG/g"
}

for yaml in kubernetes/*.yaml; do
	if [ "$(echo $yaml | grep 'deployment')" ]
	then
		echo "Creating / Updating deployment for $APP_NAME"
		yaml_substitute "$yaml" | kubectl apply -f - && kubectl rollout restart deployment $APP_NAME;
	elif [ "$(echo $yaml | grep 'cronjob')" ]
	then
		echo "Creating / Updating cronjob for $APP_NAME"
		yaml_substitute "$yaml" | kubectl apply -f -;
	elif [ "$(echo $yaml | grep 'job')" ]
	then
		echo "Creating / Updating job for $APP_NAME"
		yaml_substitute "$yaml" | kubectl apply -f -;
	elif [ "$(echo $yaml | grep 'service')" ]
	then
		echo "Creating / Updating service for $APP_NAME"
		yaml_substitute "$yaml" | kubectl apply -f -;
	else
		echo "Not sure what you're trying to deploy"
		echo "Acceptable kubernetes yaml file names are deployment.yaml, cronjob.yaml, job.yaml"
	fi
done
