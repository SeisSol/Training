# ==========================================
# STAGE 0: Build Environment (Native GCC 13)
# ==========================================
FROM ubuntu:24.04 AS builder

# Prevent interactive prompts during apt installations
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    cmake \
    g++ \
    gcc \
    gfortran \
    git \
    make \
    libnuma-dev \
    libopenblas-dev \
    libopenmpi-dev \
    libreadline-dev \
    libtbb-dev \
    libyaml-cpp-dev \
    libxml2-dev \
    openmpi-bin \
    pkg-config \
    python3 \
    python3-pip \
    python3-setuptools \
    wget \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Cleanly initialize custom build workspace directories
RUN mkdir -p /home/tools/bin /home/tools/lib /home/tools/include

WORKDIR /tmp

# Setup pristine search and linking paths for your custom toolchain
ENV PATH="/home/tools/bin:${PATH:-}"
ENV LD_LIBRARY_PATH="/home/tools/lib:${LD_LIBRARY_PATH:-}"
ENV PKG_CONFIG_PATH="/home/tools/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
ENV CMAKE_PREFIX_PATH="/home/tools:${CMAKE_PREFIX_PATH:-}"
ENV CPATH="/home/tools/include:${CPATH:-}"

# 1. Compile HDF5 (Parallel processing enabled over native OpenMPI)
RUN wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.12/hdf5-1.12.3/src/hdf5-1.12.3.tar.bz2 \
    && tar -xvf hdf5-1.12.3.tar.bz2 \
    && cd hdf5-1.12.3 \
    && CFLAGS="-fPIC -Wno-error=format-security" CPPFLAGS="-fPIC" CC=mpicc CXX=mpicxx ./configure \
       --enable-parallel \
       --prefix=/home/tools \
       --with-zlib \
       --disable-shared \
       --disable-dependency-tracking \
    && make -j$(nproc) && make install

# 2. Build libxsmm
RUN git clone --depth=1 --single-branch --branch 1.17 https://github.com/libxsmm/libxsmm \
    && cd libxsmm \
    && make -j$(nproc) generator \
    && cp bin/libxsmm_gemm_generator /home/tools/bin/

# 3. Build NetCDF
RUN wget --progress=bar:force:noscroll https://downloads.unidata.ucar.edu/netcdf-c/4.9.2/netcdf-c-4.9.2.tar.gz \
    && tar -xvf netcdf-c-4.9.2.tar.gz \
    && cd netcdf-c-4.9.2 \
    && CFLAGS="-fPIC" CC=h5pcc ./configure --enable-shared=no --prefix=/home/tools --disable-dap --disable-byterange \
    && make -j$(nproc) && make install

# 4. Build ParMETIS
RUN wget --progress=bar:force:noscroll https://deb.debian.org/debian/pool/non-free/p/parmetis/parmetis_4.0.3.orig.tar.gz \
    && tar -xvf parmetis_4.0.3.orig.tar.gz \
    && cd parmetis-4.0.3 \
    && sed -i 's/IDXTYPEWIDTH 32/IDXTYPEWIDTH 64/g' ./metis/include/metis.h \
    && CC=mpicc CXX=mpicxx make config prefix=/home/tools \
    && make -j$(nproc) && make install \
    && cp build/Linux-x86_64/libmetis/libmetis.a /home/tools/lib \
    && cp metis/include/metis.h /home/tools/include

