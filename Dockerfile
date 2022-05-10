FROM nikolaik/python-nodejs:python3.9-nodejs16

RUN apt-get update \
    && apt-get install -y sudo

RUN echo pn ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/pn \
    && chmod 0440 /etc/sudoers.d/pn

RUN chown -R 1000:1000 /home/pn/
USER pn

RUN sudo npm install -g ganache-cli@beta
RUN pip install --force --upgrade pip setuptools
RUN pip install pipx
RUN /home/pn/.local/bin/pipx install eth-brownie==1.17
RUN python -m pipx ensurepath --force
RUN pip install requests
COPY download_compilers.py /download_compilers.py
RUN python download_compilers.py
COPY requirements.txt /requirements.txt
RUN pip install -v -r requirements.txt
RUN export PATH=/home/pn/.local/bin:${PATH}

COPY entrypoint.sh /home/pn/entrypoint.sh
ENTRYPOINT [ "/home/pn/entrypoint.sh" ]