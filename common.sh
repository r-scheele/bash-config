#!/bin/bash

######################################
#
# Krew
# https://krew.sigs.k8s.io/docs/user-guide/setup/install/
#
######################################
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

######################################
#
# Environment Variables
#
######################################
export OPERATOR_DEV_TEST="ON"
export PATH="/opt/homebrew/opt/node@18/bin:$PATH"
export PATH="${PATH}:${HOME}/.krew/bin"
export PATH=/Library/PostgreSQL/15/bin:$PATH # To have psql
export POSTGRESQL_URL='postgres://postgres:testing123@localhost:5432/change_manager?sslmode=disable'
export CONFIG_FILES=/Users/cniackz/bash-config/config-files

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
    KIND_FOLDER=~/bash-config/config-files/kind
    CONFIG_FILE=$KIND_FOLDER/kind-config.yaml # Default 4 nodes
    if [ "$NODES" == "8" ]
    then
        # It selected, it could be up to 8 nodes for testing
        CONFIG_FILE=$KIND_FOLDER/kind-config-8-nodes.yaml
    fi
    if [ "$VERSION" == "118" ]
    then
        CONFIG_FILE=$KIND_FOLDER/kind-config-1-18.yaml
    fi
    if [ "$1" == "ingress" ]
    then
        CONFIG_FILE=$KIND_FOLDER/kind-config-ingress.yaml
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

function upgradetenant() {

    echo "Current version:"
    helm list -n tenant-ns
    echo " "; echo " "; echo " ";

    echo "Upgrade:"
    helm upgrade --namespace tenant-ns tenant-ns /Users/cniackz/bash-config/config-files/tenant-5.0.3
    echo " "; echo " "; echo " ";

    echo "New version:"
    helm list -n tenant-ns
    echo " "; echo " "; echo " ";

}

function upgradeoperator() {

    METHOD=$1
    echo "METHOD: ${METHOD}"
    VERSION=$2
    echo "VERSION: ${VERSION}"

    if [ "$METHOD" == "helm" ]
    then
        echo "Upgrading via Helm..."
        if [ "$VERSION" == "5.0.3" ]
        then
            echo "Upgrading to version 5.0.3..."
            helm upgrade \
                 --namespace minio-operator \
                 minio-operator /Users/cniackz/bash-config/config-files/operator-5.0.3.tgz
        fi
        if [ "$VERSION" == "4.5.8" ]
        then
            echo "Upgrading to version 4.5.8..."
            helm upgrade \
                 --namespace minio-operator \
                 minio-operator /Users/cniackz/bash-config/config-files/operator-4.5.8.tgz
        fi
    fi

}

function installoperator() {

    METHOD=$1
    VERSION=$2
    NAMESPACE=$3

    if [ "$1" == "help" ]
    then
        echo "installoperator(): Examples:"
        echo "installoperator(): installoperator METHOD VERSION NAMESPACE"
        echo "installoperator(): METHOD:  Kustomize or Helm"
        echo "installoperator(): VERSION: 4.5.8, 5.0.3, etc."
        echo "installoperator(): NAMESPACE: minio-operator, tenant-lite, etc."
        echo "installoperator():"
        echo "installoperator(): Below install Operator version 5.0.4 in tenant-lite namespace:"
        echo "installoperator(): installoperator helm 5.0.4 tenant-lite"
        return
    fi

    DEFAULT_METHOD=kustomize
    echo "installoperator(): If no method is provided, then $DEFAULT_METHOD is default method."
    if [ -z "$METHOD" ]
    then
        METHOD=$DEFAULT_METHOD
    fi

    DEFAULT_NAMESPACE=minio-operator
    echo "installoperator(): If no namespace is provided, then $DEFAULT_NAMESPACE is default namespace."
    if [ -z "$NAMESPACE" ]
    then
        NAMESPACE=$DEFAULT_NAMESPACE
    fi

    if [ "$METHOD" == "kustomize" ]
    then
        if [ -z "$VERSION" ]
        then
            # kustomize build github.com/minio/operator/resources/\?ref\=v5.0.3 > operator.yaml
            # Make sure to use version or tag so that you don't have to compile against latest master code.
            # k apply -k github.com/minio/operator/resources/\?ref\=v5.0.3
            k apply -f $CONFIG_FILES/kustomize/Operator/operator-5-0-3.yaml
        else
            k apply -k github.com/minio/operator/resources/\?ref\=v"$VERSION"
        fi
    fi

    if [ "$METHOD" == "helm" ]
    then

        helm install \
             --namespace $NAMESPACE \
             --create-namespace $NAMESPACE \
             $CONFIG_FILES/helm/Operator/operator-"$VERSION"

    fi

    k get service console -n $NAMESPACE -o yaml > ~/service.yaml
    yq e -i '.spec.type="NodePort"' ~/service.yaml
    yq e -i '.spec.ports[0].nodePort = 30080' ~/service.yaml
    k apply -f ~/service.yaml
    k get deployment minio-operator -n $NAMESPACE -o yaml > ~/operator.yaml
    yq -i -e '.spec.replicas |= 1' ~/operator.yaml
    k apply -f ~/operator.yaml
    k apply -f $CONFIG_FILES/others/console-secret.yaml -n $NAMESPACE
    SA_TOKEN=$(k -n $NAMESPACE  get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode)
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
    NAMESPACE=$3

    if [ -z "$NAMESPACE" ]
    then
        NAMESPACE=tenant-ns
    fi

    if [ "$METHOD" == "kustomize" ]
    then
        # kustomize build github.com/minio/operator/examples/kustomization/tenant-lite > tenant.yaml
        k apply -f $CONFIG_FILES/tenant-5-0-3.yaml
        # k apply -k ~/operator/examples/kustomization/tenant-lite
    fi

    if [ "$METHOD" == "helm" ]
    then

        helm install \
          --namespace $NAMESPACE \
          --create-namespace $NAMESPACE \
          $CONFIG_FILES/helm/Tenant/tenant-$VERSION

    fi

}

