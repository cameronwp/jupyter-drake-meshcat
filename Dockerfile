FROM russtedrake/manipulation:latest as manipulation
FROM robotlocomotion/drake:focal as drake

RUN apt-get update && apt-get upgrade -y && apt install -y \
    build-essential \
    nginx \
    python3-dev \
    python3-venv \
    xvfb

# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

RUN mkdir -p /opt/manipulation
COPY --from=manipulation /opt/manipulation/manipulation/ /usr/local/lib/python3.8/dist-packages/manipulation

ARG UNAME=user
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o $UNAME && \
  mkdir -p /usr/local/src/jupyter && \
  chown --recursive $UNAME:$UNAME /usr/local/src/jupyter
USER $UNAME

WORKDIR /usr/local/src/jupyter
COPY requirements.txt .
RUN python -m venv .venv
RUN .venv/bin/pip install -r requirements.txt

USER root
RUN chown --recursive $UNAME:$UNAME /usr/local/src/jupyter
USER $UNAME

# default port for jupyter
EXPOSE 8888
# default port for meshcat
EXPOSE 7000

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD [".venv/bin/jupyter", "lab", "--no-browser", "--ip=0.0.0.0"]
