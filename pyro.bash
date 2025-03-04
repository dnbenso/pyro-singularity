#!/bin/bash
set -e

BUSCO_CONFIG_FILE=/usr/local/busco/config/myconfig.ini
AUGUSTUS_CONFIG_PATH=/usr/local/config/
RSTUDIO_PANDOC=/usr/bin/pandoc
export BUSCO_CONFIG_FILE AUGUSTUS_CONFIG_PATH RSTUDIO_PANDOC

SRC_DIR=/usr/local/src
BLD_DIR=/usr/local/build
PKG_DIR=/usr/local/stow
CPUS=30
mkdir -p $SRC_DIR $BLD_DIR $PKG_DIR
export CFLAGS="-O3 -mtune=native -march=native"
export CXXFLAGS="$CFLAGS"

sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/mirror.aarnet.edu.au\/ubuntu\//' /etc/apt/sources.list
## update and upgrade packages, get basics, set up bashrc ##
echo "# Pyro BASHRC File" >~/.bashrc
echo "export PATH=\$PATH:/usr/local/scripts" >>~/.bashrc
apt update && apt install -y apt-utils && apt install -y sudo wget curl stow && apt-get upgrade -y

## get things from apt: ##
# first batch
DEBIAN_FRONTEND=noninteractive apt install -y build-essential default-jre dirmngr gnupg apt-transport-https ca-certificates software-properties-common cmake tzdata psmisc dazzdb
# second batch
apt install -y libcurl4-gnutls-dev libpthread-stubs0-dev libboost-all-dev openmpi-bin libopenmpi-dev libsparsehash-dev
apt install -y mpi libomp-dev libjemalloc-dev libbz2-dev libncurses5-dev libncursesw5-dev liblzma-dev
apt install -y perl pigz git samtools cutadapt fastqc bwa ray jellyfish swig
apt install -y libsqlite3-dev libmysql++-dev libgsl-dev liblpsolve55-dev libsuitesparse-dev libbamtools-dev
apt install -y pandoc python3-setuptools abyss doxygen python3-biopython python3-pandas python2 python3-matplotlib
apt install -y python g++-7 ninja-build time python-psutil vim
apt autoremove -y
apt autoclean -y

## get R ##
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
apt install -y r-base

cd /usr/bin
mv gunzip gunzip-gnu && ln unpigz gunzip
mv gzip  gzip-gnu && ln pigz gzip

# Compiled Apps
HTSLIB_VERSION=1.12
BCFTOOLS_VERSION=1.12
SAMTOOLS_VERSION=1.12
AUGUSTUS_VERSION=3.4.0
NCBI_BLAST_VERSION=2.12.0+
KMC_VERSION=3.1.1
PRODIGAL_VERSION=2.6.3
HMMER_VERSION=3.3.1
HYPO_VERSION=1.0.3
SOAPDENOVO2_VERSION=r242
MINIASM_VERSION=0.3
RAVEN_VERSION=1.5.0
WTDBG2_VERSION=2.5
NEXTPOLISH_VERSION=1.3.1
NTHITS_VERSION=0.0.1
NTEDIT_VERSION=1.3.5
RED_VERSION=2.0
#MECAT_VERSION=
#HASLR_VERSION=
#SEQTK_VERSION=
#RATATOSK_VERSION=
#W2WRAP_VERSION=
#DBG2OLC_VERSION=
#RACON_VERSION=
#ASSEMBLY-STATS_VERSION=
#METAEUK_VERSION=

# Apps not compiled
SHASTA_VERSION=0.6.0
NECAT_VERSION=0.0.1_update20200803
PLATANUS_VERSION=1.2.4 # Version number obfuscated in download link
MINIMAP2_VERSION=2.18
TRIMGALORE_VERSION=0.6.6
FILTLONG_VERSION=0.2.0
BBMAP_VERSION=38.90
SPADES_VERSION=3.15.2
CANU_VERSION=2.1.1
MASHMAP_VERSION=2.0


