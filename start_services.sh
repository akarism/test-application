#!/bin/bash

# Directory to store all JAR files
TARGET_DIR="./all-services"

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

export JAVA_HOME=/Users/honglongweng/Library/Java/JavaVirtualMachines/azul-1.8.0_422/Contents/Home
mvn --version

# Array of service directories in the order they should be built and started
services=(
    "eureka-server"
    "config-server"
    "monitor-service"
    "uaa-service"
    "gateway-service"
    "admin-service"
    "user-service"
    "blog-service"
    "log-service"
)

# Function to build a service and copy its JAR
build_service() {
    service=$1
    echo "Building $service..."
    
    cd "$service" || exit
    mvn clean install -DskipTests
    
    jar_file=$(find target -name "$service-*.jar")
    if [ -n "$jar_file" ]; then
        cp "$jar_file" "../$TARGET_DIR/${service}.jar"
        echo "Copied ${service}.jar to $TARGET_DIR"
    else
        echo "Error: JAR file not found for $service"
    fi
    
    cd ..
}

# Function to start a service in detached mode
start_service() {
    service=$1
    echo "Starting $service..."
    nohup java -jar $TARGET_DIR/${service}.jar > ${service}.log 2>&1 &
    echo "$service started with PID $!"
    sleep 10  # Wait for the service to start
}

# Build all services
for service in "${services[@]}"; do
    build_service "$service"
done

# Start all services
for service in "${services[@]}"; do
    start_service "$service"
done

echo "All services have been started in detached mode."
