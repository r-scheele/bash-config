#!/bin/bash

######################################
#
# All shared Aliases
#
######################################
alias ext=exit
alias cls=clear
alias k="kubectl"
alias gadd="git add"
alias gst="git status"
alias gpush="git push"
alias gdiff="git diff"
alias wb1="git rev-parse --abbrev-ref HEAD"
alias gcconsole="git clone git@github.com:cniackz/console.git"
alias gcminio="cd ~; git clone git@github.com:cniackz/minio-1.git minio-1"

######################################
#
# Common functions:
#
######################################
function commit() {
    git add .
    git commit -m 'a'
    git push
}

function gcommit() {
    git commit -m "${1}"
}

function createcluster() {
    kind delete cluster
    kind create cluster --config ~/bash-config/kind-config.yaml
}

function installoperator() {
    # Make sure to use version or tag so that you don't have to compile against latest master code.
    k apply -k github.com/minio/operator/resources/\?ref\=v4.5.8
    k get service console -n minio-operator -o yaml > ~/service.yaml
    yq e -i '.spec.type="NodePort"' ~/service.yaml
    yq e -i '.spec.ports[0].nodePort = 30080' ~/service.yaml
    k apply -f ~/service.yaml
    k get deployment minio-operator -n minio-operator -o yaml > ~/operator.yaml
    yq -i -e '.spec.replicas |= 1' ~/operator.yaml
    k apply -f ~/operator.yaml
    k apply -f ~/bash-config/console-secret.yaml
    SA_TOKEN=$(k -n minio-operator  get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode)
    echo ""
    echo ""
    echo ""
    echo "########################################"
    echo "#"
    echo "# START: Operator Token"
    echo "#"
    echo "########################################"
    echo $SA_TOKEN
    echo "########################################"
    echo "#"
    echo "# END: Operator Token"
    echo "#"
    echo "########################################"
    echo ""
    echo ""
    echo ""
}

function installtenant() {
    k apply -k ~/operator/examples/kustomization/tenant-lite
}