# Java Libraries
PILON_VERSION=1.24

# PYTHON Libraries
SEPP_VERSION=4.5.1
FLYE_VERSION=2.8.3
FALCON_UNZIP_VERSION=0.4.0
#BUSCO_VERSION=
#BUSCOMP_VERSION=
QUAST_VERSION=5.1.0rc1

### Git repo ###
#GENOMESCOPE_VERSION=

### CONDA ###
MINICONDA_VERSION=4.6.14

### Compiled Applications ###

## htslib ##
# get
cd $SRC_DIR && wget https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2
cd $BLD_DIR && tar -xjf $SRC_DIR/htslib-${HTSLIB_VERSION}.tar.bz2 && cd htslib-${HTSLIB_VERSION}
# make
autoreconf -i && ./configure --prefix=$PKG_DIR/htslib-${HTSLIB_VERSION}
make -j $CPUS && make install
cd $PKG_DIR && stow -v htslib-${HTSLIB_VERSION}

## bcftools ##
# get
cd $SRC_DIR && wget https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2
cd $BLD_DIR && tar -xjf $SRC_DIR/bcftools-${BCFTOOLS_VERSION}.tar.bz2 && cd bcftools-${BCFTOOLS_VERSION}
# make
autoreconf -i && ./configure --prefix=$PKG_DIR/bcftools-${BCFTOOLS_VERSION}
make -j $CPUS && make install
cd $PKG_DIR && stow -v bcftools-${BCFTOOLS_VERSION}

## samtools ##
# get
cd $SRC_DIR && wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2
cd $BLD_DIR && tar -xjf $SRC_DIR/samtools-${SAMTOOLS_VERSION}.tar.bz2 && cd samtools-${SAMTOOLS_VERSION}
# make
autoreconf -i && ./configure --prefix=$PKG_DIR/samtools-${SAMTOOLS_VERSION}
make -j $CPUS && make install
cd $PKG_DIR && stow -v samtools-${SAMTOOLS_VERSION}

## Augustus ##
# get
cd $SRC_DIR && wget https://github.com/Gaius-Augustus/Augustus/releases/download/v${AUGUSTUS_VERSION}/augustus-${AUGUSTUS_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/augustus-${AUGUSTUS_VERSION}.tar.gz && cd augustus-${AUGUSTUS_VERSION}
# make
sed -i -e 's/install:/install-orig:/' Makefile
sed -i -e 's/INSTALLDIR = \/opt\/augustus-/INSTALLDIR = \/usr\/local\/stow\/augustus-/' Makefile
sed -i -e '/^INSTALLDIR =/a \\ninstall:\n\tinstall -d $(INSTALLDIR)\n\tcp -a config bin scripts $(INSTALLDIR)' Makefile
sed -i -e 's/INCLUDES=-I\/usr\/include\/htslib/INCLUDES=-I\/usr\/local\/include\/htslib/' auxprogs/bam2wig/Makefile
sed -i -e 's/AUGVERSION = 3.3.3/AUGVERSION = 3.4.0/' common.mk
make -j $CPUS all && make install
cd $PKG_DIR && stow -v augustus-${AUGUSTUS_VERSION}

## KMC ##
# get
cd $SRC_DIR && wget https://github.com/refresh-bio/KMC/archive/refs/tags/v${KMC_VERSION}.tar.gz -O kmc-${KMC_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/kmc-${KMC_VERSION}.tar.gz && cd $BLD_DIR/KMC-${KMC_VERSION}
# build
make -j $CPUS all 
cd bin && mkdir -p $PKG_DIR/kmc-${KMC_VERSION}/bin $PKG_DIR/kmc-${KMC_VERSION}/lib
cp kmc kmc_dump kmc_tools $PKG_DIR/kmc-${KMC_VERSION}/bin
cp py_kmc_api.cpython-38-x86_64-linux-gnu.so $PKG_DIR/kmc-${KMC_VERSION}/lib
cd $PKG_DIR && stow -v kmc-${KMC_VERSION}

