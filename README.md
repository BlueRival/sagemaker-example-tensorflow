# Template for SageMaker Algorithm Development v0.0.1

The purpose of this code base is to provide a template for developing custom machine learning algorithms suitable for 
deployment into Amazon SageMaker. The conventions used here are a combination of Docker and Python, all wired together 
with some custom Python libraries and Bash(On Linux/Mac)/Batch(On Windows) shell scripts. 

This will allow you to develop your algorithms in a way that your code will port directly to SageMaker for training and 
deployment as a trained end-point. Although the code getting started examples from SageMaker all show usage of Jupyter
Notebooks for building and deploying your algorithms, this pattern is NOT a manageable process. Using Jupyter Notebooks
is closer to editing production code live on servers than it is to a proper software engineering process.

The template in this project will help produce an engineering process which helps achieve the following goals:

* Algorithm code is checked in to a version control system and all changes are tracked there.
* Version control is used for code review and collaboration.
* Deployments of algorithms to production are done through a proper build server, such as Jenkins, and not directly by a 
developer from a development environment.
* The code written in development will port directly to production without issue.

# Software Dependencies

## On Linux/Mac

Install Docker community edition for your OS: https://www.docker.com/community-edition#/download
This will allow for development as the template runs your algorithm in a container on your computer that looks just like
the container SageMaker will use.

Install Postman to make it easier to test the webserver EndPoint for your trained algorithm: https://www.getpostman.com/apps

## On Windows

Install Docker for Windows (use stable version only):
https://store.docker.com/editions/community/docker-ce-desktop-windows
This will allow for development as the template runs your algorithm in a container on your computer that looks just like
the container SageMaker will use.

Install Postman to make it easier to test the webserver EndPoint for your trained algorithm: https://www.getpostman.com/apps

# Template Files and Directory Layout

There are  number of directories and files in this template. This is a complete list of all files and their purpose.

* bin: This directory contains all the shell (Bash for Linux/Mac and Batch for Windows) scripts that are used to ease 
development process. These commands allow the engineer to control their development environment without having to know
any Docker commands.
* lib: This directory is a placeholder directory. The template does not utilize it. However, if an engineer decides
their algorithm is too large to fit into the single algorithm.py file they should create all their sub-modules here.
* opt: SageMaker creates directories and other files rooted in the path /opt/ml within the containers run algorithms in
production. In development we wire up the same directories and files into this opt directory. In production SageMaker 
would actually wire them up to S3 storage buckets. Our scripts and Docker files have simulated that production 
environment. Read the comments in algorithm.py for details on the how to use this directory in development.
* .dockerignore: This file is a standard Docker file. When building Docker images all the files listed in this file are 
ignored. We omit these files because they are only used in development and are added into the Docker images by other
means.
* .env.example/.env.bat.example: These are the config files for your project environment. Each project has its own
project environment file which declares some config values for the shell scripts in the bin directory. Use the .env for 
Mac/Linux and the .env.bat file for Windows.  
* .gitignore: This file tells Git which files should NOT be included in code commits.
* algorithm.py: This is where the framework within this template hooks into the custom algorithm. Read the comments at
the top of this file for details on how to implement the file.
* Dockerfile: This is the configuration file to build the base Docker image. The base image is used directly in 
production and is modified slightly for development. There is a line in this file where Python dependencies can be 
managed.
* Dockerfile.develop: This is a special configuration that modifies the Dockerfile for development. Where as Dockerfile
is suitable for directly deploying to SageMaker, Dockerfile.develop is needed to simulate the SageMaker sidecars on the
engineer's computer.
* main.py: This is the root executable for the Python framework in this template. It handles the run commands issued by
SageMaker and routes the commands correctly to the methods exposed by the Python module defined by the engineer in 
algorithm.py.
* README.md: Is this file. 

# Usage

Full software development cycle is possible with this template. The only files which must be modified are algorithm.py,
.env (Linux/Mac)/.env.bat (Windows), and Dockerfile. Although, for more complex algorithms it is recommended that the 
engineer break apart their code into different Python modules within the lib directory and import the code as needed 
into the algorithm.py file. It is left up to the engineer to determine when refactoring into submodules makes sense as 
it is not required by the framework bundled with this template.

Note for Mac/Linux: Scripts for Mac/Linux are run by passing the script name to the bash interpreter. For example, to 
execute the train script, run `/bin/bash bin/train.sh`. Note that the script is run from the root of the project and not
from within the bin directory.

Note for Windows: This template contains scripts for both Mac/Linux and Windows. This documentation will mainly name the
Mac/Linux script names only. The Windows equivalents differ in file name extension only. That is, if the Mac/Linux file
is named file.sh, then the corresponding Windows file is file.bat. Also, the Windows scripts can be called just by 
typing the name of the script, such as bin\train.bat. Windows scripts do not use the /bin/bash interpreter call to 
prefix the script filename. 

## Development

In order to start developing a new project from this template, do the following:

1. Determine the name of the new project. For this example, lets say the new project is called "Widget Algo".
2. Copy this template to a directory with a name that is descriptive of the project name, such as widget-algo.
3. Modify the .env/.env.bat file and set the DOCKER_NAME environment variable to the name of the project. For instance, 
you could use the same name as the directory from step 2, widget-algo.
4. Run bin/docker-build.sh. This will create the docker images needed to simulate running your code in SageMaker.
5. Write your algorithm in algorithm.py. See the comment section at the top of that file for instructions on how to
implement the algorithm.py file and provide the correct life-cycle hooks to initialize, train and predict with your 
algorithm.
6. To train your algorithm, run bin/train.sh. If your algorithm is implemented correctly, it will read the training data
from the training directory and write the trained model to the model directory as described in the requirements at the 
top of the algorithm.py file.
7. To test predictions on your algorithm, run bin/serve.sh. This will create a web service that meets the SageMaker
requirements for a prediction end-point. Use Postman, cURL, or any web API test utility to POST JSON payloads to your 
service. The URL you will post to is http://localhost:8080/invocations. The content-type of the HTTP request must be
application/json. The payload must be JSON encoded string. This JSON object will be parsed into a Python dictionary and
passed directly to your Predict() function. Your Predict() function must return a Python dictionary containing the 
predictions for the passed in features. The framework will JSON encode this dictionary and reply to the POST request
to invocations. 

If you need to delete/re-create your Docker images for a project, simply run bin/docker-destroy.sh, then rebuild your
environment from step 4 above. Similarly, if you are done with an algorithm and do not plan to develop on it again you
should run bin/docker-destroy.sh before archiving the source code. This will clean up all the associated Docker images
and containers so they do not waste your disk space. 

If you need to modify any part of Dockerfile or Dockerfile.develop, run bin/docker-build.sh after you save your changes
to the files.

## Deployment

In order to deploy your completed algorithm you need to re-build your Docker image and push it to your container repo.

1. Run bin/docker-build.sh. This will ensure your latest code is packaged in the :dev-base image for your algorithm.
2. You will have two images in your local Docker repo on your machine. They will differ in that one will be tagged :dev
and one :dev-base. :dev-base is the image you will want to push to your container repository. The :dev image is used for
local development only. 
3. Once you have identified the image in your local repo tag it for pushing to your container repository in the cloud. 
You will want to tag it with the version number of your algorithm. For example if your algorithm instance version is
0.2.5, then make sure your tag ends in :0.2.5. This will prevent accidentally crossing code versions when deploying.
4. Push to your container repo.
5. See documentation in the SageMaker broker for how to deploy an algorithm instance from a container repo to 
production.

# Release History

v0.0.1 - This release 
