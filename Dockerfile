FROM debian:bullseye-slim

RUN apt-get update \
    && apt-get install -y \
    wget \
    ca-certificates \
    bzip2 \
    gcc \
    g++ \
    gfortran \
    make \
    cmake \
    libnuma-dev \
    libnuma1 \
    libopenblas-dev \
    libopenmpi-dev \
    libocct-data-exchange-7.5 \
    libocct-data-exchange-dev \
    libocct-modeling-algorithms-7.5 \
    libocct-modeling-algorithms-dev \
    libocct-modeling-data-7.5 \
    libocct-modeling-data-dev \
    libocct-foundation-7.5 \
    libocct-foundation-dev \
    libtbb2 \
    zlib1g-dev \
    pkg-config \
    git \
    python3 \
    python3-numpy \
    libgomp1 \
    libopenmpi3 \
    libopenblas-base \
    libreadline-dev \
    libyaml-cpp-dev \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/tools

WORKDIR /tmp
RUN wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.7/src/hdf5-1.10.7.tar.bz2 \
    && tar -xvf hdf5-1.10.7.tar.bz2 \
    && cd hdf5-1.10.7 \
    && CFLAGS="-fPIC" CC=mpicc FC=mpif90 ./configure --enable-parallel --with-zlib --disable-shared --enable-fortran --prefix /home/tools \
    && make -j$(nproc) && make install

RUN wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-c-4.7.4.tar.gz \
    && tar -xvf netcdf-c-4.7.4.tar.gz \
    && cd netcdf-c-4.7.4 \
    && CFLAGS="-fPIC" CC=/home/tools/bin/h5pcc ./configure --enable-shared=no --prefix=/home/tools --disable-dap \
    && make -j$(nproc) && make install

# You need to have a private copy of parmetis-4.0.3.tar.gz
COPY ./parmetis-4.0.3.tar.gz /tmp/parmetis-4.0.3.tar.gz
RUN tar -xvf parmetis-4.0.3.tar.gz \
    && cd parmetis-4.0.3 \
    && sed -i 's/IDXTYPEWIDTH 32/IDXTYPEWIDTH 64/g' ./metis/include/metis.h \
    && CC=mpicc CXX=mpicxx make config prefix=/home/tools \
    && make -j$(nproc) && make install \
    && cp build/Linux-x86_64/libmetis/libmetis.a /home/tools/lib \
    && cp metis/include/metis.h /home/tools/include

RUN git clone https://github.com/TUM-I5/ASAGI.git \
    && cd ASAGI \
    && git submodule update --init \
    && mkdir build && cd build \
    && CC=mpicc CXX=mpicxx cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools -DSHARED_LIB=off -DSTATIC_LIB=on -DNONUMA=on \
    && make -j$(nproc) && make install

RUN git clone https://github.com/uphoffc/ImpalaJIT.git \
    && cd ImpalaJIT \
    && mkdir build && cd build \
    && cmake .. && make -j $(nproc) install 

