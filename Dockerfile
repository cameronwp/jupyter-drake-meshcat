FROM robotlocomotion/drake:focal as drake

RUN apt-get update && apt-get upgrade -y

COPY requirements.txt .