## prodigal ##
# get
cd $SRC_DIR && wget https://github.com/hyattpd/Prodigal/archive/refs/tags/v${PRODIGAL_VERSION}.tar.gz -O prodigal-${PRODIGAL_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/prodigal-${PRODIGAL_VERSION}.tar.gz && cd Prodigal-${PRODIGAL_VERSION}
# build
sed -i -e 's/INSTALLDIR  = \/usr\/local\/bin/INSTALLDIR  = \/usr\/local\/stow\/prodigal-2.6.3\/bin/' Makefile
make -j $CPUS all && make install
cd $PKG_DIR && stow -v prodigal-2.6.3

## hmmer ##
# get
cd $SRC_DIR && wget http://eddylab.org/software/hmmer/hmmer-${HMMER_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/hmmer-${HMMER_VERSION}.tar.gz && cd hmmer-${HMMER_VERSION}
# build
./configure --prefix=$PKG_DIR/hmmer-${HMMER_VERSION}
make -j $CPUS && make install
cd $PKG_DIR && stow -v hmmer-${HMMER_VERSION}

## hypo ##
#get
cd $SRC_DIR && wget https://github.com/kensung-lab/hypo/archive/refs/tags/v${HYPO_VERSION}.tar.gz -O hypo-${HYPO_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/hypo-${HYPO_VERSION}.tar.gz
cd hypo-${HYPO_VERSION}/external/install && mv htslib htslib.back && ln -s /usr/local/stow/htslib-1.12 htslib
mkdir $BLD_DIR/hypo-${HYPO_VERSION}/build && cd $BLD_DIR/hypo-${HYPO_VERSION}/build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PKG_DIR/hypo-${HYPO_VERSION} -G Ninja ..
ninja -j $CPUS && ninja install
cd $PKG_DIR && stow -v hypo-${HYPO_VERSION}

## soapdenovo2 ##
# get
SAMTOOLS_VERSION=0.1.19 # for dependency
# get
cd $SRC_DIR && wget https://downloads.sourceforge.net/project/samtools/samtools/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2
cd $BLD_DIR && tar -xjf $SRC_DIR/samtools-${SAMTOOLS_VERSION}.tar.bz2
# build
cd samtools-${SAMTOOLS_VERSION} && make -j $CPUS
# get
cd $SRC_DIR && wget https://github.com/aquaskyline/SOAPdenovo2/archive/refs/tags/${SOAPDENOVO2_VERSION}.tar.gz -O soapdenovo2-${SOAPDENOVO2_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/soapdenovo2-${SOAPDENOVO2_VERSION}.tar.gz
cd SOAPdenovo2-${SOAPDENOVO2_VERSION} && cp $BLD_DIR/samtools-0.1.19/libbam.a sparsePregraph/inc
# build
make all
mkdir -p $PKG_DIR/soapdenovo2-${SOAPDENOVO2_VERSION}/bin && cp SOAPdenovo-127mer SOAPdenovo-63mer SOAPdenovo-fusion $PKG_DIR/soapdenovo2-${SOAPDENOVO2_VERSION}/bin
cd $PKG_DIR && stow -v soapdenovo2-${SOAPDENOVO2_VERSION}

## miniasm ##
# get
cd $SRC_DIR && wget https://github.com/lh3/miniasm/archive/refs/tags/v${MINIASM_VERSION}.tar.gz -O miniasm-${MINIASM_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/miniasm-${MINIASM_VERSION}.tar.gz && cd miniasm-${MINIASM_VERSION}
# build
make -j $CPUS
mkdir -p $PKG_DIR/miniasm-${MINIASM_VERSION}/bin && cp -r misc tex $PKG_DIR/miniasm-${MINIASM_VERSION} && cp miniasm minidot $PKG_DIR/miniasm-${MINIASM_VERSION}/bin
cd $PKG_DIR && stow -v miniasm-${MINIASM_VERSION}

