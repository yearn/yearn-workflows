FROM nikolaik/python-nodejs:python3.9-nodejs22

# Install the security-fixed Node release without changing the Python toolchain.
ARG NODE_VERSION=22.23.5
RUN set -eux; \
    case "$(uname -m)" in \
      x86_64) node_arch=x64; node_sha=cdeb8670a0c81f51b4dc4ac61919f9b1ad917b304bf8221eb939570663d240f8 ;; \
      aarch64) node_arch=arm64; node_sha=2babb9eb5264860d540849f4b064a6fbdebcdc323657d9d382ce23d313fd5e09 ;; \
      *) echo "Unsupported architecture" >&2; exit 1 ;; \
    esac; \
    curl -fsSLo /tmp/node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${node_arch}.tar.xz"; \
    echo "${node_sha}  /tmp/node.tar.xz" | sha256sum -c -; \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 --no-same-owner; \
    rm /tmp/node.tar.xz; \
    test "$(node --version)" = "v${NODE_VERSION}"

RUN npm install -g ganache-cli@beta

RUN pip install --no-cache-dir --force --upgrade pip setuptools
RUN pip install --user pipx
RUN /root/.local/bin/pipx install eth-brownie==1.17
COPY security_overrides.sh /security_overrides.sh
RUN /security_overrides.sh /root/.local/pipx/venvs/eth-brownie/bin/python
RUN python -m pipx ensurepath --force

RUN pip install requests
COPY download_compilers.py /download_compilers.py
RUN python download_compilers.py

COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
RUN /security_overrides.sh python3

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]