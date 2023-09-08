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
export POSTGRESQL_URL='postgres://postgres:testing123@localhost:5432/change-manager?sslmode=disable'
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
alias podman=docker

######################################
#
# Common functions:
#
######################################

function deleteCluster() {
    printMessage "kind delete cluster:"
    kind delete cluster
}

function commit() {
    git add .
    git commit -m 'a'
    git push
}

function gcommit() {
    git commit -m "${1}"
}





















































######################################
#
# This function call a function to
# create a k8s cluster in kind
#
######################################
function createcluster() {
    if [ "$1" == "nodeport" ]
    then
        createclusternp
    elif [ "$1" == "8nodes" ]
    then
        createcluster8nodes
    elif [ "$1" == "ingress" ]
    then
        createclusteringress
    elif [ "$1" == "oldversion" ]
    then
        createclusteroldversion
    elif [ "$1" == "myownip" ]
    then
        createclustermyownip
    elif [ "$1" == "base" ]
    then
        createclusterbase
    else
        createclusterhelp
    fi
}




















































######################################
#
# This function provides help on what
# function to call for creating a
# given k8s cluster:
#
######################################
function createclusterhelp() {
    echo "                           "
    echo "                           "
    echo "                           "
    echo "**SUPPORTED CLUSTERS ARE:  "
    echo "                           "    
    echo "                           "
    echo "                           "
    echo "###########################"
    echo "createcluster nodeport"
    echo "createcluster 8nodes"
    echo "createcluster ingress"
    echo "createcluster oldversion"
    echo "createcluster myownip"
    echo "createcluster base"
    echo "###########################"
    echo "                           "
    echo "                           "
    echo "                           "
}





















































function createclusternp() {
    kind delete cluster
    kind create cluster --config /Users/cniackz/bash-config/config-files/kind/kind-config-nodeport.yaml
}

function createcluster8nodes() {
    kind delete cluster
    kind create cluster --config /Users/cniackz/bash-config/config-files/kind/kind-config-8-nodes.yaml
}

function createclusteringress() {
    kind delete cluster
    kind create cluster --config /Users/cniackz/bash-config/config-files/kind/kind-config-ingress.yaml
}

function createclusteroldversion() {
    kind delete cluster
    kind create cluster --config /Users/cniackz/bash-config/config-files/kind/kind-config-1-18.yaml
}

function createclustermyownip() {
    kind delete cluster
    kind create cluster --config /Users/cniackz/bash-config/config-files/kind/kind-config-with-my-own-ip.yaml
}

function createclusterbase() {
    kind delete cluster
    kind create cluster --config /Users/cniackz/bash-config/config-files/kind/kind-config-base.yaml
}

