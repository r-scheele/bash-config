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

function gcommit() {
    git commit -m "${1}"
}

function createcluster() {
    NODES=$1
    VERSION=$NODES
    CONFIG_FILE=~/bash-config/config-files/kind-config.yaml # Default 4 nodes
    if [ "$NODES" == "8" ]
    then
        # It selected, it could be up to 8 nodes for testing
        CONFIG_FILE=~/bash-config/config-files/kind-config-8-nodes.yaml
    fi
    if [ "$VERSION" == "118" ]
    then
        CONFIG_FILE=~/bash-config/config-files/kind-config-1-18.yaml
    fi
    if [ "$1" == "ingress" ]
    then
        CONFIG_FILE=~/bash-config/config-files/kind-config-ingress.yaml
    fi

    kind delete cluster
    kind create cluster --config $CONFIG_FILE

    # To put pool-0 in these nodes:
    kubectl label nodes kind-worker  pool=zero
    kubectl label nodes kind-worker2 pool=zero
    kubectl label nodes kind-worker3 pool=zero
    kubectl label nodes kind-worker4 pool=zero

    if [ "$NODES" == "8" ]
    then
        # To put pool one in these nodes:
        kubectl label nodes kind-worker5 pool=one
        kubectl label nodes kind-worker6 pool=one
        kubectl label nodes kind-worker7 pool=one
        kubectl label nodes kind-worker8 pool=one
    fi

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
echo ""
echo ""
echo ""
echo $SA_TOKEN
echo ""
echo ""
echo ""
}

function upgradeoperator() {

    METHOD=$1
    VERION=$2

    if [ "$METHOD" == "helm" ]
    then
        helm upgrade \
             --namespace minio-operator \
             minio-operator /Users/cniackz/bash-config/config-files/operator-5.0.3.tgz
    fi

}

function installoperator() {

    METHOD=$1
    VERSION=$2

    if [ "$METHOD" == "kustomize" ]
    then
        if [ "$VERSION" == "4.5.8" ]
        then
            k apply -k github.com/minio/operator/resources/\?ref\=v4.5.8
        else
            # kustomize build github.com/minio/operator/resources/\?ref\=v5.0.3 > operator.yaml
            # Make sure to use version or tag so that you don't have to compile against latest master code.
            # k apply -k github.com/minio/operator/resources/\?ref\=v5.0.3
            k apply -f /Users/cniackz/bash-config/config-files/operator-5-0-3.yaml
        fi
    fi

    if [ "$METHOD" == "helm" ]
    then
        helm install \
             --namespace minio-operator \
             --create-namespace \
             minio-operator /Users/cniackz/bash-config/config-files/operator-4.5.8.tgz
    fi

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

    METHOD=$1
    VERSION=$2

    if [ "$METHOD" == "kustomize" ]
    then
        # kustomize build github.com/minio/operator/examples/kustomization/tenant-lite > tenant.yaml
        k apply -f /Users/cniackz/bash-config/config-files/tenant-5-0-3.yaml
        # k apply -k ~/operator/examples/kustomization/tenant-lite
    fi

    if [ "$METHOD" == "helm" ]
    then
        helm install \
          --namespace tenant-ns \
          --create-namespace \
          tenant-ns /Users/cniackz/bash-config/config-files/tenant-4.5.8.tgz
    fi

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

    REPO_TO_CREATE_PR=$1
    BRANCH_OF_THE_PR=$2

    echo "Provided parameters are:"
    echo "REPO_TO_CREATE_PR: ${REPO_TO_CREATE_PR}"
    echo "BRANCH_OF_THE_PR: ${BRANCH_OF_THE_PR}"

    echo "1. Removing old Repository"
    echo "rm -rf ~/$REPO_TO_CREATE_PR"
    rm -rf ~/$REPO_TO_CREATE_PR

    echo "Changing to home directory"
    echo "cd ~/"
    cd ~/

    echo "Cloning Repository at Home:"
    echo "gc $REPO_TO_CREATE_PR"
    gc $REPO_TO_CREATE_PR # git clone repo

    echo "Changing to cloned repo directory:"
    echo "cd ~/$REPO_TO_CREATE_PR"
    cd ~/$REPO_TO_CREATE_PR

    echo "Updating the cloned repo:"
    echo "update $REPO_TO_CREATE_PR"
    update $REPO_TO_CREATE_PR

    echo "Pushing changes to update"
    echo "git push"
    git push

    echo "Creating new branch: ${BRANCH_OF_THE_PR}"
    echo "git checkout -b $BRANCH_OF_THE_PR"
    git checkout -b $BRANCH_OF_THE_PR

    echo "To Start working Open sublime here:"
    echo "subl ."
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

    if [ "$REPO" == "dcos" ]
    then
        REPO=docs
        BRANCH=master
        ACCOUNT=minio
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

















































######################################
#
# The k8s contexts
#
######################################

function intelcontext() {
    kubectl config use-context kubernetes-admin@kubernetes
}

function kindcontext() {
    kubectl config use-context kind-kind
}

function dpcontext() {
    kubectl config use-context
}































