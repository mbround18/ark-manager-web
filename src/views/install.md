# Install Guide

Whoooooaaahh it looks like you dont have the frontend configured right.....
Lets walkthrough the install together!


## Setup Local

- Install [Yarn]
- Once yarn is installed run `yarn install`
- Then run `yarn build`


## Setup Remote

- Install [Yarn]
- Once yarn is installed run `yarn install`
- Set the env variable `BACKEND_EXTERNAL_URL` to the IP of the backend server.
- Then run `yarn build`
- Deploy the contents of the `dist` folder to where ever you intend to host the frontend. (Ex: hosted on AWS CloudFront)
- Restart the backend but before you do.. set the following env variables:

```.env
NODE_ENV='external'
FRONTEND_EXTERNAL_URL='HOST OF FRONTEND'
```

## Notes

Once the setup is completed simply reload this webpage :)