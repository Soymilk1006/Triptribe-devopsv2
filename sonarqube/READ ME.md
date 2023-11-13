# Sonalqube(

The SonarQube server requires Java version 17 and PostgreSQL

## deployment:

make a docker-compose.yml file 

```yaml
version: '3.1'

services:
  db:
    image: postgres
    container_name: db
    ports:
      - 5432:5432
    networks:
      - sonarnet
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
  
  sonarqube:
    image: sonarqube:lts-community
    container_name: sonarqube
    depends_on:
      - db
    ports:
      - 9000:9000
    networks:
      - sonarnet
    environment:
      SONAR_JDBC_URL : jdbc:postgresql://db:5432/sonar
      SONAR_JDBC_USERNAME : sonar
      SONAR_JDBC_PASSWORD : sonar

networks:
  sonarnet:
    driver: bridge
```

check the docker log if :

![Untitled](Sonalqube/Untitled.png)

you need to change it through: 

 

```bash
sudo vim /etc/sysctl.conf
```

![Untitled](Sonalqube/Untitled%201.png)

then run 

```bash
sudo sysctl -p
```

visit (your ip address):9000 you can see the page 

![Untitled](Sonalqube/Untitled%202.png)

Login info: 

admin

admin