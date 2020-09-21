#!/bin/bash
#
########################################
# USER MODIFIABLE PARAMETERS:
 PART=short   	# partition name
 TASKS=28       # 28 cores
 TIME="12:00:00" # 12 hours
 GPU=1			# 1 GPU
 QOS=normal		# QOS Name
########################################
#
# TRAP SIGINT AND SIGTERM OF THIS SCRIPT
function control_c {
    echo -en "\n SIGINT: TERMINATING SLURM JOBID $JOBID AND EXITING \n"
    scancel $JOBID
    rm pycharm-server.sbatch
    exit $?
}
trap control_c SIGINT
trap control_c SIGTERM
#
# SBATCH FILE FOR ALLOCATING COMPUTE RESOURCES TO RUN NOTEBOOK SERVER
create_sbatch() {
cat << EOF
#!/bin/bash
#
#SBATCH --job-name pycharm_srv
#SBATCH --partition $PART
#SBATCH --qos $QOS
##SBATCH --ntasks-per-node=$TASKS
##SBATCH --cpus-per-task=1
#SBATCH --time=$TIME
#SBATCH --gres=gpu:$GPU
##SBATCH -J pycharm_server
#SBATCH -o $CWD/pycharm_session_%J.log

#
launch='sleep 600'
echo " STARTING JOB WITH THE COMMAND:  \$launch "
while true; do
        eval \$launch
done
EOF
}
#
## CREATE SESSION LOG FOLDER 
#if [ ! -d session_logs ] ; then
#   mkdir session_logs
#fi
##
# CREATE PYCHARM SBATCH FILE
export CWD=`pwd`
create_sbatch > pycharm-server.sbatch
#
# START NOTEBOOK SERVER
#
export JOBID=$(sbatch pycharm-server.sbatch  | awk '{print $4}')
NODE=$(squeue -hj $JOBID -O nodelist )
if [[ -z "${NODE// }" ]]; then
   echo  " "
   echo -n "    WAITING FOR RESOURCES TO BECOME AVAILABLE (CTRL-C TO EXIT) ..."
fi
while [[ -z "${NODE// }" ]]; do
   echo -n "."
   sleep 3
   NODE=$(squeue -hj $JOBID -O nodelist )
done
  HOST_NAME=$(squeue -j $JOBID -h -o  %B)
#  HOST_IP=$(ssh -q $HOST_NAME 'hostname -i')
  HOST_IP=$(grep -i $HOST_NAME /etc/hosts | awk '{ print $1 }')
  TIMELIM=$(squeue -hj $JOBID -O timeleft )
  if [[ $TIMELIM == *"-"* ]]; then
  DAYS=$(echo $TIMELIM | awk -F '-' '{print $1}')
  HOURS=$(echo $TIMELIM | awk -F '-' '{print $2}' | awk -F ':' '{print $1}')
  MINS=$(echo $TIMELIM | awk -F ':' '{print $2}')
  TIMELEFT="THIS SESSION WILL TIMEOUT IN $DAYS DAY $HOURS HOUR(S) AND $MINS MINS "
  else
  HOURS=$(echo $TIMELIM | awk -F ':' '{print $1}' )
  MINS=$(echo $TIMELIM | awk -F ':' '{print $2}')
  TIMELEFT="THIS SESSION WILL TIMEOUT IN $HOURS HOUR(S) AND $MINS MINS "
  fi
  echo " "
  echo "  --------------------------------------------------------------------"
  echo "    STARTING PYCHARM SERVER ON NODE $NODE           "
  echo "    $TIMELEFT"
  echo "    SESSION LOG WILL BE STORED IN pycharm_session_${JOBID}.out  "
  echo "  --------------------------------------------------------------------"
  echo "  "
  echo "    TO ACCESS THIS COMPUTE SERVER, COPY AND PASTE "
  echo "    THE FOLLOWING IP ADDRESS INTO YOUR PYCHARM REMOTE: "
  echo "  "
  echo "    ${HOST_IP}  "
  echo "  "
  echo "  --------------------------------------------------------------------"
  echo "  "
  echo "    TO KILL THIS SERVER ISSUE THE FOLLOWING COMMAND: "
  echo "  "
  echo "       scancel $JOBID "
  echo "  "
  echo "  --------------------------------------------------------------------"
  echo "  "
#
# CLEANUP
  rm pycharm-server.sbatch
#
# EOF
