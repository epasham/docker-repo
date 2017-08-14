# Generating the SSL Certificate
openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 365 -out certs/domain.crt

    $ openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 365 -out certs/domain.crt
    Generating a 4096 bit RSA private key
    .........++
    .....................................................++
    writing new private key to 'certs/domain.key'
    -----
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) []:US
    State or Province Name (full name) []:IL
    Locality Name (eg, city) []:Chicago
    Organization Name (eg, company) []:Docker
    Organizational Unit Name (eg, section) []:
    Common Name (eg, fully qualified host name) []:127.0.0.1
    Email Address []:

## To get the docker daemon to trust the certificate, copy the domain.crt file.
    mkdir /etc/docker/certs.d
    mkdir /etc/docker/certs.d/127.0.0.1:5000 
    cp $(pwd)/certs/domain.crt /etc/docker/certs.d/127.0.0.1:5000/ca.crt
