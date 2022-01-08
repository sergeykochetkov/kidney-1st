
#pytorch/pytorch:1.8.0-cuda11.1-cudnn8-devel

set -x

PASS=${1:-11339}
USER_SERVER=${2:-root@ssh4.vast.ai}

GIT_USERNAME=sergeykochetkov
GIT_PAT=${3:-no_pat}

EXPERIMENT_NAME=${4:-default}

INSTALL_ENV=${5:-false}


REPO_DIR=Kidney-1st

REMOTE_HOME=/root
CA="source $REMOTE_HOME/miniconda/bin/activate"

SSH="ssh -p ${PASS} ${USER_SERVER} -L 8081:localhost:8081"

if $INSTALL_ENV
then


$SSH  "apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata && apt-get install nano htop expect screen git -y" &&

$SSH "apt-get install wget curl unzip -y"  &&

$SSH  "apt-get install ffmpeg libsm6 libxext6  -y" &&

$SSH "wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh"  &&

$SSH " bash ~/miniconda.sh -u -b -p $REMOTE_HOME/miniconda && ${CA} && conda init bash"  &&

$SSH "git clone https://${GIT_USERNAME}:${GIT_PAT}@github.com/sergeykochetkov/kidney-1st.git ${REPO_DIR}" &&

$SSH "$CA && conda install pytorch==1.8.0 torchvision==0.9.0 torchaudio==0.8.0 cudatoolkit=11.1 -c pytorch -c conda-forge -y" &&

$SSH "$CA && cd ${REPO_DIR} && pip install -r requirements.txt" &&

$SSH "curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip  && unzip awscliv2.zip  && ./aws/install" &&

$SSH "cd ${REPO_DIR} && chmod +x aws_configure.exp && ./aws_configure.exp " &&

$SSH "cd ${REPO_DIR}/src/01_data_preparation/01_01 && aws s3 cp s3://kochetkov-kidney/kidney-1st/result_01_01/01_01/ result/01_01 --recursive" &&

$SSH "cd ${REPO_DIR}/src/01_data_preparation/01_02 && aws s3 cp s3://kochetkov-kidney/kidney-1st/result_01_02/01_02/ result/01_02 --recursive" &&

$SSH "$CA && cd ${REPO_DIR}src/pretrained-models.pytorch-master && pip install -e . "

else

$SSH "cd ${REPO_DIR} && git pull "

fi


cmd="$CA cd ${REPO_DIR}/src/02_train && python train_02.py "


cmd="${cmd} && aws s3 cp result s3://kochetkov-kidney/kidney-1st/$EXPERIMENT_NAME --recursive"

$SSH "echo \"${cmd}\">script.sh"
$SSH "chmod +x script.sh"
$SSH "pkill screen"
$SSH "screen -S my_screen -d -m "
$SSH "screen -S my_screen -X stuff \"./script.sh &> local_log.txt\n\""
