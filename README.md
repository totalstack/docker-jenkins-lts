# docker-jenkins-lts
Dockerfile creates an image with Ubuntu 16.04 and Jenkins LTS.

## Procedures
### 1. Build an Image using Dockerfile
To create an image
```
docker build -t image-name:version .
```

### 2. Create a Jenkins Container
To create a Container
```
docker run -p 8080:8080 -p 50000:50000 -d jenkins-lts:2.150.3
```
