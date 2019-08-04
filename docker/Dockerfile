from devkitpro/devkitarm
run apt-get update \
 && apt-get install -y gcc g++ zip \
 && git clone https://github.com/Stary2001/ScenicRoute.git \
 && cd ScenicRoute \
 && make install \
 && cd .. \
 && git clone https://github.com/profi200/Project_CTR.git \
 && cd Project_CTR/makerom \
 && make \
 && install makerom /usr/bin \
 && cd ../.. \
 && git clone https://github.com/Steveice10/bannertool.git \
 && cd bannertool \
 && git submodule init \
 && git submodule update \
 && make install \
 && cd .. \
 && rm -r ScenicRoute Project_CTR bannertool \
 && apt-get autoremove -y gcc g++ \
 && rm -rf /var/lib/apt/lists/*

entrypoint [ "make", "-C", "/buttonswap3ds" ]
