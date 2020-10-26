FROM python:3

# copy current folder to /app inside of container
RUN mkdir /app
COPY . /app

WORKDIR /app
ADD requirements.txt /app

# installing dependencies
RUN pip install -r /app/requirements.txt

# running app.py code
CMD ["./app/wait-for-it.sh", "postgresdb:5432", "--", "python", "/app/app.py"]
