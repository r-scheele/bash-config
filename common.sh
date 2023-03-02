#!/bin/bash

######################################
#
# Environment Variables
#
######################################
export OPERATOR_DEV_TEST="ON"
export PATH="/opt/homebrew/opt/node@18/bin:$PATH"

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
alias gpull="git pull"
alias wb1="git rev-parse --abbrev-ref HEAD"
alias sshpg="ssh cesar@65.49.37.17 -p 4492"
alias sshintel="ssh minio@64.71.151.78 -p 4492"
alias gcconsole="git clone git@github.com:cniackz/console.git"
alias gcenterprise="git clone git@github.com:cniackz/enterprise.git"
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
    kind create cluster --config ~/bash-config/config-files/kind-config.yaml
}

function JWTOperator() {
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: console-sa-secret
  namespace: minio-operator
  annotations:
    kubernetes.io/service-account.name: console-sa
type: kubernetes.io/service-account-token
EOF
SA_TOKEN=$(kubectl -n minio-operator  get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode)
echo $SA_TOKEN
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
    k apply -f ~/bash-config/config-files/console-secret.yaml
    SA_TOKEN=$(k -n minio-operator  get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode)
    echo ""
    echo ""
    echo ""
    echo "########################################"
    echo "#"
    echo "# START: Operator Token"
    echo "#"
    echo "########################################"
    echo ""
    echo ""
    echo ""
    echo $SA_TOKEN
    echo ""
    echo ""
    echo ""
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
    k apply -f ~/minio/ubuntu.yaml -n tenant-lite
}

function installubuntu() {
    k apply -f ~/bash-config/config-files/ubuntu.yaml -n $1
}

function updateoperator() {
        git checkout master
        git remote add upstream git@github.com:minio/operator.git
        git fetch upstream
        git rebase upstream/master
        echo "push if ok"
}

function updateconsole() {
        git checkout master
        git remote add upstream git@github.com:minio/console.git
        git fetch upstream
        git rebase upstream/master
        echo "push if ok"
}

function updateminio() {
        git checkout master
        git remote add upstream git@github.com:minio/minio.git
        git fetch upstream
        git rebase upstream/master
        echo "push if ok"
}

function updateenterprise() {
        git checkout master
        git remote add upstream git@github.com:miniohq/enterprise.git
        git fetch upstream
        git rebase upstream/master
        echo "push if ok"
}

function squashoperator() {
        git remote add upstream git@github.com:minio/operator.git
        git fetch upstream
        git rebase -i upstream/master
}

function squashconsole() {
        git remote add upstream git@github.com:minio/console.git
        git fetch upstream
        git rebase -i upstream/master
}

function squashenterprise() {
        git remote add upstream git@github.com:miniohq/enterprise.git
        git fetch upstream
        git rebase -i upstream/master
}

function gcoperator() {
	git clone git@github.com:cniackz/operator.git
}















