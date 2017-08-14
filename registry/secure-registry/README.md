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

## restart the docker daemon

# Run secure registry
For the secure registry, we need to run a container which has the SSL certificate and key files available. We do with an additional volume mount (so we have one volume for registry data, and one for certs). We also need to specify the location of the certificate files, which we’ll do with environment variables

    mkdir registrydata
    docker run -d -p 5000:5000 --name registry \
      --restart unless-stopped \
      -v $(pwd)/registrydata:/var/lib/registry \
      -v $(pwd)/certs:/certs \
      -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
      -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
      registry
      
      
