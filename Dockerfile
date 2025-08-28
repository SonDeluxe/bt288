# Stage 1: build WAR bằng Maven (Java 24)
# Thay đổi ảnh nền để sử dụng phiên bản Java 24
FROM maven:latest-eclipse-temurin-24 AS build
WORKDIR /app
COPY . .
RUN mvn -B -DskipTests clean package

# Stage 2: chạy ứng dụng với Tomcat
# Bạn cũng cần một ảnh Tomcat hỗ trợ Java 24 để chạy ứng dụng
FROM tomcat:latest-jre24-temurin

# (Tuỳ chọn) Tắt shutdown port 8005 để tránh spam log
RUN sed -i 's/port="8005"/port="-1"/' /usr/local/tomcat/conf/server.xml

# Xoá các ứng dụng mặc định của Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy file .war từ stage 1 vào thư mục webapps của Tomcat
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Mở port 8080
EXPOSE 8080

# Lệnh mặc định khi container khởi động
CMD ["catalina.sh","run"]
