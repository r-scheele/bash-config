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

function intelcontext() {
    kubectl config use-context kubernetes-admin@kubernetes
}

function kindcontext() {
    kubectl config use-context kind-kind 
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
    k apply -k github.com/minio/operator/resources/\?ref\=v5.0.3
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
    kustomize build github.com/minio/operator/examples/kustomization/tenant-lite > tenant.yaml
    k apply -f tenant.yaml
    # k apply -k ~/operator/examples/kustomization/tenant-lite
}

function installubuntu() {
    k apply -f ~/bash-config/config-files/ubuntu.yaml -n $1
}

function squashrh() {
    git remote add upstream git@github.com:miniohq/release-hub.git
    git fetch upstream
    git rebase -i upstream/main
}

function squashpy() {
    git remote add upstream git@github.com:minio/minio-py.git
    git fetch upstream
    git rebase -i upstream/master
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

function clearMinIO() {
    rm -rf /Volumes/data1/*
    rm -rf /Volumes/data2/*
    rm -rf /Volumes/data3/*
    rm -rf /Volumes/data4/*
    rm -rf /Volumes/data1/.minio.sys/
    rm -rf /Volumes/data2/.minio.sys/
    rm -rf /Volumes/data3/.minio.sys/
    rm -rf /Volumes/data4/.minio.sys/
}


































##########################################
#
# Create PR
#
##########################################

function createPR() {

    REPO=$1
    BRANCH=$2

    rm -rf ~/$RESPO
    cd ~/
    gc $RESPO # git clone repo
    cd ~/$RESPO
    update $REPO
    git push
    git checkout -b $BRANCH
    subl .
}























######################################
#
# Clone Function
#
######################################

# Git Clone <Repo>
# gc enterprise
# gc operator
# gc minio-1
# gc rh
# gc console
function gc() {
    REPO=$1
    git clone git@github.com:cniackz/${REPO}.git
}
















































######################################
#
# Update function
#
######################################

function update() {

    # We receive only one parameter and from there we determine values
    REPO=$1

    if [ "$REPO" == "enterprise" ]
    then
        REPO=enterprise
        BRANCH=master
        ACCOUNT=miniohq
    fi

    if [ "$REPO" == "rh" ]
    then
        REPO=release-hub
        BRANCH=main
        ACCOUNT=miniohq
    fi

    if [ "$REPO" == "operator" ]
    then
        REPO=operator
        BRANCH=master
        ACCOUNT=minio
    fi

    if [ "$REPO" == "console" ]
    then
        REPO=console
        BRANCH=master
        ACCOUNT=minio
    fi

    if [ "$REPO" == "minio" ]
    then
        REPO=minio
        BRANCH=master
        ACCOUNT=minio
    fi

    git checkout $BRANCH
    git remote add upstream git@github.com:${ACCOUNT}/${REPO}.git
    git fetch upstream
    git rebase upstream/$BRANCH
    echo "push if ok"

}
















































