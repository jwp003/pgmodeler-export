FROM alpine

# Build dependencies
RUN apk add curl qt5-qtbase-dev g++ libxml2-dev postgresql-dev qt5-qtsvg-dev \
	make libexecinfo-dev ed

# Fetch source 0.9.2-beta
RUN curl -L https://github.com/pgmodeler/pgmodeler/archive/v0.9.2-beta.tar.gz \
	| tar xzf -

# Build and install
WORKDIR /pgmodeler-0.9.2-beta
RUN mkdir -p /opt/pgmodeler
RUN qmake-qt5 -r CONFIG+=release pgmodeler.pro PREFIX=/opt/pgmodeler
# Patch Makefile to link execinfo
RUN printf '41s/.*/& -lexecinfo/\nwq\n' | ed main/Makefile
RUN make
RUN make install


FROM alpine

RUN apk add xvfb qt5-qtbase-x11 qt5-qtsvg libpq libxml2 mesa-dri-swrast

COPY --from=0 /opt/pgmodeler /opt/pgmodeler
RUN ln -s /opt/pgmodeler/bin/pgmodeler-cli /bin/

# Work-around for bug complaining about missing pattern-highlight.conf
RUN mkdir -p /root/.config/pgmodeler
RUN cp /opt/pgmodeler/share/pgmodeler/conf/pattern-highlight.conf /root/.config/pgmodeler/

RUN mkdir -p /tmp/pgmodeler
ENV XDG_RUNTIME_DIR /tmp/pgmodeler

WORKDIR /
COPY ./xvfb-run /bin/
COPY ./pgmodeler-export /bin/
ENTRYPOINT ["xvfb-run", "--"]
CMD pgmodeler-export

