#!/bin/bash

######################################
#
# To import common things:
#
######################################

source ~/bash-config/common.sh

######################################
#
# Particular things for Ubuntu
#
######################################

# Alias for Ubuntu only:
alias movemouse="keep-presence --seconds 30"
alias minioserver="CI=on MINIO_ROOT_USER=minio MINIO_ROOT_PASSWORD=minio123 minio server /home/ccelis/data{1...4} --address :9000 --console-address :9001"

# Other particular things for ubuntu:
export PATH=$PATH:/usr/local/go/bin
export set GOROOT=/usr/local/go
export set GOPATH=/home/ccelis/go

function JWTOperato(){

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
function gcem(){
	rm -rf ~/enterprise
	git clone https://cniackz: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@github.com/miniohq/enterprise.git ~/enterprise
	cd ~/enterprise
}
function compile(){
	cd $GOPATH/src/github.com/minio/directpv
	go build -v ./...
	./build.sh
	docker build -t quay.io/cniackz4/directpv:thunov172211am .
	./kubectl-directpv --kubeconfig /home/ccelis/.kube/config install \
--image directpv:thunov172211am --org cniackz4 --registry quay.io
	./kubectl-directpv --kubeconfig /home/ccelis/.kube/config $1
}
function installoperator() {
        # Make sure to use version or tag so that you don't have to compile against latest master code.
        kubectl apply -k github.com/minio/operator/resources/\?ref\=v4.5.8
        k get service console -n minio-operator -o yaml > ~/service.yaml
        yq e -i '.spec.type="NodePort"' ~/service.yaml
        yq e -i '.spec.ports[0].nodePort = 30080' ~/service.yaml
        k apply -f ~/service.yaml

k get deployment minio-operator -n minio-operator -o yaml > ~/operator.yaml
yq -i -e '.spec.replicas |= 1' ~/operator.yaml
k apply -f ~/operator.yaml

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

function gcenterprise(){
	git clone git@github.com:cniackz/enterprise.git
}
function gcdpv(){
	cd $GOPATH/src/github.com/minio
	git clone git@github.com:cniackz/directpv.git
	cd $GOPATH/src/github.com/minio/directpv
}
function compiledpv() {
	cd /home/ccelis/directpv
	go build -v ./...
        echo "did it build?"
        read worked
        if [ "$worked" == "yes"  ]; then
            echo "will proceed then"
        else
            echo "stopping here"
            return 0
        fi
	./build.sh
	docker build -t quay.io/cniackz4/directpv:newbuildtag1 .
	#docker push quay.io/cniackz4/directpv:newbuildtag1
	./kubectl-directpv install --image directpv:newbuildtag1 --org cniackz4 --registry quay.io
	#./kubectl-directpv drives list
}
function squashconsole() {
        git remote add upstream git@github.com:minio/console.git
        git fetch upstream
        git rebase -i upstream/master
}
function squashdpv(){
	git remote add upstream git@github.com:minio/directpv.git
	git fetch upstream
	git rebase -i upstream/master
}
function squashenterprise() {
	git remote add upstream git@github.com:miniohq/enterprise.git
	git fetch upstream
	git rebase -i upstream/master
}
function updateconsole() {
	git checkout master
	git remote add upstream git@github.com:minio/console.git
	git fetch upstream
	git rebase upstream/master
	echo "push if ok"
}
function updatedpv() {
	git checkout master
	git remote add upstream git@github.com:minio/directpv.git
	git fetch upstream
	git checkout master
	git rebase upstream/master
	echo "push if ok"
}
function updateoperator() {
        git checkout master
        git remote add upstream git@github.com:minio/operator.git
        git fetch upstream
        git rebase upstream/master
        echo "push if ok"
}
function squashmintauto() {
	git remote add upstream git@github.com:miniohq/mint-auto.git
	git fetch upstream
	git rebase -i upstream/master
}
function updateminio() {
	git checkout master
	git remote add upstream git@github.com:minio/minio.git
	git fetch upstream
	git checkout master
	git rebase upstream/master
	echo "git push if all goes well"	
}
function updateenterprise() {
	git checkout master
	git remote add upstream git@github.com:miniohq/enterprise.git
	git fetch upstream
	git rebase upstream/master
	echo "push ok"
}

export PATH=$PATH:/usr/local/go/bin



# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
source <(kubectl completion bash)
complete -o default -F __start_kubectl k

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
