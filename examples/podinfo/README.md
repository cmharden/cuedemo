# Deploying a Kubernetes Application

This example demonstrates how we can configure a simple application on Kubernetes using CUE.

The `resources` expression holds our kubernetes resources. The `out` expression contains a `yaml` encoded stream of Kubernetes manifests.

List the Kubernetes resources to be created with the following command:
```bash
cue ls
```

Generate the Kubernetes manifests using the following command:
```bash
cue oyaml

We can use the "-t hpa" flag to enable the hpa:
```bash
cue -t hpa ls
```
