# set base image (host OS)
FROM python:3.8-slim AS reduce_docker_image

# set the working directory in the container
WORKDIR /code

# copy the dependencies file to the working directory
COPY requirements.txt .

# install dependencies
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r requirements.txt

FROM reduce_docker_image

# copy the content of the local src directory to the working directory
COPY --from=reduce_docker_image /code /code

ENV FLASK_ENV development
ENV ROOMS_PATH rooms/
ENV USERS_PATH users.csv

# command to run on container start
CMD [ "python", "./chatApp.py" ]