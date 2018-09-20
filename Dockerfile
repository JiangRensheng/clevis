
FROM ubuntu:18.04 as builder

LABEL maintainer="golden finger@deepsecs.com"

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /opt/clevis

COPY aliyun.list  /etc/apt/sources.list

RUN apt-get update -y && \
       	apt-get install -y dh-autoreconf pkg-config git-core build-essential systemd libssl-dev libkmod-dev asciidoc libaudit-dev \
	libcryptsetup-dev libudisks2-dev libglib2.0-dev libpwquality-tools&& \
	git clone --branch v10 https://github.com/latchset/clevis.git && \
	git clone --branch v9  https://github.com/latchset/luksmeta.git && \
	git clone --branch v2.10 https://github.com/akheron/jansson.git && \
	git clone --branch v10 https://github.com/latchset/jose.git && \
	git clone --branch 048 https://github.com/dracutdevs/dracut.git && \
	cd luksmeta && aclocal && autoreconf -fis && automake --add-missing && ./configure && make -j4 && make install && cd - && \
	cd jansson && aclocal && autoreconf -fis && automake --add-missing && ./configure && make -j4 && make install && cd - && \ 
	cd jose && libtoolize --automake --copy --force && aclocal && automake --add-missing && autoreconf -fis && \
	./configure && make -j4 && make install && cd - && \
	cd dracut/ && ./configure && make -j4 && make install && cd - && \
	cd clevis && aclocal && autoreconf -fis && automake --add-missing && ./configure && make -j4 && make install && cd - && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/ 


FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive

COPY aliyun.list  /etc/apt/sources.list.d/


RUN apt-get update -y && \
	apt-get install -yqq libssl1.0.0 libkmod2 libaudit1 && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/ 

COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY --from=builder /usr/local/lib/ /usr/local/lib/
COPY --from=builder /usr/local/libexec/ /usr/local/libexec/

ENTRYPOINT ["/usr/local/bin/clevis"]