# 5. Build Lua
RUN wget --progress=bar:force:noscroll https://www.lua.org/ftp/lua-5.3.6.tar.gz \
    && tar -xzvf lua-5.3.6.tar.gz \
    && cd lua-5.3.6 && make linux CC=mpicc && make local \
    && cp -r install/* /home/tools && cd ..

# 6. Build Eigen
RUN wget --progress=bar:force:noscroll https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz \
    && tar -xf eigen-3.4.0.tar.gz \
    && cd eigen-3.4.0 && mkdir build && cd build && cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools \
    && make -j$(nproc) install 

# 7. Build PROJ
RUN git clone --depth 1 --single-branch --branch 4.9.3 https://github.com/OSGeo/PROJ.git \
    && cd PROJ \
    && mkdir build && cd build \
    && CC=mpicc CXX=mpicxx cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools \
    && make -j$(nproc) && make install

# 8. Build ASAGI
RUN git clone --recursive https://github.com/TUM-I5/ASAGI.git \
    && cd ASAGI \
    && mkdir build && cd build \
    && CC=mpicc CXX=mpicxx cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools -DCMAKE_PREFIX_PATH=/home/tools -DSHARED_LIB=off -DSTATIC_LIB=on -DNONUMA=on \
    && make -j$(nproc) && make install

# 9. Build easi
RUN git clone https://github.com/SeisSol/easi \
    && cd easi \
    && mkdir build && cd build \
    && CC=mpicc CXX=mpicxx cmake .. -DEASICUBE=OFF -DLUA=ON -DCMAKE_PREFIX_PATH=/home/tools -DCMAKE_INSTALL_PREFIX=/home/tools -DASAGI=ON -DIMPALAJIT=OFF \
    && make -j$(nproc) && make install

# Install foundational generation packages alongside PSpaMM via pip3
RUN pip3 install --no-cache-dir --break-system-packages numpy \
    && pip3 install --no-cache-dir --break-system-packages git+https://github.com/SeisSol/PSpaMM.git

# 10. Build SeisSol 
RUN git clone --recursive https://github.com/SeisSol/SeisSol.git \
    && cd SeisSol \
    && mkdir build_hsw && cd build_hsw \
    &&CC=mpicc CXX=mpicxx cmake .. \
       -DCMAKE_PREFIX_PATH=/home/tools \
       -DCMAKE_LIBRARY_PATH=/home/tools/lib \
       -DCMAKE_INCLUDE_PATH=/home/tools/include \
       -DGEMM_TOOLS_LIST=auto \
       -DHOST_ARCH=hsw -DASAGI=on -DNETCDF=on -DORDER=6 -DEQUATIONS=elastic \
    && make -j$(nproc) \
    && cp SeisSol_* /home/tools/bin

# 11. Build rconv
RUN cd SeisSol/preprocessing/science/rconv/ \
    && git checkout vikas/rconv-fix \
    && mkdir build && cd build \
    && echo "find_package(HDF5 REQUIRED COMPONENTS C HL)" >> ../CMakeLists.txt \
    && echo "target_link_libraries(SeisSol-rconv PUBLIC \${HDF5_C_HL_LIBRARIES} \${HDF5_C_LIBRARIES})" >> ../CMakeLists.txt \
    && CC=mpicc CXX=mpicxx cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools -DCMAKE_PREFIX_PATH=/home/tools \
    && make -j$(nproc) && cp rconv /home/tools/bin/

# 12. Build PUMGen
RUN git clone --recursive --branch v1.1.0 https://github.com/SeisSol/PUMGen.git \
    && cd PUMGen \
    && mkdir build && cd build \
    && cmake .. -DCMAKE_INSTALL_PREFIX=/home/tools -DCMAKE_PREFIX_PATH=/home/tools -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc) && make install


# ==========================================
# STAGE 1: Final Lightweight Runtime Image
# ==========================================
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    gmsh \
    libgomp1 \
    libnuma1 \
    libopenblas-dev \
    libopenmpi3 \
    libtbb12 \
    libxrender1 \
    libyaml-cpp0.8 \
    openmpi-bin \
    python3 \
    python3-pip \
    tini \
    xvfb \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Install modern Python plotting and visualization stack natively 
RUN pip3 install --no-cache-dir --break-system-packages \
    panel \
    ipyvtklink \
    vtk \
    pyvista \
    ipywidgets \
    scipy \
    pyproj \
    matplotlib \
    gmsh \
    sympy \
    pandas

WORKDIR /home
COPY --from=builder /home/tools tools

# Expose modern linking environments globally to runtime contexts
ENV PATH="/home/tools/bin:${PATH:-}"
ENV LD_LIBRARY_PATH="/home/tools/lib:${LD_LIBRARY_PATH:-}"
ENV PYTHONPATH="/home/tools/lib:${PYTHONPATH:-}"

ENV OMP_PLACES="cores"
ENV OMP_PROC_BIND="spread"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /home/training
COPY tpv13/ tpv13/
COPY sulawesi/ sulawesi/
COPY northridge/ northridge/
COPY kaikoura/ kaikoura/
RUN chmod -R 777 /home/training

VOLUME ["/shared"]
WORKDIR /shared
ENTRYPOINT ["tini", "-s", "-g", "/entrypoint.sh", "--"]
