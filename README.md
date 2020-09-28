# infrastructure

Infrastructure configuration files for both research and engineering projects.

## `infrastructure/terraform`

Terraform configuration files for personal software development
infrastructure.

Currently, the configuration defines the Google Kubernetes Engine cluster
(and respective Node Pools) used for hosting development status software
projects and automated machine learning model training jobs.

## resources

- [GCP REST API](https://cloud.google.com/compute/docs/reference/rest/v1/)
  - The REST API is what the `gcloud` CLI tool uses to interface with GCP.
  - The REST API is also used by Terraform to provision resources.


## infrastructure overview

### kubernetes cluster
- projects
  - **redirect2**
    - `redirect2-certs`. certificates needed for HTTPS.
    - `redirect2-secrets`. contains credentials for making shortcuts.
  - **analytics proxy**
    - `proxy{1,2}-certs`. certificates needed for HTTPS.
  - **gitlab**
    - `static-ip-key`. used to grant permission to automatically assign an
      external IP to the GitLab preemptible instance.
  - **thedevelopingdev**
    - `thedevelopingdev-certs`. certificates needed for HTTPS.

### managed instance group
- projects
  - **gitlab**
    - gitlab runs in a managed instance group of size 1 of preemptible
      instances.



