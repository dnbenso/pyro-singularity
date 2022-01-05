Singularity container recipe for Pyro
====

Dependencies
------------ 

- Singularity v 2.5 or newer

Quick Installation
------------------ 

1. Clone the repository
   ```
   git clone https://github.com/dnbenso/pyro-singularity.git
   ```

2. Decide on whether you want to create an image for use with pyro or create a
   sandbox.
    * Sandbox - As root execute the following singularity commands. First
      create an Ubunut image and then interactively install the applications
      using the bash script pyro_def.bash.
        ```
        singularity build --sandbox pyro docker://ubuntu:latest
        singularity shell -B ~/pyro-singularity:/mnt --writable pyro
        /mnt/pyro_def.bash
        ```
    * Image - Create the image using the definition file and place in the
      singularity directory under the root of the cloned pyro repo.
        ```
        singularity build pyro.simg pyro.def
        ```
Getting Started
---------------

If your singularity image is on a slow filesystem copy it to a more appropriate
place.

To list the software and miniconda environments available:
  ```
  singularity run pyro.simg ls /usr/local/stow
  singularity run pyro.simg ls /usr/local/stow/miniconda3-4.6.14/envs
  ```
Where pyro.simg above is the singularity image (note: you may need to load the
singularity module on a HPC system first before running the above).

To run a program:
  ```
  singularity run singularity/pyro.simg seqtk
  ```

To run a miniconda env you'll need to create a bash script file and execute it
with singularity.
  ```
  cat <<EOF>masurca.sh
  #!/bin/bash
  . /usr/local/stow/miniconda3-4.6.14/etc/profile.d/conda.sh
  conda activate masurca
  masurca -h
  EOF
  singularity run pyro.simg bash masurca.sh
  ```
  
Or to run a more complicated example using a script file with a reference and
paired end reads:
  ```
  cat <<EOF>bwa.sh
  #!/bin/bash
  bwa index reference.fasta
  bwa mem -t 64 reference.fasta  sample_R1.fastqsanger.gz  sample_R2.fastqsanger.gz | \
      samtools sort -o sample.bam
  EOF
  singularity run pyro.simg bash bwa.sh
  ```
