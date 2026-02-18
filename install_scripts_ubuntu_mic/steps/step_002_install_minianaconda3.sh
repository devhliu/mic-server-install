#!/bin/bash

#------------------------------------------------------------------------------------
#
# version
# updated @ 2025-03-01
#
#------------------------------------------------------------------------------------

# check install path then make one if not exist
# if [ "$#" -lt 1 ]; then
# 	echo "Usage: $0 <install folder (absolute path)> $1 <force or not>"
# 	echo "For sudoer recommend: $0 /opt"
# 	echo "For normal user recommend: $0 $HOME"
# 	exit 0
# fi
DEST=$HOME
mkdir -p $DEST

# environments and settings
ANACONDA3_DIR=$DEST/.miniconda3
ANACONDA3_INST_FILE=Miniconda3-py311_25.1.1-2-Linux-x86_64.sh
USING_MIRROR=true
if $USING_MIRROR; then
    ANACONDA3_REPO_URL=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda
else
    ANACONDA3_REPO_URL=https://repo.continuum.io/miniconda
fi
if [ -d $ANACONDA3_DIR ]; then
	rm -rf $ANACONDA3_DIR
fi
mkdir $ANACONDA3_DIR

echo -n "installing miniconda3..." #-n without newline
# download anaconda3
#-P: prefix, where there file will be save to
wget -nv -P $ANACONDA3_DIR --tries=10 $ANACONDA3_REPO_URL/$ANACONDA3_INST_FILE
#-b: bacth mode, -f: no error if install prefix already exists
bash $ANACONDA3_DIR/$ANACONDA3_INST_FILE -b -f -p $ANACONDA3_DIR
rm $ANACONDA3_DIR/$ANACONDA3_INST_FILE

# using user profile
if [ -e $HOME/.profile ]; then #ubuntu
	PROFILE=$HOME/.profile
elif [ -e $HOME/.bash_profile ]; then #centos
	PROFILE=$HOME/.bash_profile
else
	echo "Add PATH manualy: PATH=$ANACONDA3_DIR/bin"
	exit 0
fi

#check if PATH already exist in $PROFILE
if grep -xq "export PATH=$ANACONDA3_DIR/bin:\$PATH" $PROFILE #return 0 if exist
then 
	echo "PATH=$ANACONDA3_DIR/bin" in the PATH already.
else
	echo "" >> $PROFILE    
	echo "# anaconda3" >> $PROFILE 
	echo "ANACONDA3_DIR=$ANACONDA3_DIR"
	echo "export PATH=$ANACONDA3_DIR/bin:\$PATH" >> $PROFILE
fi
source $PROFILE

# add conda mirror
if $USING_MIRROR; then
	# echo "ssl_verify: true" >> $HOME/.condarc
	echo "show_channel_urls: true" >> $HOME/.condarc
	echo "channels:" >> $HOME/.condarc
	# echo "  - defaults" >> $HOME/.condarc
	# echo "channel_alias: https://mirrors.tuna.tsinghua.edu.cn/anaconda" >> $HOME/.condarc
	# echo "default_channels:" >> $HOME/.condarc
	echo "  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main" >> $HOME/.condarc
	# echo "custom_channels:" >> $HOME/.condarc
	# echo "  auto: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud" >> $HOME/.condarc
	python -m pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
fi

conda update --all
conda clean --all

#test installation
echo "test anaconda install: "
conda update conda -y > /dev/null
if [ $? -eq 0 ]; then
	echo 'SUCCESS'
	echo "To update PATH of current terminal: source $PFORFILE"
	echo "To update PATH of all terminal: re-login"
else
    echo 'FAIL.'
fi

# conda install scikit-learn-intelex

# install 3rd party packages

# mrtrix3
# wget https://anaconda.org/MRtrix3/mrtrix3/3.0.3/download/linux-64/mrtrix3-3.0.3-h2bc3f7f_0.tar.bz2
# conda install conda-linux-mrtrix3-3.0.2-h6bb024c_0.tar.bz2
# rm conda-linux-mrtrix3-3.0.2-h6bb024c_0.tar.bz2
# ants
# wget https://anaconda.org/Aramislab/ants/2.3.1/download/linux-64/ants-2.3.1-hf484d3e_0.tar.bz2
# conda install ants-2.3.1-hf484d3e_0.tar.bz2
# rm ants-2.3.1-hf484d3e_0.tar.bz2

# dipy
# pip install dipy
# pip install antspyx

# deep learning
# NVIDIA driver >= 450.80.02

# pytorch cuda 11.1
# pip install torch==1.8.2+cu111 torchvision==0.9.2+cu111 torchaudio==0.8.2 -f https://download.pytorch.org/whl/lts/1.8/torch_lts.html

# tensorflow cuda 11.2
# pip install tensorflow==2.8.0
