FROM nikolaik/python-nodejs:python3.9-nodejs16

RUN apt-get update \
    && apt-get install -y sudo
RUN npm install -g ganache-cli@beta
RUN pip install --no-cache-dir --force --upgrade pip setuptools
RUN pip install --user pipx
RUN /root/.local/bin/pipx install eth-brownie==1.17
RUN python -m pipx ensurepath --force
RUN pip install requests
COPY download_compilers.py /download_compilers.py
RUN python download_compilers.py
COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

RUN groupadd --gid 1001 robowoofy \
    && useradd --uid 1001 --gid 1001 -m robowoofy \
    && echo robowoofy ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/robowoofy \
    && chmod 0440 /etc/sudoers.d/robowoofy

RUN chown -R 1001:1001 /home/robowoofy/

USER robowoofy
COPY entrypoint.sh /home/robowoofy/entrypoint.sh
ENTRYPOINT [ "/home/robowoofy/entrypoint.sh" ]