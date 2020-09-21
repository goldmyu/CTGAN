#!/bin/bash

##################
### sbatch configuration parameters must start with #SBATCH and must precede any other commands.
### To ignore, just add another # - like ##SBATCH
##################

##PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
##debug*       up    2:00:00     10    mix cs-gpu-[01-02,06-08],dt-gpu-[01-03],ise-gpu-[01-02]
##short        up 7-00:00:00     11    mix cs-gpu-[01-02,06-08],dt-gpu-[01-03],ise-gpu-[01-02],ise-titan-01
##gtx1080      up 7-00:00:00      7    mix cs-1080-[01-03],ise-1080-[01-04]
##gtx1080      up 7-00:00:00      1  alloc dt-1080-01
##titanrtx     up 7-00:00:00      1    mix ise-titan-01




#SBATCH --partition short		### specify partition name where to run a job. debug: 2 hours limit; short: 7 days limit
##SBATCH --time 0-12:00:00	    ### limit the time of job running, partition limit can override this. Format: D-H:MM:SS
#SBATCH --job-name ctgan			        ### name of the job
#SBATCH --output generated_files/output_logs/ctgan-%J.out			### output log for running job - %J for job number
#SBATCH --mail-user=goldmyu@post.bgu.ac.il	    ### user email for sending job status
#SBATCH --mail-type=NONE						### conditions when to send the email. ALL,BEGIN,END,FAIL, REQUEU, NONE
#SBATCH --gres=gpu:1							### number of GPUs, ask for more than 1 only if you can parallelize your code for multi GPU
#SBATCH --mem=64G
#SBATCH --cpus-per-task=12



### Print some datasets to output file ###
echo `date`
echo -e "\nSLURM_JOBID:\t\t" $SLURM_JOBID
echo -e "SLURM_JOB_NODELIST:\t" $SLURM_JOB_NODELIST "\n"

### Start you code below ####
module load anaconda				### load anaconda module (must present when working with conda environments)
source activate preempt				### activating environment, environment must be configured before running the job

#srun --mem=24G jupyter lab		    ### execute jupyter lab command – replace with your own command
									### (e.g. “srun --mem=24G python my.py my_arg”.
									### You may use multiple srun lines, they are the job steps.
									### --mem - memory to allocate: use 24G x number for each allocated GPUs (24G * nGPU)

python src/models/ctgan/main.py