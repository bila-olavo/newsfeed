FROM library/python:3.6.0-alpine

COPY front-end/public/serve.py /serve.py

COPY build/static.tgz /static.tgz

RUN tar -xf  static.tgz

CMD ["python", "/serve.py"]