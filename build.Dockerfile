FROM nikolaik/python-nodejs:python3.10-nodejs16-bullseye

RUN apt-get update \
    && apt-get install -y --no-install-recommends sudo \
    && apt-get install -y axel --no-install-recommends \
    && echo pn ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/pn \
    && chmod 0440 /etc/sudoers.d/pn \
    && chown -R 1000:1000 /home/pn/

USER pn

COPY requirements.txt /requirements.txt
COPY download_compilers.py /download_compilers.py
COPY entrypoint.sh /home/pn/entrypoint.sh

ENV VIRTUAL_ENV=/home/pn/.local/pipx/venvs
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN sudo npm install -g ganache-cli@6.12.2 && \
pip install --force --no-cache-dir --upgrade pip setuptools && \
pip install --no-cache-dir pipx && \
python -m pipx ensurepath --force && \
/home/pn/.local/bin/pipx install  "eth-brownie==1.19.2" --pip-args="cython<3.0 pyyaml>=5.4.1,<6 --no-build-isolation" && \
python3 -m venv $VIRTUAL_ENV

RUN pip install --no-cache-dir wheel && \
 pip install --no-cache-dir "cython<3.0" "pyyaml>=5.4.1,<6" --no-build-isolation && \
 pip install --no-cache-dir -r requirements.txt && python download_compilers.py && \
 brownie && rm ~/.brownie/deployments.db && \
 rm -rf ~/.local/lib && \
 rm -rf ~/.cache && \
 npm cache clean --force && \
 sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "/home/pn/entrypoint.sh" ]
