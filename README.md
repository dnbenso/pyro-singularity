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
