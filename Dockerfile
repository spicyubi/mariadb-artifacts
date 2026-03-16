FROM debian:stable-slim
# Use ARG for build-time and ENV for runtime
ARG build_type=standard
RUN echo 'export USER=$(whoami)' >> /etc/bash.bashrc

# Update sources list
RUN sed -i 's/^Types: deb$/Types: deb deb-src/g' /etc/apt/sources.list.d/debian.sources && apt-get update

# neovim requirements
WORKDIR /root/nvim/
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl ca-certificates git clangd ripgrep
RUN curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.appimage
RUN chmod u+x nvim-linux-x86_64.appimage && ./nvim-linux-x86_64.appimage --appimage-extract && ln -s /root/nvim/squashfs-root/usr/bin/nvim /usr/bin/nvim
WORKDIR /root/.config/
RUN ln -s /mnt/.config/nvim/ /root/.config/
# WORKDIR /root/codelldb/
# RUN curl -LO https://github.com/vadimcn/codelldb/releases/download/v1.12.1/codelldb-linux-x64.vsix && unzip codelldb-linux-x64.vsix
# RUN chmod u+x /root/codelldb/extension/adapter/codelldb
# ENV PATH="/root/codelldb/extension/adapter/:$PATH"

# MariaDB init Setup
WORKDIR /mnt/code
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get build-dep -y mariadb-server && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential libncurses5-dev gnutls-dev bison zlib1g-dev ccache ninja-build
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    time
COPY ./ ./
WORKDIR /app/build
COPY ./mariadb.cnf /root/mariadb.cnf
RUN mkdir /run/mariadb/ /var/lib/mariadb/
COPY ./startup.sh ./startup.sh
RUN chmod +x ./startup.sh
RUN ./startup.sh ${build_type} init
RUN rm -rf /mnt/code/ && ln -s /mnt/code /app/code && git config --global --add safe.directory "*"

# On container start
WORKDIR /app/build
ENV build_type=${build_type}
CMD ["sleep", "infinity"]
# CMD ./startup.sh ${build_type}
