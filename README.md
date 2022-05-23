## To deploy

https://leangaurav.medium.com/simplest-https-setup-nginx-reverse-proxy-letsencrypt-ssl-certificate-aws-cloud-docker-4b74569b3c61

Make sure the IP is correctly associated to the domain (`sib-training-test.ml`)

First host the app over http

```sh
cd deploy/config
mv nginx.conf.http nginx.conf
```

Start the app + nginx over http:

```sh
docker compose up --build nginx
```

On the server, generate the certificates:

```sh
docker compose -f docker-compose-le.yml up --build
```

Then run: 

```sh
cd deploy/config
mv nginx.conf.https nginx.conf
```

Export a variable in the shell:

```sh
export BATCH_USER_CREATION="user1:pass1;user2:pass2"
```

```sh
docker compose up --build -d nginx
```

