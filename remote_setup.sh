#!/bin/sh

if [ $# -lt 1 ]; then
	echo 'usage: hostip'
	exit 1
fi

hostip=$1
user=ubuntu

program_dir=../../bft-smart-mod

ssh -l $user $hostip sudo apt update
ssh -l $user $hostip sudo apt install -y zsh lv screen default-jre-headless iperf3
ssh -l $user $hostip sudo chsh -s /bin/zsh $user
scp ~/.vimrc.compat $user@$hostip:.vimrc
scp ~/.zshrc $user@$hostip:.zshrc
rsync -av --delete --exclude=.git --exclude='*.java' --exclude='*.class' --exclude='*.swp' $program_dir $user@$hostip:
