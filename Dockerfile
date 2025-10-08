# Official Python image from Docker Hub
FROM python:3.10-slim

# Upgrade system packages to reduce vulnerabilities
RUN apt-get update && apt-get upgrade -y && apt-get clean

# Set the working directory
WORKDIR /app

# Copy project files into the container
COPY . /app

# Install dependencies
RUN pip install -r requirements.txt

ENV WEB_API_PORT=5001
ENV WEB_API_VALUE="Default Value"

# Run application
CMD ["python", "app.py"]