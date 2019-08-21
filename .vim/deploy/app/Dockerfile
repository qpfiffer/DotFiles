FROM stackbrew/ubuntu:13.10
RUN echo "deb http://archive.ubuntu.com/ubuntu saucy main universe" > /etc/apt/sources.list
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y unzip git curl openjdk-7-jre-headless maven
VOLUME ["/app"]
WORKDIR /app
ENTRYPOINT ["java", "-jar"]
