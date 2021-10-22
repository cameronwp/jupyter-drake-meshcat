FROM robotlocomotion/drake:focal as drake

RUN apt-get update && apt-get upgrade -y \
  && apt install -y build-essential nginx python3-dev

# https://u.group/thinking/how-to-put-jupyter-notebooks-in-a-dockerfile/
# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

WORKDIR /home/ubuntu/jupyter
COPY requirements.txt .
RUN pip install -r requirements.txt

# default port for jupyter
EXPOSE 8888

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["jupyter", "lab", "--allow-root", "--no-browser", "--ip=0.0.0.0"]
