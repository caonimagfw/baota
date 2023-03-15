FROM centos:7
MAINTAINER pch18.cn

#设置entrypoint和letsencrypt映射到www文件夹下持久化
COPY entrypoint.sh /entrypoint.sh
COPY set_default.py /set_default.py

RUN mkdir -p /www/letsencrypt \
    && ln -s /www/letsencrypt /etc/letsencrypt \
    && rm -f /etc/init.d \
    && mkdir /www/init.d \
    && ln -s /www/init.d /etc/init.d \
    && chmod +x /entrypoint.sh \
    && mkdir /www/wwwroot
    
#更新系统 安装依赖 安装宝塔面板
RUN cd /home \
    && yum -y install wget openssh-server which curl iproute \
    && echo 'Port 63322' > /etc/ssh/sshd_config \
    && wget https://github.com/caonimagfw/btpanel-v7.7.0/raw/main/install/install_panel.sh \
    && bash install_panel.sh \
    && python /set_default.py \
    && echo '["linuxsys", "webssh"]' > /www/server/panel/config/index.json \
    && yum clean all

WORKDIR /www/wwwroot
CMD /entrypoint.sh
EXPOSE 8888 888 21 20 443 80

HEALTHCHECK --interval=60s --timeout=5s CMD curl -fs http://localhost:8888/ && curl -fs http://localhost/ || exit 1 
