# Stage 1: build WAR bằng Maven (Java 21)
FROM maven:3.9.4-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .
RUN mvn -B -DskipTests clean package

# Stage 2: chạy ứng dụng với Tomcat
FROM tomcat:11.0-jre21-temurin

# (Tuỳ chọn) Tắt shutdown port 8005 để tránh spam log
RUN sed -i 's/port="8005"/port="-1"/' /usr/local/tomcat/conf/server.xml

# Xoá các ứng dụng mặc định của Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy file .war từ stage 1 vào thư mục webapps của Tomcat ở stage 2
COPY --from=build /app/target/web3-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

# Mở port 8080 để có thể truy cập ứng dụng từ bên ngoài container
EXPOSE 8080

# Lệnh mặc định khi container khởi động là chạy Tomcat
CMD ["catalina.sh","run"]
