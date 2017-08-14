# Setup basic authentication
The registry server and the Docker client support basic authentication over HTTPS. 
The server uses a file with a collection of usernames and encrypted passwords. The file uses Apache’s htpasswd.

Create the password file with username 'registryuser' and password as 'password'
    
    mkdir auth
    docker run --entrypoint htpasswd registry:latest -Bbn registryuser password > auth/htpasswd
    
–entrypoint Overwrite the default ENTRYPOINT of the image <br />
-B Use bcrypt encryption <br />
-b run in batch mode <br />
-n display results <br />

Verify that entries have been written by checking the file contents. Use the below command to see the user names in plain text
and a cipher text password.

    cat auth/htpasswd
    
# Run Authenticated Secure Registry
Adding authentication to the registry is a similar to adding SSL.
We need to run the registry with access to the htpasswd file on the host, and configure authentication using environment variables.

    docker run -d -p 5000:5000 --name registry \
      --restart unless-stopped \
      -v $(pwd)/registrydata:/var/lib/registry \
      -v $(pwd)/certs:/certs \
      -v $(pwd)/auth:/auth \
      -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
      -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
      -e REGISTRY_AUTH=htpasswd \
      -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
      -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
      registry
The options for this container are:

1) -v $(pwd)/auth:/auth <br />
   mount the local auth folder into the container, so the registry server can access htpasswd file.
2) -e REGISTRY_AUTH=htpasswd <br />
   use the registry’s htpasswd authentication method.
3) -e REGISTRY_AUTH_HTPASSWD_REALM='Registry Realm' <br />
   specify the authentication realm.
4) -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd
   specify the location of the htpasswd file.
Now the registry is using secure transport and user authentication.


## Authenticating with the Registry
With basic authentication, users cannot push or pull from the registry unless they are authenticated. 
If you try to pull an image without authenticating, you will get an error:

    docker pull 127.0.0.1:5000/hello-world
    Using default tag: latest
    Error response from daemon: Get https://127.0.0.1:5000/v2/hello-world/manifests/latest: no basic auth credentials
    
## Login to secure registry

    docker login 127.0.0.1:5000
    Username: registryuser
    Password:
    Login Succeeded
    
## Now you’re authenticated, you can push and pull as before:

    docker pull 127.0.0.1:5000/hello-world
    Using default tag: latest
    latest: Pulling from hello-world
    Digest: sha256:961497c5ca49dc217a6275d4d64b5e4681dd3b2712d94974b8ce4762675720b4
    Status: Image is up to date for registry.local:5000/hello-world:latest
