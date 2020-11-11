Bootstrap: docker
From: ubuntu:latest

%help
    This container assembles and polishes genomes using the Pyro front-end wrapper. Any of the Pyro programs can be called normally through the container to run them individually without Pyro getting involved, but generally better to go through the wrapper script.

%labels
    Maintainer Genomeassembler
    Version v1.0

%environment
    BUSCO_CONFIG_FILE=x
    AUGUSTUS_CONFIG_PATH=x
    RSTUDIO_PANDOC=x
    export BUSCO_CONFIG_FILE AUGUSTUS_CONFIG_PATH RSTUDIO_PANDOC
    export PATH=$PATH:/add/to/path:/add/to/path2

%runscript
    echo "Singularity loaded. Running $*"
    exec "$@"

%post
# update and upgrade packages
    sudo apt-get update && sudo apt-get upgrade -y
# get miniconda
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    chmod +x Miniconda3-latest-Linux-x86_64.sh
    ./Miniconda3-latest-Linux-x86_64.sh
    rm Miniconda3-latest-Linux-x86_64.sh
# get things from apt:
    sudo apt-get install -y build-essential default-jre dirmngr gnupg apt-transport-https ca-certificates software-properties-common zlib1g-dev cmake libcurl libpthread-stubs0-dev libboost-all-dev openmpi-bin libopenmpi-dev libsparsehash-dev mpi libomp-dev libjemalloc-dev libbz2-dev libncurses5-dev libncursesw5-dev liblzma-dev perl pigz git samtools cutadapt fastqc bwa
# refresh so everything can see everything else
    source ~/.bashrc
# get R
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
    sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
    sudo apt install r-base
# get things from conda
    conda install minimap2
# other installs
# htslib
    cd /usr/bin
    wget https://github.com/samtools/htslib/releases/download/1.11/htslib-1.11.tar.bz2
    tar -vxjf htslib-1.11.tar.bz2
    cd htslib-1.11
    make
    cd .. && rm htslib-1.11.tar.bz2
# ncbi-blast
    wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.11.0+-x64-linux.tar.gz
    tar -xzf ncbi-blast-2.11.0+-x64-linux.tar.gz
# linuxbrew
    cd /usr/local && mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew



