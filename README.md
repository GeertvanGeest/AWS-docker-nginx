# NGINX for reverse proxy container with Rstudio

Based on [this tutorial](https://leangaurav.medium.com/simplest-https-setup-nginx-reverse-proxy-letsencrypt-ssl-certificate-aws-cloud-docker-4b74569b3c61)

## Generate credentials

Generate a list of credentials based on first name and last name of participants: 

```sh
./utils/generate_credentials.sh -l examples/user_list_credentials.txt > credentials_list.txt
```

Generate a variable called `BATCH_USER_CREATION` that is used by the Rstudio container to generate users:

```sh
source utils/user_list_variable.sh credentials_list.txt
```

## Start the containers

First, install docker (if you haven't already):

```sh
curl https://get.docker.com | sh
sudo usermod -a -G docker ubuntu # ubuntu is the user with root access
sudo service docker start
```

Logout and login again to use docker with `sudo`. 

For a certificate issued by Let's encrypt, you will need first to make sure that the IP you are hosting the app is correctly associated to your domain. In the repo the domain `sib-training-test.ml` is used. 

Setting up the reverse proxy occurs in three steps:

1. Set up a reverse proxy over http using nginx
2. Generate certificates with let's encrypt
3. Set up the reverse proxy with the app over https

### 1. Set up a reverse proxy over http using nginx

```sh
cd 01_http_proxy
docker compose up --build -d
```

### 2. Generate certificates with let's encrypt

```sh
cd ../02_lets_encrypt
docker compose up
```

The container should stop automatically when it's done. 

Now that the certificates are created we will stop the http proxy by:

```sh
cd ../01_http_proxy
docker compose down
```

### 3. Set up the reverse proxy with the app over https

```sh
cd ../03_https_proxy
```

Set variables in the `.env` file. These are environmental variables used inside the `docker-compose.yml` file. The default contents are:

```
IMAGE=geertvangeest/rstudio_multi_user 
```

Which specifies the image used by the `rstudio` service. 

You can pass also variables to the container. These are taken over from the shell where the `docker compose` command is run. Here for example the usernames and passwords if you want to host rstudio with multiple users:

```sh
BATCH_USER_CREATION="user1:pass1;user2:pass2"
```

To auto generate this variable, use `utils/user_list_to_variable.sh`:

```sh
source utils/user_list_variable.sh credentials_list.txt
```

And to set to admin password:

```sh
PASSWORD=myverysecureadminpassword
```

Now start the services:

```sh
docker compose up --build -d
```

## Reload nginx after changins certs

```sh
docker exec -it [CONTAINER ID] nginx -s reload
```
