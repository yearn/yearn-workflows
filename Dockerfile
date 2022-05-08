FROM nikolaik/python-nodejs:python3.9-nodejs16
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

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]