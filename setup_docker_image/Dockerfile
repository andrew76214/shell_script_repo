FROM ubuntu:24.04

ENV ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y wget bzip2 curl && \
    apt-get clean

# 下載並安裝 Miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
RUN /bin/bash /tmp/miniconda.sh -b -p /opt/miniconda3 && \
    rm /tmp/miniconda.sh && \
    echo "export PATH=/opt/miniconda3/bin:$PATH" > /etc/profile.d/miniconda.sh

ENV PATH="/opt/miniconda3/bin:$PATH"

# 初始化 Conda
RUN /opt/miniconda3/bin/conda init bash

# 指定工作目錄
WORKDIR /app

# 設定默認環境為 base
ENV CONDA_DEFAULT_ENV=base
ENV PATH="/opt/miniconda3/bin:$PATH"

CMD ["bash"]