# set base image (host OS)
FROM python:alpine

# set the working directory in the container
WORKDIR /code

# copy the dependencies file to the working directory
COPY requirements.txt .

# install dependencies
RUN pip install -r requirements.txt

ENV FLASK_ENV development
ENV ROOMS_PATH='rooms'
ENV USERS_PATH='users.csv'

# copy the content of the local src directory to the working directory
COPY src/ .

# command to run on container start
CMD [ "python", "./chatApp.py" ]
