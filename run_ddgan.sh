#!/bin/sh
export MASTER_PORT=6036
echo MASTER_PORT=${MASTER_PORT}

export PYTHONPATH=$(pwd):$PYTHONPATH

CURDIR=$(cd $(dirname $0); pwd)
echo 'The work dir is: ' $CURDIR

DATASET=$1
MODE=$2
GPUS=$3

if [ -z "$1" ]; then
   GPUS=1
fi

echo $DATASET $MODE $GPUS

# ----------------- VANILLA -----------
if [[ $MODE == train ]]; then
	echo "==> Training DDGAN"

    if [[ $DATASET == cifar10 ]]; then
        python train_ddgan.py --dataset cifar10 --exp ddgan_cifar10_exp1 --num_channels 3 --num_channels_dae 128 --num_timesteps 4 \
			--num_res_blocks 2 --batch_size 256 --num_epoch 1800 --ngf 64 --nz 100 --z_emb_dim 256 --n_mlp 4 --embedding_type positional \
			--use_ema --ema_decay 0.9999 --r1_gamma 0.02 --lr_d 1.25e-4 --lr_g 1.6e-4 --lazy_reg 15 \
			--ch_mult 1 2 2 2 --save_content --datadir data/cifar-10 \
			--master_port $MASTER_PORT --num_process_per_node $GPUS \

	elif [[ $DATASET == stl10 ]]; then
		python train_ddgan.py --dataset stl10 --exp ddgan_stl10_exp1 --num_channels 3 --num_channels_dae 128 --num_timesteps 4 \
			--num_res_blocks 2 --batch_size 128 --num_epoch 1800 --ngf 64 --nz 100 --z_emb_dim 256 --n_mlp 4 --embedding_type positional \
			--use_ema --ema_decay 0.9999 --r1_gamma 0.02 --lr_d 1.25e-4 --lr_g 1.6e-4 --lazy_reg 15 \
			--ch_mult 1 2 2 2 --save_content --datadir data/STL-10 \
			--master_port $MASTER_PORT --num_process_per_node $GPUS \

	elif [[ $DATASET == celeba_256 ]]; then
		python train_ddgan.py --dataset celeba_256 --image_size 256 --exp ddgan_celebahq_256_exp1 --num_channels 3 --num_channels_dae 64 --ch_mult 1 1 2 2 4 4 --num_timesteps 2 \
			--num_res_blocks 2 --batch_size 32 --num_epoch 500 --ngf 64 --embedding_type positional --use_ema --r1_gamma 2. \
			--z_emb_dim 256 --lr_d 1e-4 --lr_g 2e-4 --lazy_reg 10 --save_content --datadir data/celeba/celeba-lmdb/ \
			--master_port $MASTER_PORT --num_process_per_node $GPUS \

	elif [[ $DATASET == celeba_512 ]]; then
		python train_ddgan.py --dataset celeba_512 --image_size 512 --exp ddgan_celebahq_512_exp1 --num_channels 3 --num_channels_dae 64 --ch_mult 1 1 2 2 4 4 --num_timesteps 2 \
			--num_res_blocks 2 --batch_size 2 --num_epoch 400 --ngf 64 --embedding_type positional --use_ema --r1_gamma 2. \
			--z_emb_dim 256 --lr_d 1e-4 --lr_g 2e-4 --lazy_reg 10 --save_content --datadir data/celeba_512/celeba-lmdb-512/ \
			--master_port $MASTER_PORT --num_process_per_node $GPUS \
			--save_content_every 25 \

	elif [[ $DATASET == lsun ]]; then
		python train_ddgan.py --dataset lsun --image_size 256 --exp ddgan_lsun_exp1 --num_channels 3 --num_channels_dae 64 --ch_mult 1 1 2 2 4 4 --num_timesteps 4 \
			--num_res_blocks 2 --batch_size 8 --num_epoch 500 --ngf 64 --embedding_type positional --use_ema --ema_decay 0.999 --r1_gamma 1. \
			--z_emb_dim 256 --lr_d 1e-4 --lr_g 1.6e-4 --lazy_reg 10 --save_content --datadir data/lsun/ \
			--master_port $MASTER_PORT --num_process_per_node $GPUS \

	fi
else
	echo "==> Test DDGAN"
	if [[ $DATASET == cifar10 ]]; then \
		python test_ddgan.py --dataset cifar10 --exp ddgan_cifar10_exp1 --num_channels 3 --num_channels_dae 128 --num_timesteps 4 \
			--num_res_blocks 2 --nz 100 --z_emb_dim 256 --n_mlp 4 --ch_mult 1 2 2 2 --epoch_id 1200 \
			--compute_fid --real_img_dir pytorch_fid/cifar10_train_stat.npy \
			# --measure_time \

	elif [[ $DATASET == stl10 ]]; then
		python test_ddgan.py --dataset stl10 --image_size 64 --exp ddgan_stl10_exp1 --num_channels 3 --num_channels_dae 128 --num_timesteps 4 \
			--num_res_blocks 2 --nz 100 --z_emb_dim 256 --n_mlp 4 --ch_mult 1 2 2 2 --epoch_id 900 \
			# --compute_fid --real_img_dir pytorch_fid/stl10_stat.npy \
			# --measure_time \

	elif [[ $DATASET == celeba_256 ]]; then
		python test_ddgan.py --dataset celeba_256 --image_size 256 --exp ddgan_celebahq_exp1 --num_channels 3 --num_channels_dae 64 \
			--ch_mult 1 1 2 2 4 4 --num_timesteps 2 --num_res_blocks 2  --epoch_id 550 \
			# --compute_fid --real_img_dir pytorch_fid/celebahq_stat.npy
			# --measure_time \

	elif [[ $DATASET == celeba_512 ]]; then
		python test_ddgan.py --dataset celeba_512 --image_size 512 --exp ddgan_celebahq_512_exp1 --num_channels 3 --num_channels_dae 64 \
			--ch_mult 1 1 2 2 4 4 --num_timesteps 2 --num_res_blocks 2  --epoch_id 325 \
			--batch_size 100 \
			# --compute_fid --real_img_dir ./pytorch_fid/celebahq_512_stat.npy \
			# --measure_time --batch_size 25 \

	elif [[ $DATASET == lsun ]]; then
		python test_ddgan.py --dataset lsun --image_size 256 --exp ddgan_lsun_exp1 --num_channels 3 --num_channels_dae 64 \
			--ch_mult 1 1 2 2 4 4  --num_timesteps 4 --num_res_blocks 2  --epoch_id 500 \
			# --compute_fid --real_img_dir pytorch_fid/lsun_church_stat.npy \
			# --measure_time \

	fi
fi
