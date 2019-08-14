FROM node:10.13.0

RUN apt-get update && apt-get -qq install -y \
      bash \
      curl \
      build-essential \
      libproj-dev \
      sqlite3 \
      libsqlite3-dev \
      ca-certificates \
      git-core \
      postgresql-client \
      zip \
      unzip \
      locales \
      --no-install-recommends \
      && rm -rf /var/lib/apt/lists/*

# Set en_US.UTF-8 locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV SRC_DIR /usr/src/
RUN mkdir -p $SRC_DIR

# Get and build proj6
RUN curl -L https://download.osgeo.org/proj/proj-6.1.1.tar.gz -o /usr/src/proj-6.1.1.tar.gz
RUN cd /usr/src && tar -xvzf proj-6.1.1.tar.gz
WORKDIR /usr/src/proj-6.1.1
RUN ./configure --prefix=/opt/proj
RUN curl -L https://download.osgeo.org/proj/proj-datumgrid-1.8.zip -o /usr/src/proj-6.1.1/proj-datumgrid-1.7.zip
RUN unzip -o proj-datumgrid-1.7.zip -d data/
RUN make
RUN make install
RUN make check

# Get and build GDAL 3.0
RUN cd /usr/src
RUN curl -L http://download.osgeo.org/gdal/3.0.0/gdal-3.0.0.tar.gz -o /usr/src/gdal-3.0.0.tar.gz
RUN cd /usr/src && tar -xvzf gdal-3.0.0.tar.gz
WORKDIR /usr/src/gdal-3.0.0
RUN ./configure --prefix=/opt/gdal --with-proj=/opt/proj
RUN make
RUN make install
ENV GDAL=/opt/gdal/bin
ENV GDAL_DATA=/opt/gdal/share/gdal
ENV PATH "$PATH:/opt/gdal/bin"
ENV LD_LIBRARY "$LD_LIBRARY:/opt/gdal/lib"
