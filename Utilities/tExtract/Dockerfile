FROM ubuntu:xenial

# Set this environment variable to avoid warnings 'debconf: unable to initialize frontend: dialog'
ENV DEBIAN_FRONTEND noninteractive

# Update to install pip and other packages for add-apt-repository
RUN apt-get update && RUN apt-get install -y \
    software-properties-common python-software-properties python-pip
    
# Add 3rd party PPA for ffmpeg package (ffmpeg is used by textract)
# Run update again to get new packages that we described in the new PPA
RUN add-apt-repository ppa:jon-severinsson/ffmpeg \
   && RUN apt-get update

# Install all dependencies as needed by textract. 
# Install zlibg1-dev as it is needed on docker instances.
# See http://textract.readthedocs.org/en/latest/installation.html. check note as well
RUN apt-get install python-dev libxml2-dev libxslt1-dev antiword unrtf poppler-utils pstotext tesseract-ocr \
flac ffmpeg lame libmad0 libsox-fmt-mp3 sox libjpeg-dev swig libpulse-dev zlib1g-dev

# Install textract using pip
RUN pip install textract

ENTRYPOINT ["textract"]
