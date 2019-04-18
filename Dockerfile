FROM ubuntu:18.04

# Base level OS setup, gets latest code for Ubuntu 18.04
RUN apt-get update
RUN apt-get -y dist-upgrade

# Installs Python 3, Pip, and some very common libraries for Python. Install only what is needed on all or almost all algorithms
RUN apt-get -y install python3 python3-pip
RUN pip3 install --upgrade pip pandas numpy flask cherrypy

# The prediction container will have to listen on port 8080 when running as SageMaker endpoint
EXPOSE 8080/tcp

# all code will run from here
WORKDIR /opt/app

# DO NOT EDIT ABOVE THIS LINE ----------------------------------------------------------------------------

# These are libraries that are specific to example algorithm in this template, so its within the User configuration
RUN pip3 install --upgrade tensorflow

# DO NOT EDIT BELOW THIS LINE ----------------------------------------------------------------------------

# Copy all code up to the working directory
COPY main.py /opt/app
COPY algorithm.py /opt/app
COPY lib /opt/app/lib

# This is a template file that handles
ENTRYPOINT ["python3", "main.py"]