RUN wget https://www.lua.org/ftp/lua-5.3.6.tar.gz \
    && tar -xzvf lua-5.3.6.tar.gz \
    && cd lua-5.3.6 && make linux CC=mpicc && make local \
    && cp -r install/* /home/tools && cd ..

RUN git clone https://github.com/SeisSol/easi \
    && cd easi \
    && mkdir build && cd build \
    && CC=mpicc CXX=mpicxx cmake .. -DEASICUBE=OFF -DLUA=ON -DCMAKE_PREFIX_PATH=/home/tools -DCMAKE_INSTALL_PREFIX=/home/tools -DASAGI=ON -DIMPALAJIT=ON .. \
    && make -j$(nproc) && make install

RUN git clone https://github.com/hfp/libxsmm.git \
    && cd libxsmm \
    && git checkout 1.16.1 \
    && make -j$(nproc) generator \
    && cp bin/libxsmm_gemm_generator /home/tools/bin

RUN git clone https://github.com/OSGeo/PROJ.git \
    && cd PROJ && git checkout 4.9.3 \
    && mkdir build && cd build \
    && CC=mpicc CXX=mpicxx cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools \
    && make -j$(nproc) && make install

RUN wget --progress=bar:force:noscroll https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz \
    && tar -xf eigen-3.4.0.tar.gz \
    && cd eigen-3.4.0 && mkdir build && cd build && cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools \
    && make -j$(nproc) install 

RUN git clone https://github.com/SeisSol/SeisSol.git \
    && cd SeisSol \
    && git submodule update --init \
    && mkdir build_hsw && cd build_hsw \
    && export PATH=$PATH:/home/tools/bin \
    && CC=mpicc CXX=mpicxx cmake .. -DCMAKE_PREFIX_PATH=/home/tools -DGEMM_TOOLS_LIST=LIBXSMM -DHOST_ARCH=hsw -DASAGI=on -DNETCDF=on -DORDER=4 -DCMAKE_Fortran_FLAGS="-ffast-math -funsafe-math-optimizations" \
    && make -j$(nproc) \
    && cmake .. -DEQUATIONS=viscoelastic2 -DNUMBER_OF_MECHANISMS=3 \
    && make -j$(nproc) \
    && cp SeisSol_* /home/tools/bin

RUN cd SeisSol/preprocessing/science/rconv \
    && mkdir build && cd build \
    && echo "find_package(HDF5 REQUIRED COMPONENTS C HL)" >> ../CMakeLists.txt \
    && echo "target_link_libraries(SeisSol-rconv PUBLIC \${HDF5_C_HL_LIBRARIES} \${HDF5_C_LIBRARIES})" >> ../CMakeLists.txt \
    && CC=mpicc CXX=mpicxx cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools -DCMAKE_PREFIX_PATH=/home/tools \
    && make -j$(nproc) && cp rconv /home/tools/bin/

RUN git clone https://github.com/SCOREC/core.git \
    && cd core \
    && git submodule update --init \
    && mkdir build && cd build \
    && cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_BUILD_TYPE=Release -DSCOREC_CXX_FLAGS="-Wno-error=array-bounds" \
    && make -j$(nproc) && make install

RUN git clone https://github.com/SeisSol/PUMGen.git \
    && cd PUMGen \
    && git submodule update --init \
    && mkdir build && cd build \
    && cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc) && make install

RUN wget https://gmsh.info/src/gmsh-4.8.4-source.tgz \
    && tar -xvf gmsh-4.8.4-source.tgz \
    && cd gmsh-4.8.4-source && mkdir build && cd build \
    && cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools -DCMAKE_BUILD_TYPE=Release -DENABLE_OCC=ON -DENABLE_BUILD_LIB=ON -DENABLE_BUILD_SHARED=ON \
    && make -j$(nproc) && make install

FROM debian:bullseye-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libgomp1 \
    libopenmpi3 \
    openmpi-bin \
    libnuma1 \
    libopenblas-base \
    libocct-data-exchange-7.5 \
    libocct-modeling-algorithms-7.5 \
    libocct-modeling-data-7.5 \
    libocct-foundation-7.5 \
    libtbb2 \
    libyaml-cpp-dev \
    python3 \
    python3-pip \
    python3-setuptools \
    zlib1g \
    libxrender1 \
    xvfb \
    tini \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home
COPY --from=0 /home/tools tools
COPY requirements.txt .
RUN python3 -m pip install --upgrade pip && pip3 install -r requirements.txt

ENV PATH=/home/tools/bin:$PATH
ENV OMP_PLACES="cores"
ENV OMP_PROC_BIND="spread"
ENV PYTHONPATH="${PYTHONPATH}:/home/tools/lib"
COPY entrypoint.sh /entrypoint.sh

WORKDIR /home/training
COPY tpv13/ tpv13/
COPY sulawesi/ sulawesi/
COPY northridge/ northridge/
COPY kaikoura/ kaikoura/

VOLUME ["/shared"]
WORKDIR /shared
ENTRYPOINT ["tini", "-g", "/entrypoint.sh", "--"]
