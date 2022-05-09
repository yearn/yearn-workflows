FROM nikolaik/python-nodejs:python3.9-nodejs16

RUN apt-get update \
    && apt-get install -y sudo


RUN useradd --uid 1001 --gid 1000 -m robowoofy \
    && echo robowoofy ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/robowoofy \
    && chmod 0440 /etc/sudoers.d/robowoofy

RUN chown -R 1001:1000 /home/robowoofy/
USER robowoofy

RUN sudo npm install -g ganache-cli@beta
RUN pip install --no-cache-dir --force --upgrade pip setuptools
RUN pip install --user pipx
RUN /home/robowoofy/.local/bin/pipx install eth-brownie==1.17
RUN python -m pipx ensurepath --force
RUN pip install requests
COPY download_compilers.py /download_compilers.py
RUN python download_compilers.py
COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
RUN export PATH=/home/robowoofy/.local/bin:${PATH}

COPY entrypoint.sh /home/robowoofy/entrypoint.sh
ENTRYPOINT [ "/home/robowoofy/entrypoint.sh" ]