#!/bin/bash

aws eks update-kubeconfig --region eu-west-1 --name staging
wait
flux check --pre
wait
flux bootstrap github \
  --owner=solenersync \
  --repository=infrastructure \
  --components-extra=image-reflector-controller,image-automation-controller \
  --read-write-key=true \
  --path=clusters/staging
wait
flux reconcile kustomization flux-system --with-source
wait
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/aws/deploy.yaml
wait
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
wait
flux reconcile kustomization flux-system --with-source



