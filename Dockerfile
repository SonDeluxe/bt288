# Stage 1: build WAR bằng Maven (Java 17)
# Sử dụng ảnh chính thức của Maven và Eclipse Temurin để đảm bảo môi trường build ổn định
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
# Lệnh này sẽ build ứng dụng Java của bạn thành file .war, bỏ qua các bài kiểm tra
RUN mvn -B -DskipTests clean package

# Stage 2: chạy ứng dụng với Tomcat
# Sử dụng một ảnh Tomcat nhẹ nhàng hơn, chỉ chứa JDK để chạy
FROM tomcat:11.0-jre17-temurin

# (Tuỳ chọn) Tắt shutdown port 8005 để tránh spam log
# Lệnh sed này sẽ thay đổi cấu hình của Tomcat để port 8005 không được sử dụng
RUN sed -i 's/port="8005"/port="-1"/' /usr/local/tomcat/conf/server.xml

# Xoá các ứng dụng mặc định của Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Đã sửa: Copy file .war từ stage 1 vào thư mục webapps của Tomcat ở stage 2
# Tên file .war thường có dạng [artifact-id]-[version].war, ví dụ: web3-1.0-SNAPSHOT.war
COPY --from=build /app/target/web3-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

# Mở port 8080 để có thể truy cập ứng dụng từ bên ngoài container
EXPOSE 8080

# Lệnh mặc định khi container khởi động là chạy Tomcat
CMD ["catalina.sh","run"]
