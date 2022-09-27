#!/bin/bash

#SBATCH --job-name="pickOTUopenRef-16s"
#SBACTH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=14-00:00:00
#SBATCH --mail-user=taruna.aggarwal@ucr.edu
#SBATCH --mail-type=END,FAIL
#SBATCH -e pickOTUopenRef-16s.err-%N
#SBATCH -o pickOTUopenRef-16s.out-%N