## raven ##
# get
cd $SRC_DIR && wget https://github.com/lbcb-sci/raven/archive/refs/tags/${RAVEN_VERSION}.tar.gz -O raven-${RAVEN_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/raven-${RAVEN_VERSION}.tar.gz
# build
cd raven-${RAVEN_VERSION} && mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PKG_DIR/raven-${RAVEN_VERSION} -G Ninja ..
ninja -j $CPUS && ninja install
cd $PKG_DIR && stow -v raven-${RAVEN_VERSION}

## wtdbg2 ##
# get
cd $SRC_DIR && wget https://github.com/ruanjue/wtdbg2/archive/refs/tags/v${WTDBG2_VERSION}.tar.gz -O wtdbg2-${WTDBG2_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/wtdbg2-${WTDBG2_VERSION}.tar.gz
cd wtdbg2-${WTDBG2_VERSION} && sed -i -e "s%BIN := /usr/local/bin%BIN := /usr/local/stow/wtdbg2-$WTDBG2_VERSION/bin%" Makefile
# build
make -j $CPUS && make install
cd $PKG_DIR && stow -v  wtdbg2-${WTDBG2_VERSION}

## nextpolish ##
# get
cd $SRC_DIR && wget https://github.com/Nextomics/NextPolish/releases/download/v${NEXTPOLISH_VERSION}/NextPolish.tgz -O nextpolish-${NEXTPOLISH_VERSION}.tgz
cd $BLD_DIR && tar -xzf $SRC_DIR/nextpolish-${NEXTPOLISH_VERSION}.tgz && cd NextPolish
# build
make -j $CPUS
mkdir -p $PKG_DIR/nextpolish-${NEXTPOLISH_VERSION}/bin && cp -r bin $PKG_DIR/nextpolish-${NEXTPOLISH_VERSION}/bin
cp nextPolish  $PKG_DIR/nextpolish-${NEXTPOLISH_VERSION}/bin
cp -r lib $PKG_DIR/nextpolish-${NEXTPOLISH_VERSION}/bin
cd $PKG_DIR && stow -v nextpolish-${NEXTPOLISH_VERSION}

## nthits ##
# get
cd $SRC_DIR && wget https://github.com/bcgsc/ntHits/archive/refs/tags/ntHits-v${NTHITS_VERSION}.tar.gz -O nthits-${NTHITS_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/nthits-${NTHITS_VERSION}.tar.gz
# build
cd ntHits-ntHits-v${NTHITS_VERSION} && ./autogen.sh && ./configure --prefix=$PKG_DIR/nthits-${NTHITS_VERSION}
make -j $CPUS && make install
cd $PKG_DIR && stow -v nthits-${NTHITS_VERSION}

## ntedit ##
# get
cd $SRC_DIR && wget https://github.com/bcgsc/ntEdit/archive/refs/tags/v${NTEDIT_VERSION}.tar.gz -O ntedit-${NTEDIT_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/ntedit-${NTEDIT_VERSION}.tar.gz
# build
cd ntEdit-1.3.5 && make -j $CPUS
mkdir -p $PKG_DIR/ntedit-${NTEDIT_VERSION}/bin && cp ntedit $PKG_DIR/ntedit-${NTEDIT_VERSION}/bin && cp -r lib $PKG_DIR/ntedit-${NTEDIT_VERSION}
cd $PKG_DIR && stow -v ntedit-${NTEDIT_VERSION}

## red ##
# get
cd $SRC_DIR && wget https://github.com/BioinformaticsToolsmith/Red/archive/refs/tags/v${RED_VERSION}.tar.gz -O red-${RED_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/red-${RED_VERSION}.tar.gz
# build
cd Red-${RED_VERSION}/src_2.0 && sed -i 's|CXX = g++-8|CXX = g++|g' Makefile
make bin && make -j $CPUS
mkdir -p $PKG_DIR/red-${RED_VERSION}/bin && cp ../bin/Red $PKG_DIR/red-${RED_VERSION}/bin
cd $PKG_DIR && stow -v red-${RED_VERSION}

