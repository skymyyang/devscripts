FROM python:3.6.8-slim-stretch
ENV TZ='Asia/Shanghai'
RUN set -x \
    && echo "deb http://mirrors.aliyun.com/debian/ stretch main non-free contrib" > /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/debian/ stretch-proposed-updates main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/debian/ stretch main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/debian/ stretch-proposed-updates main non-free contrib" >> /etc/apt/sources.list \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && apt update \
    && apt install -y g++ tzdata \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ~/.pip \
    && echo '[global]' > ~/.pip/pip.conf \
    && echo 'index-url = https://pypi.tuna.tsinghua.edu.cn/simple' >> ~/.pip/pip.conf

WORKDIR /app
COPY . /app
VOLUME [ "/app/pdf" ]
RUN pip install -r plist.txt
EXPOSE 5000
CMD ["python","app.py","-h 0.0.0.0"]