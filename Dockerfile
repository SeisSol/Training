FROM debian:stable-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget ca-certificates bzip2 gcc g++ gfortran make cmake libopenblas-dev libopenmpi-dev git libgomp1 libopenmpi3 libopenblas-base \
    && rm -rf /var/lib/apt/lists/

RUN cd /tmp \
    && wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.21/src/hdf5-1.8.21.tar.bz2 \
    && tar -xvf hdf5-1.8.21.tar.bz2 \
    && cd hdf5-1.8.21 \
    && CPPFLAGS="-fPIC" CC=mpicc FC=mpif90 ./configure --enable-parallel --with-zlib --disable-shared --enable-fortran --prefix /usr/local \
    && make -j4 && make install \
    && cd /tmp && rm -r hdf5-1.8.21

RUN cd /tmp \
    && git clone https://github.com/SCOREC/core.git \
    && cd core \
    && mkdir build && cd build \
    && cmake .. -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_BUILD_TYPE=Release -DSCOREC_CXX_FLAGS="-Wno-error=array-bounds" \
    && make -j4 && make install \
    && cd /tmp && rm -r core

RUN cd /tmp \
    && git clone https://github.com/SeisSol/PUMGen.git \
    && cd PUMGen \
    && git checkout xml \
    && git submodule update --init \
    && mkdir build && cd build \
    && cmake .. -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_BUILD_TYPE=Release \
    && make -j4 && make install \
    && cd /tmp && rm -r PUMGen

RUN cd /tmp \
    && wget https://gmsh.info/src/gmsh-4.6.0-source.tgz \
    && tar -xvf gmsh-4.6.0-source.tgz \
    && cd gmsh-4.6.0-source && mkdir build && cd build \
    && cmake .. && make -j4 && make install \
    && cd /tmp && rm -r gmsh-4.6.0-source

WORKDIR /home