## mecat ##
# get
cd $BLD_DIR && git clone https://github.com/xiaochuanle/MECAT2.git && cd MECAT2
# build
make
mkdir $PKG_DIR/mecat2 && cp -r Linux-amd64/bin $PKG_DIR/mecat2
cd $PKG_DIR && stow -v mecat2

## haslr ##
# get
cd $BLD_DIR && git clone https://github.com/vpc-ccg/haslr.git
# DO NOT DO PARALLEL MAKE HERE
cd haslr && make 
mkdir -p $PKG_DIR/haslr/bin && cd bin && cp fastutils haslr.py haslr_assemble minia minia_nooverlap $PKG_DIR/haslr/bin
cd $PKG_DIR && stow -v haslr

## seqt ##
# get
cd $BLD_DIR && git clone https://github.com/lh3/seqtk.git
cd seqtk && make
mkdir -p $PKG_DIR/seqtk/bin && cp seqtk $PKG_DIR/seqtk/bin
cd $PKG_DIR && stow -v seqtk

## ratatosk ##
# get
cd $BLD_DIR && git clone --recursive https://github.com/DecodeGenetics/Ratatosk.git
mkdir Ratatosk/build && cd Ratatosk/build
# build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PKG_DIR/ratatosk ..
make -j $CPUS && make install
cd $PKG_DIR && stow -v ratatosk

## w2wrap ##
# get
cd $BLD_DIR && git clone https://github.com/gonzalogacc/w2rap-contigger.git
cd w2rap-contigger
wget https://raw.githubusercontent.com/dnbenso/patches/main/src/VariantCallTools.patch && patch src/paths/long/VariantCallTools.cc VariantCallTools.patch
# build
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=g++-7 -DCMAKE_INSTALL_PREFIX=$PKG_DIR/w2rap-contigger -G Ninja ..
ninja -j $CPUS && ninja install
cd $PKG_DIR && stow -v w2rap-contigger

## dbg2olc ##
DBG2OLC_VERSION=
# get and build apps
mkdir -p $PKG_DIR/dbg2olc/bin
# DBG2OLC
cd $BLD_DIR && git clone https://github.com/yechengxi/DBG2OLC.git && cd DBG2OLC
g++ -o DBG2OLC -O3 *.cpp && cp DBG2OLC $PKG_DIR/dbg2olc/bin
# Sparc
cd $BLD_DIR && git clone https://github.com/yechengxi/Sparc.git && cd Sparc
g++ -o Sparc -O3 *.cpp && cp Sparc $PKG_DIR/dbg2olc/bin
# SparseAssembler
cd $BLD_DIR && git clone https://github.com/yechengxi/SparseAssembler && cd SparseAssembler
g++ -o SparseAssembler -O3 *.cpp && cp SparseAssembler $PKG_DIR/dbg2olc/bin
# stow apps
cd $PKG_DIR && stow -v dbg2olc

## racon ##
# get
cd $BLD_DIR && git clone --recursive https://github.com/lbcb-sci/racon.git racon
cd racon && mkdir build && cd build
# build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PKG_DIR/racon -G Ninja ..
ninja -j $CPUS && ninja install
cd $PKG_DIR && stow -v racon

## assembly-stats ##
# get
cd $BLD_DIR && git clone https://github.com/sanger-pathogens/assembly-stats.git && cd assembly-stats
mkdir build && cd build
# build
cmake -DCMAKE_BUILD_TYPE=Release -DINSTALL_DIR:PATH=$PKG_DIR/assembly-stats/bin -G Ninja ..
ninja -j $CPUS && ninja install
cd $PKG_DIR && stow -v assembly-stats

