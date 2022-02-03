# Helm Chart for Kubernetes

This is to be able to deploy into a kubernetes cluster. 

## Required

- helm v3+
- kubectl
- Kuberntes Cluster
- kubeconfig

## Usage

### Testing

```shell
helm template \
  --dry-run \
  --debug .
```

### Installation

```shell
helm upgrade \
  --install ark-manager \
  ./helm
```
