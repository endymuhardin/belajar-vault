# stage 1 : build jar dulu
FROM maven:3-eclipse-temurin-21 AS mvnbuild
# membuat working folder
WORKDIR /opt/aplikasi
# menambahkan pom.xml dari laptop ke dalam container
COPY pom.xml .
# donlod dependensi dulu, supaya menjadi layer terpisah dari compile
RUN mvn dependency:go-offline
# menambahkan folder src ke dalam container
COPY src ./src
# menjalankan compile source code dan buat jar file
RUN mvn package

# stage 2 : extract jar untuk memisahkan layer
FROM bellsoft/liberica-openjre-alpine:21-cds AS jarlayer
WORKDIR /builder
COPY --from=mvnbuild /opt/aplikasi/target/*.jar application.jar
RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted

# stage 3 : rakit layer menjadi docker image
FROM bellsoft/liberica-openjre-alpine:21-cds
WORKDIR /application
COPY --from=jarlayer /builder/extracted/dependencies/ ./
COPY --from=jarlayer /builder/extracted/spring-boot-loader/ ./
COPY --from=jarlayer /builder/extracted/snapshot-dependencies/ ./
COPY --from=jarlayer /builder/extracted/application/ ./
ENTRYPOINT ["java", "-jar", "application.jar"]