## metaeuk ##
# get
cd $BLD_DIR && git clone https://github.com/soedinglab/metaeuk.git && cd metaeuk
mkdir build && cd build
# build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PKG_DIR/metaeuk -G Ninja ..
ninja -j $CPUS && ninja install
cd $PKG_DIR && stow -v metaeuk

### Applications not compiled ###

## shasta ##
# get
mkdir -p $PKG_DIR/shasta-${SHASTA_VERSION}/bin
cd $PKG_DIR/shasta-${SHASTA_VERSION}/bin && wget https://github.com/chanzuckerberg/shasta/releases/download/0.6.0/shasta-Linux-0.6.0 -O shasta
chmod a+x shasta
cd $PKG_DIR && stow -v shasta-${SHASTA_VERSION}

## necat ##
# get
cd $SRC_DIR && wget https://github.com/xiaochuanle/NECAT/releases/download/v0.0.1_update20200803/necat_20200803_Linux-amd64.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/necat_20200803_Linux-amd64.tar.gz
mkdir $PKG_DIR/necat_20200803 && cp -r $BLD_DIR/NECAT/Linux-amd64/bin $PKG_DIR/necat_20200803
# cd $PKG_DIR && stow -v necat_20200803

## platanaus ##
# get
mkdir -p $PKG_DIR/platanus-${PLATANUS_VERSION}/bin && cd $PKG_DIR/platanus-${PLATANUS_VERSION}/bin
wget http://platanus.bio.titech.ac.jp/?ddownload=145 -O platanus && chmod a+x platanus
cd $PKG_DIR && stow -v platanus-${PLATANUS_VERSION}

## minimap2 ##
# get
cd $SRC_DIR && wget https://github.com/lh3/minimap2/releases/download/v${MINIMAP2_VERSION}/minimap2-${MINIMAP2_VERSION}_x64-linux.tar.bz2
cd $BLD_DIR && tar -xjf  $SRC_DIR/minimap2-${MINIMAP2_VERSION}_x64-linux.tar.bz2
cd minimap2-${MINIMAP2_VERSION}_x64-linux && mkdir -p $PKG_DIR/minimap2-${MINIMAP2_VERSION}/bin && cp minimap2 k8  paftools.js $PKG_DIR/minimap2-${MINIMAP2_VERSION}/bin
cd $PKG_DIR && stow -v minimap2-${MINIMAP2_VERSION}

## trim-galore ##
# get
cd $SRC_DIR && wget https://github.com/FelixKrueger/TrimGalore/archive/refs/tags/${TRIMGALORE_VERSION}.tar.gz -O trimgalore-${TRIMGALORE_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/trimgalore-${TRIMGALORE_VERSION}.tar.gz && cd TrimGalore-${TRIMGALORE_VERSION}
mkdir -p $PKG_DIR/trimgalore-${TRIMGALORE_VERSION}/bin && cp trim_galore $PKG_DIR/trimgalore-${TRIMGALORE_VERSION}/bin
cd $PKG_DIR && stow -v trimgalore-${TRIMGALORE_VERSION}

## filtong ##
# get
cd $SRC_DIR && wget https://github.com/rrwick/Filtlong/archive/refs/tags/v${FILTLONG_VERSION}.tar.gz -O filtlong-${FILTLONG_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/filtlong-${FILTLONG_VERSION}.tar.gz && cd Filtlong-${FILTLONG_VERSION} && make -j $CPUS
# build
mkdir -p $PKG_DIR/filtlong-${FILTLONG_VERSION}/bin && cp bin/filtlong $PKG_DIR/filtlong-${FILTLONG_VERSION}/bin
cd $PKG_DIR && stow -v filtlong-${FILTLONG_VERSION}