function createclusterlegacy() {
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

    deleteCluster
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

function printMessage() {
    MESSAGE=$1
    echo " "
    echo "####################"
    echo "${MESSAGE}"
    echo "####################"
}

function crcStop() {
    printMessage "crc stop:"
    crc stop
}

function crcDelete() {
    printMessage "crc delete -f:"
    crc delete -f
}

function crcCleanUp() {
    printMessage "crc cleanup:"
    crc cleanup
}

function crcConfigSetCpus() {
    printMessage "crc config set cpus 8:"
    crc config set cpus 8
}

function crcConfigSetMemory() {
    printMessage "crc config set memory 16384:"
    crc config set memory 16384
}

function crcSetup() {
    printMessage "crc setup:"
    crc setup
}

function crcStart() {
    printMessage "crc start -c 8 -m 16384:"
    crc start -c 8 -m 16384
}

function crcRun() {
    echo "https://github.com/cniackz/public/wiki/crc"
    deleteCluster
    crcStop
    crcDelete
    crcCleanUp
    crcConfigSetCpus
    crcConfigSetMemory
    crcSetup
    crcStart
}

function upgradetenant() {

    METHOD=$1
    VERSION=$2
    NAMESPACE=$3

    echo "Current version:"
    helm list -n tenant-ns
    echo " "; echo " "; echo " ";

    echo "Upgrade:"
    helm upgrade --namespace $NAMESPACE tenant-ns $CONFIG_FILES/helm/Tenant/tenant-$VERSION
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
    NAMESPACE=$3

    if [ -z "$VERSION" ]
    then
        echo "ERROR: Version is needed"
        return 0
    fi

    if [ -z "$NAMESPACE" ]
    then
        echo "ERROR: Namespace is needed"
        return 0
    fi

    if [ "$METHOD" == "helm" ]
    then
        echo "Upgrading via Helm..."
        helm list -n $NAMESPACE
        helm upgrade \
             --namespace $NAMESPACE \
             minio-operator $CONFIG_FILES/helm/Operator/operator-$VERSION
        helm list -n $NAMESPACE
    fi

}

function install452() {
    createcluster
    cd /Users/cniackz/bash-config/config-files/kustomize/Operator
    # kustomize build github.com/minio/operator/resources/\?ref\=v4.5.2 > operator-4-5-2.yaml
    k apply -f operator-4-5-2.yaml
    cd /Users/cniackz/bash-config/config-files/kustomize/Tenant
    # kustomize build github.com/minio/operator/examples/kustomization/tenant-lite\?ref\=v4.5.2 > tenant-4-5-2.yaml
    # Then modified and removed logs and prometheus.
    k apply -f tenant-4-5-2.yaml
}





















































######################################
#
# This function install an Operator
# type based on user's input.
#
######################################
function installoperator() {
    if [ "$1" == "nodeport" ]
    then
        installoperatornp
    elif [ "$1" == "ingress" ]
    then
        installoperatoringress
    else
        installoperatorhelp
    fi
}



















































######################################
#
# This function offers help on how to
# actually install an Operator
#
######################################
function installoperatorhelp() {
    echo "                           "
    echo "                           "
    echo "                           "
    echo "** SUPPORTED METHODS:      "
    echo "                           "
    echo "                           "
    echo "                           "
    echo "###########################"
    echo "installoperator nodeport"
    echo "installoperator ingress"
    echo "###########################"
    echo "                           "
    echo "                           "
    echo "                           "
}





















































### installoperatornp is for nodeport
function installoperatornp() {
    k apply -f /Users/cniackz/bash-config/config-files/kustomize/Operator/operator-5-0-7.yaml
    k get service console -n minio-operator -o yaml > ~/service.yaml
    yq e -i '.spec.type="NodePort"' ~/service.yaml
    yq e -i '.spec.ports[0].nodePort = 30080' ~/service.yaml
    k apply -f ~/service.yaml
    k get deployment minio-operator -n minio-operator -o yaml > ~/operator.yaml
    yq -i -e '.spec.replicas |= 1' ~/operator.yaml
    k apply -f ~/operator.yaml
    k apply -f $CONFIG_FILES/others/console-secret.yaml -n minio-operator
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




















































######################################
#
# This function install Operator using
# NGINX Ingress for its exposure.
#
######################################
function installoperatoringress() {

    # Install NGINX
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

    # Wait for NGINX to be ready
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s

    # Add --enable-ssl-passthrough to enable passthrough in ingress-nginx deployment:
    k apply -f /Users/cniackz/bash-config/config-files/nginx

    # Install Operator:
    k apply -f /Users/cniackz/bash-config/config-files/kustomize/Operator/operator-5-0-7.yaml

}




















































### installoperator by default is using nginx
function installoperatorlegacy() {

    # Install NGINX
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

    # Wait for NGINX to be ready
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s

    # Add --enable-ssl-passthrough to enable passthrough in ingress-nginx deployment:
    k apply -f /Users/cniackz/bash-config/config-files/nginx

    # Example: installoperator kustomize 4.5.2 minio-operator

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
            # kustomize build github.com/minio/operator/resources/\?ref\=v5.0.7 > operator.yaml
            # Make sure to use version or tag so that you don't have to compile against latest master code.
            # k apply -k github.com/minio/operator/resources/\?ref\=v5.0.3
            k apply -f $CONFIG_FILES/kustomize/Operator/operator-5-0-7.yaml
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

# To install tenant for node port
function installtenantnp() {
    k apply -f /Users/cniackz/bash-config/config-files/kustomize/Tenant/tenant-5-0-7.yaml
}

# To install tenant for nginx
function installtenant() {

    METHOD=$1
    VERSION=$2
    NAMESPACE=$3

    if [ -z "$NAMESPACE" ]
    then
        NAMESPACE=tenant-ns
    fi

    if [ -z "$METHOD" ]
    then
        echo "If not method is provided, kustomize will be used"
        METHOD=kustomize
    fi

    if [ "$METHOD" == "kustomize" ]
    then
        # kustomize build github.com/minio/operator/examples/kustomization/tenant-lite > tenant.yaml
        k apply -f $CONFIG_FILES/kustomize/Tenant/tenant-5-0-3.yaml
        # k apply -k ~/operator/examples/kustomization/tenant-lite
    fi

    if [ "$METHOD" == "helm" ]
    then

        helm install \
          --namespace $NAMESPACE \
          --create-namespace $NAMESPACE \
          $CONFIG_FILES/helm/Tenant/tenant-$VERSION

    fi

    # Apply ingress:
    k apply -f /Users/cniackz/bash-config/config-files/ingress/ingress.yaml

}

function installubuntu() {
    k apply -f $CONFIG_FILES/others/ubuntu.yaml -n $1
}

function squashdocs() {
    git remote add upstream git@github.com:minio/docs.git
    git fetch upstream
    git rebase -i upstream/main
}

function squashrh() {
    git remote add upstream git@github.com:miniohq/release-hub.git
    git fetch upstream
    git rebase -i upstream/main
}

function squashrm() {
    git remote add upstream git@github.com:miniohq/release-manager.git
    git fetch upstream
    git rebase -i upstream/master
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

function upgradeMinIO() {
    echo "Removing old MinIO binary..."
    sudo rm -rf /usr/local/bin/minio
    echo "Download new MinIO binary..."
    curl --progress-bar -O https://dl.min.io/server/minio/release/darwin-arm64/minio
    chmod +x minio
    sudo mv minio /usr/local/bin/minio
}

function upgradeMC() {
    echo "Removing old mc binary..."
    sudo rm -rf /usr/local/bin/mc
    echo "Download new mc binary..."
    curl --progress-bar -O https://dl.min.io/client/mc/release/darwin-amd64/mc
    chmod +x mc
    sudo mv mc /usr/local/bin/mc
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

    if [ "$1" == "help" ]
    then
        echo "                                        "
        echo "                                        "
        echo "                                        "
        echo "########################################"
        echo "# Examples you can use:                 "
        echo "########################################"
        echo "                                        "
        echo "                                        "
        echo "createPR rm name-of-the-pr              "
        echo "          |                             "
        echo "          |___ release-manager          "
        echo "                                        "
        echo "                                        "
        echo "                                        "
        echo "createPR enterprise name-of-the-pr      "
        echo "          |                             "
        echo "          |___ enterprise               "
        echo "                                        "
        echo "                                        "
        echo "                                        "
        echo "createPR dp name-of-the-pr              "
        echo "          |                             "
        echo "          |___ directpv                 "
        echo "                                        "
        echo "                                        "
        echo "                                        "
        echo "createPR docs name-of-the-pr            "
        echo "          |                             "
        echo "          |___ docs                     "
        echo "                                        "
        echo "                                        "
        echo "                                        "
        echo "createPR minio-1 name-of-the-pr         "
        echo "          |                             "
        echo "          |___ minio                    "
        echo "                                        "
        echo "                                        "
        echo "                                        "
        return 0
    fi

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

    if [ "$REPO" == "rm" ]
    then
        REPO=release-manager
    fi

    if [ "$REPO" == "rh" ]
    then
        REPO=release-hub
    fi

    git clone git@github.com:cniackz/${REPO}.git
}





































######################################
#
# Helper functions
#
######################################

function convert_short_name_to_proper_name() {

    echo "Check that REPO argument is provided if calling convert_short_name_to_proper_name()"
    if [ -z "$REPO" ]
    then
        echo "ERROR: REPO argument has to be provided when calling convert_short_name_to_proper_name()"
        exit 1
    fi

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

    if [ "$REPO" == "docs" ]
    then
        REPO=docs
        echo "convert_short_name_to_proper_name(): REPO: ${REPO}"
        BRANCH=main
        echo "convert_short_name_to_proper_name(): BRANCH: ${BRANCH}"
        ACCOUNT=minio
        echo "convert_short_name_to_proper_name(): ACCOUNT: ${ACCOUNT}"
    fi

    if [ "$REPO" == "operator" ]
    then
        REPO=operator
        BRANCH=master
        ACCOUNT=minio
    fi

    if [ "$REPO" == "directpv" ] || [ "$REPO" == "dp" ]
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

    if [ "$REPO" == "minio-1" ]
    then
        REPO=minio-1
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

    echo "###########################"
    echo "update():"
    echo "###########################"
    echo " "
    echo "We receive only one parameter and from there we determine values"
    REPO=$1
    echo "REPO: ${REPO}"
    echo "convert_short_name_to_proper_name"
    convert_short_name_to_proper_name $REPO # REPO arg is required in this function

    echo "Check REPO is not empty after calling convert_short_name_to_proper_name"
    if [ -z "$REPO" ]
    then
        echo " "
        echo "##################################"
        echo "ERROR: REPO is needed and is empty"
        echo "##################################"
        echo " "
        exit 1
    fi

    echo "Check BRANCH is not empty after calling convert_short_name_to_proper_name"
    if [ -z "$BRANCH" ]
    then
        echo " "
        echo "##################################"
        echo "ERROR: BRANCH is needed and is empty"
        echo "##################################"
        echo " "
        exit 1
    fi 

    echo "git checkout ${BRANCH}"
    git checkout $BRANCH


    if [ "$REPO" == "minio" || "$REPO" == "minio-1" ]
    then
        echo "REPO is minio, meaning is a PR for minio golden repo"
        echo "Hence proper name is required not minio-1 but minio just."
        REPO=minio
    fi


    echo "git remote add upstream git@github.com:${ACCOUNT}/${REPO}.git"
    git remote add upstream git@github.com:${ACCOUNT}/${REPO}.git


    echo "git fetch upstream"
    git fetch upstream
    echo "git rebase upstream/$BRANCH"
    git rebase upstream/$BRANCH
    echo "check if all ok, git push is next:"
    git push
    echo " "
    echo " "

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
    kubectl config use-context directpv-admin@directpv
}























######################################
#
# Other functions
#
######################################
function ghpr() {
    gh repo set-default
    gh pr checkout $1
}

function getminio() {
    sudo rm -rf /usr/local/bin/minio
    curl --progress-bar -O https://dl.min.io/server/minio/release/darwin-arm64/minio
    chmod +x minio
    sudo mv minio /usr/local/bin/minio
}






















