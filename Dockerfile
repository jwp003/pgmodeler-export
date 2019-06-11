FROM alpine

# Build dependencies
RUN apk add curl qt5-qtbase-dev g++ libxml2-dev postgresql-dev qt5-qtsvg-dev \
	make libexecinfo-dev ed xvfb

# Fetch source 0.9.2-beta
RUN curl -L https://github.com/pgmodeler/pgmodeler/archive/v0.9.2-beta.tar.gz \
	| tar xzf -

# Build and install
WORKDIR /pgmodeler-0.9.2-beta
RUN qmake-qt5 -r CONFIG+=release pgmodeler.pro
# Patch Makefile to link execinfo
RUN printf '41s/.*/& -lexecinfo/\nwq\n' | ed main/Makefile
RUN make
RUN make install

# Work-around for bug complaining about missing pattern-highlight.conf
RUN mkdir -p /root/.config/pgmodeler
RUN cp ./conf/defaults/pattern-highlight.conf /root/.config/pgmodeler/

WORKDIR /
COPY ./xvfb-run /bin/
COPY ./pgmodeler-export /bin/
ENTRYPOINT ["xvfb-run", "--"]
CMD pgmodeler-export

