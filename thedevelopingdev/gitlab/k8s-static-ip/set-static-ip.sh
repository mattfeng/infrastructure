#!/bin/sh

INSTANCE_NAME=`gcloud compute instances list --limit=1 --filter=name:$PREFIX --format="value(selfLink.basename())"`

gcloud compute instances add-access-config --zone $ZONE $INSTANCE_NAME --access-config-name "External NAT" --address $ADDRESS