## ncbi-blast ##
# get
cd $SRC_DIR && wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-${NCBI_BLAST_VERSION}-x64-linux.tar.gz
cd $PKG_DIR && tar -xzf $SRC_DIR/ncbi-blast-${NCBI_BLAST_VERSION}-x64-linux.tar.gz && cd ncbi-blast-${NCBI_BLAST_VERSION}
# fix docs
mv ChangeLog  LICENSE  README doc
cd doc && for file in *;do mv $file ncbi-blast-$file;done
cd $PKG_DIR && stow -v ncbi-blast-${NCBI_BLAST_VERSION}

## bbmap ##
# get
cd $SRC_DIR && wget https://downloads.sourceforge.net/project/bbmap/BBMap_${BBMAP_VERSION}.tar.gz -O bbmap-${BBMAP_VERSION}.tar.gz
mkdir -p $PKG_DIR/bbmap-${BBMAP_VERSION}/bin && cd $PKG_DIR/bbmap-${BBMAP_VERSION}
tar -xzf $SRC_DIR/bbmap-${BBMAP_VERSION}.tar.gz -C bin --strip-components 1
cd $PKG_DIR && stow -v bbmap-${BBMAP_VERSION}

## spades ##
# get
cd $SRC_DIR && wget https://github.com/ablab/spades/releases/download/v${SPADES_VERSION}/SPAdes-${SPADES_VERSION}-Linux.tar.gz
cd $PKG_DIR && mkdir spades-${SPADES_VERSION} && tar -xzf $SRC_DIR/SPAdes-${SPADES_VERSION}-Linux.tar.gz -C spades-${SPADES_VERSION} --strip-components 1
stow -v spades-${SPADES_VERSION}

## canu ##
# get
cd $SRC_DIR && wget https://github.com/marbl/canu/releases/download/v${CANU_VERSION}/canu-${CANU_VERSION}.Linux-amd64.tar.xz
cd $PKG_DIR && tar -xf $SRC_DIR/canu-${CANU_VERSION}.Linux-amd64.tar.xz && stow -v canu-2.1.1

## mashmap ##
# get
cd $SRC_DIR && wget https://github.com/marbl/MashMap/releases/download/v${MASHMAP_VERSION}/mashmap-Linux64-v${MASHMAP_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/mashmap-Linux64-v${MASHMAP_VERSION}.tar.gz
mkdir -p $PKG_DIR/mashmap-${MASHMAP_VERSION}/bin && cp $BLD_DIR/mashmap-Linux64-v2.0/mashmap $PKG_DIR/mashmap-${MASHMAP_VERSION}/bin
cd $PKG_DIR && stow -v mashmap-${MASHMAP_VERSION}

### Java Libraries ###

## pilon ##
# get
mkdir -p $PKG_DIR/pilon-${PILON_VERSION}
cd $PKG_DIR/pilon-${PILON_VERSION} && wget https://github.com/broadinstitute/pilon/releases/download/v${PILON_VERSION}/pilon-${PILON_VERSION}.jar
mv pilon-${PILON_VERSION}.jar pilon.jar
cd $PKG_DIR && stow -v pilon-${PILON_VERSION}

### Python Libraries ###

## sep ##
# get
cd $SRC_DIR && wget https://github.com/smirarab/sepp/archive/refs/tags/${SEPP_VERSION}.tar.gz -O sepp-${SEPP_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/sepp-${SEPP_VERSION}.tar.gz
# build
cd sepp-${SEPP_VERSION} && /usr/bin/python3 setup.py config && /usr/bin/python3 setup.py build -j $CPUS && /usr/bin/python3 setup.py install --prefix=$PKG_DIR/sepp-${SEPP_VERSION}
cd $PKG_DIR && rm sepp-${SEPP_VERSION}/bin/easy_install && stow -v sepp-${SEPP_VERSION}

## flye ##
# get
cd $SRC_DIR && wget https://github.com/fenderglass/Flye/archive/refs/tags/${FLYE_VERSION}.tar.gz -O flye-${FLYE_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/flye-${FLYE_VERSION}.tar.gz && cd Flye-${FLYE_VERSION}
# build
python3 setup.py build -j $CPUS && python3 setup.py install --prefix=$PKG_DIR/flye-${FLYE_VERSION}
cd $PKG_DIR && stow -v flye-${FLYE_VERSION}

