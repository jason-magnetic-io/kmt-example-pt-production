#!/usr/bin/env bash

set -e

if [ -e updated ]
then
	for brand in $(ls brands)
	do
		for config in $(ls brands/$brand/*.yaml)
		do
			context=$(basename $config | cut -d'.' -f1)
			environment=$(echo $context | cut -d'-' -f2)
			echo "Updating $brand $environment"
			updated_flag=true
			python bin/copy_services.py \
				--config $config \
				--src-path kmt-example-service-catalog \
				--dst-path brands/$brand/production/services || updated_flag=false
			if [ "$updated_flag" = true ]
			then
				kubectl config use-context $context
				kustomize build brands/$brand/$environment | kubectl apply -f -
			fi
		done
	done
	rm updated
else
	echo "Nothing to update"
fi