function installubuntu() {
    k apply -f $CONFIG_FILES/others/ubuntu.yaml -n $1
}

function squashrh() {
    git remote add upstream git@github.com:miniohq/release-hub.git
    git fetch upstream
    git rebase -i upstream/main
}

function squashdp() {
    git remote add upstream git@github.com:minio/directpv.git
    git fetch upstream
    git rebase -i upstream/master
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
REPO=none
BRANCH=none
ACCOUNT=none
function createPR() {

    REPO=$1
    NEW_BRANCH_FOR_PR=$2 # This is different than original branch BRANCH wich normally is master or main

    # It gets the values for:
    #     REPO=none
    #     BRANCH=none
    #     ACCOUNT=none
    convert_short_name_to_proper_name $REPO

    echo "If repo is not set, we can't continue..."
    if [ -z "$REPO" ]
    then
        echo "createPR(): REPO is empty, stop here"
        exit 1
    fi

    echo "Provided parameters are:"
    echo "REPO: ${REPO}"
    echo "NEW_BRANCH_FOR_PR: ${NEW_BRANCH_FOR_PR}"

    echo "1. Removing old Repository"
    echo "rm -rf ~/$REPO"
    rm -rf ~/$REPO

    echo "Changing to home directory"
    echo "cd ~/"
    cd ~/

    echo "Cloning Repository at Home:"
    echo "gc $REPO"
    gc $REPO # git clone repo

    echo "Changing to cloned repo directory:"
    echo "cd ~/$REPO"
    cd ~/$REPO

    echo "Updating the cloned repo:"
    echo "update $REPO"
    update $REPO

    echo "Pushing changes to update"
    echo "git push"
    git push

    echo "Creating new branch: ${NEW_BRANCH_FOR_PR}"
    echo "git checkout -b $NEW_BRANCH_FOR_PR"
    git checkout -b $NEW_BRANCH_FOR_PR

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
# Helper functions
#
######################################

function convert_short_name_to_proper_name() {

    echo "convert_short_name_to_proper_name(): We receive only one parameter and from there we determine values"
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
        BRANCH=main
        ACCOUNT=minio
    fi

    if [ "$REPO" == "operator" ]
    then
        REPO=operator
        BRANCH=master
        ACCOUNT=minio
    fi

    if [ "$REPO" == "directpv" ]
    then
        REPO=directpv
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

    if [ "$REPO" == "rm" ]
    then
        echo "convert_short_name_to_proper_name(): REPO is rm then REPO will be release-manager"
        REPO=release-manager
        BRANCH=master
        ACCOUNT=miniohq
    fi

}








######################################
#
# Update function
#
######################################

function update() {

    # We receive only one parameter and from there we determine values
    REPO=$1
    convert_short_name_to_proper_name

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