## falcon ##
# get
#cd $SRC_DIR && wget https://github.com/PacificBiosciences/FALCON_unzip/archive/refs/tags/${FALCON_UNZIP_VERSION}.tar.gz -O falcon_unzip-${FALCON_UNZIP_VERSION}.tar.gz
#cd $BLD_DIR && tar -xzf $SRC_DIR/falcon_unzip-${FALCON_UNZIP_VERSION}.tar.gz
## build
#cd FALCON_unzip-${FALCON_UNZIP_VERSION} && python3 setup.py build && python3 setup.py install --prefix=$PKG_DIR/falcon_unzip-${FALCON_UNZIP_VERSION}
#cd $PKG_DIR && stow -v falcon_unzip-${FALCON_UNZIP_VERSION}

## busco ##
# get
cd $BLD_DIR && git clone https://gitlab.com/ezlab/busco.git && cd busco
# build
python3 setup.py build && python3 setup.py install --prefix=$PKG_DIR/busco
cd $PKG_DIR && stow -v busco

## buscomp ##
# get
cd $BLD_DIR && git clone https://github.com/slimsuite/buscomp.git && cd buscomp
# build
cd code && sed -i -e '1s%.*%#!/usr/bin/python2%' *.py
mkdir -p $PKG_DIR/buscomp/bin && cp *.py $PKG_DIR/buscomp/bin
cd $PKG_DIR && stow -v buscomp

## quast ##
# get
cd $SRC_DIR && wget https://github.com/ablab/quast/archive/refs/tags/quast_${QUAST_VERSION}.tar.gz
cd $BLD_DIR && tar -xzf $SRC_DIR/quast-${QUAST_VERSION}.tar.gz
# build
cd quast-quast_${QUAST_VERSION} && python3 setup.py build -j $CPUS
python3 setup.py install --prefix=$PKG_DIR/quast-${QUAST_VERSION}
cd $PKG_DIR && stow -v quast-${QUAST_VERSION}

### Git repo ###

## pyro ##
# get
#cd $BLD_DIR && git clone https://github.com/genomeassembler/pyro.git
cd $BLD_DIR && git clone https://github.com/dnbenso/pyro.git
cd pyro/scripts && chmod a+x *
mkdir -p $PKG_DIR/pyro_scripts/bin
cp -r $BLD_DIR/pyro/scripts/*.sh $BLD_DIR/pyro/scripts/*.py $BLD_DIR/pyro/scripts/*.pl $PKG_DIR/pyro_scripts/bin
cd $PKG_DIR && stow -v pyro_scripts

## genomescope ##
# get
cd $PKG_DIR && git clone https://github.com/schatzlab/genomescope.git

### CONDA ####

## miniconda ##
# get
cd $BLD_DIR && wget https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh
chmod a+x Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && ./Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -b -u -p /usr/local/stow/miniconda3-${MINICONDA_VERSION}
. /usr/local/stow/miniconda3-4.6.14/etc/profile.d/conda.sh
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
# Create the conda environments
conda create -y --name pb_assembly pb-assembly
conda create -y --name medaka medaka=1.2.0
conda create -y --name meraculous meraculous=2.2.6
conda create -y --name masurca masurca=3.4.2
# Add the masurca special version of flye
cd /usr/local/stow/miniconda3-4.6.14/envs/masurca
git clone https://github.com/alekseyzimin/Flye.git
cd Flye/lib/minimap2 && wget https://raw.githubusercontent.com/attractivechaos/klib/master/ketopt.h 
cd ../.. && make -j $CPUS

# Cleanup
#conda clean -a -y
#cd $BLD_DIR && rm -rf *
#cd $SRC_DIR && rm -f *

