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


## Notes

Due to the complexities of kubernetes, 
there is no ingress or hard node binding here. It will be up to you to expose your server to the world. 
