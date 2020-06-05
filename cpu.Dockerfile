FROM ubuntu:18.04

SHELL ["/bin/bash", "-c"]

RUN apt-get update

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    git \
    sudo \
    rsync \
    wget \
    software-properties-common \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libopenmpi-dev


RUN update-ca-certificates

ENV HOME /home
WORKDIR ${HOME}/

# Download Miniconda
# https://docs.anaconda.com/anaconda/install/silent-mode/
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    chmod +x ~/miniconda.sh
RUN bash ~/miniconda.sh -b -p $HOME/miniconda
RUN rm miniconda.sh

ENV PATH ${HOME}/miniconda/bin:$PATH
ENV CONDA_PATH ${HOME}/miniconda
ENV LD_LIBRARY_PATH ${CONDA_PATH}/lib:${LD_LIBRARY_PATH}

RUN eval "$(conda shell.bash hook)"

RUN mkdir p /code
# Results directory
RUN mkdir -p /results

WORKDIR /code
ADD . .
RUN bash ./scripts/create_conda_env.sh cpu
RUN bash ./scripts/add_dropbox.sh


RUN chmod 777 ./scripts/execute_in_conda.sh
RUN find ${CONDA_PATH} -type d -exec chmod 777 {} \;

VOLUME ["/results"]

# Run experiments
ENTRYPOINT /code/scripts/execute_in_conda.sh ${repeats} ${scenario} ${experiment} ${dboxtoken} ${dboxdir} cpu