# docker build -t ekambaram/flask-demo .
FROM python:3

ENV DB_HOST=db   
ENV DB_PORT=5432
ENV DB_USER=postgres
ENV DB_PASSWORD=postgres
ENV DB_NAME=sampledb
ENV DB_CP_MIN_CONN=1
ENV DB_CP_MAX_CONN=10


# copy current folder to /app inside of container
RUN mkdir /app
COPY . /app

WORKDIR /app
ADD requirements.txt /app

# installing dependencies
RUN pip install -r /app/requirements.txt
RUN chmod +x /app/wait-for-it.sh

# running app.py code
CMD ["python", "/app/app.py"]
