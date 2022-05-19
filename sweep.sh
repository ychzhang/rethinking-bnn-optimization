#!/bin/bash
VM_NAME=v2vm$1
ZONE=us-central1-f
TMUX_SESSION=bop
FOLDER=rethinking-bnn-optimization
COMMAND="
	mkdir log &&
	cd rethinking-bnn-optimization &&
	pip install -e . &&
	for tau in {0.2e-2,1e-2,5e-2}
	do
		for gamma1 in {0.2e-4,1e-4,1e-3,1e-2}
		do
			/home/yichi/.local/bin/bnno train binarynet --dataset cifar10 --preprocess-fn resize_and_flip --hparams-set bop_sec52 --hparams threshold=\$tau,gamma=\$gamma1 2>&1 | tee -a /home/yichi/log/training_log_tau\$tau_g1_\$gamma1.txt
		done
	done
"

# copy $FOLDER to TPU vm
mkdir /home/yichi/test
cp -r /home/yichi/bop/$FOLDER /home/yichi/test/$FOLDER
rm -rf /home/yichi/test/$FOLDER/.git
gcloud alpha compute tpus tpu-vm scp /home/yichi/test/$FOLDER $VM_NAME: --worker=all --zone=$ZONE --recurse
rm -r /home/yichi/test
# ssh and execute command on VM
gcloud alpha compute tpus tpu-vm ssh $VM_NAME --zone $ZONE --worker=all --command "tmux new-session -d -s $TMUX_SESSION '$COMMAND'"
