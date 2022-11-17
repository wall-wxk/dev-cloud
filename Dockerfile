FROM ubuntu:18.04

# ssh开放端口
ARG SSH_PORT=9999
# ROOT用户初始化密码
ARG ROOT_PASSWD=hello#fe1024
# 架构
ARG ARCH=x86
#设置系统语言环境
ENV LANG=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
# 设置tzdata的前端类型为非交互式（通过环境变量）
ENV DEBIAN_FRONTEND=noninteractive

MAINTAINER leon<582104384@qq.com>

LABEL org.opencontainers.image.authors="leon"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.created="2022-11-18"

# 离线安装nvm
ADD nvm-0.39.2.tar.gz /root/.nvm

# 更新apt镜像源为淘宝源
COPY sources.${ARCH}.list /etc/apt/sources.list

# 配置nvm
COPY nvm.bashrc /build/nvm.bashrc

# 配置ssh开机自启动
COPY ssh.bashrc /build/ssh.bashrc
COPY start_ssh.sh /root/start_ssh.sh

# bash的方式执行命令
SHELL ["/bin/bash", "-ic"]

# 安装相关软件
## 解压安装nvm
RUN mv /root/.nvm/nvm-0.39.2/* /root/.nvm \
	#　更新apt
  && rm -rf /var/lib/apt/lists/* \
  && apt clean \
  && apt-get -y update \   
  # 安装vim
  && apt-get install -y vim \ 
  # 安装ssh
  && apt-get install -y openssh-server \
  && sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && sed -i 's/^#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config \
  && cat /build/ssh.bashrc >> /root/.bashrc \
  && rm -rf /build/ssh.bashrc \
  && chmod +x /root/start_ssh.sh \
  && /etc/init.d/ssh start \
  # 安装curl，nvm依赖curl
  && apt-get install -y  curl \ 
  # 安装git
  && apt-get install -y git \
  # 配置nvm
  && cat /build/nvm.bashrc >> /root/.bashrc \
  && rm -rf /build/nvm.bashrc \
  && source ~/.bashrc \
  # 使用nvm安装默认node版本
  && nvm install 14 \
  && npm config set registry https://registry.npmmirror.com \
  && npm config set user 0 \
  && npm config set unsafe-perm true \
  && npm install -g nrm \
  # 安装yarn
  && corepack enable \
  && corepack prepare yarn@3.2.4 --activate \
  # 安装中文支持包
  && apt-get install -y language-pack-zh-hans \
  # 安装时区数据库
  && apt-get install -y locales tzdata \
  #
  && locale-gen zh_CN.UTF-8 \
  && update-locale LANG=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 \
  # 建立到期望的时区的链接
  && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  # 重新配置tzdata软件包，使得时区设置生效
  && dpkg-reconfigure --frontend noninteractive tzdata \
  # 最后一步才能修改root密码，不然会影响source .bashrc
  && echo "root:${ROOT_PASSWD}" | chpasswd

# 定义匿名卷
VOLUME /mnt

#　确定工作目录
WORKDIR /mnt 

# ssh接口配置
EXPOSE ${SSH_PORT}:22

CMD ["/bin/bash"]