FROM ubuntu:xenial

# Set this environment variable to avoid warnings 'debconf: unable to initialize frontend: dialog'
ENV DEBIAN_FRONTEND noninteractive

# Update to install pip and other packages for add-apt-repository
RUN apt-get update && apt-get install -y \
    software-properties-common python-software-properties python-pip && apt-get clean
    
# Add 3rd party PPA for ffmpeg package (ffmpeg is used by textract)
# Run update again to get new packages that we described in the new PPA
RUN add-apt-repository ppa:jonathonf/ffmpeg-3 \
   && apt-get update && apt-get dist-upgrade && apt-get clean

# Install all dependencies as needed by textract. 
# Install zlibg1-dev as it is needed on docker instances.
# See http://textract.readthedocs.org/en/latest/installation.html. check note as well
RUN apt-get install python-dev libxml2-dev libxslt1-dev antiword unrtf poppler-utils pstotext tesseract-ocr \
flac ffmpeg lame libmad0 libsox-fmt-mp3 sox libjpeg-dev swig libpulse-dev zlib1g-dev && apt-get clean

# Install textract using pip
RUN pip install textract

ENTRYPOINT ["textract"]
