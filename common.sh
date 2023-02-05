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
alias gdiff="git diff"
alias wb1="git rev-parse --abbrev-ref HEAD"
alias gcconsole="git clone git@github.com:cniackz/console.git"
alias gcminio="cd ~; git clone git@github.com:cniackz/minio-1.git minio-1"

######################################
#
# Common functions:
#
######################################
function createcluster() {
        kind delete cluster
        kind create cluster --config ~/bash-config/kind-config.yaml
}
