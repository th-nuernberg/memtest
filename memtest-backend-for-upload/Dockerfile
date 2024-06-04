FROM python:3-alpine

# Install necessary dependencies
RUN apk add --no-cache gcc musl-dev linux-headers

# Set the working directory
WORKDIR /usr/src/app

# Copy the requirements file
COPY requirements.txt /usr/src/app/

# Install dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . /usr/src/app

# Create the upload folder
RUN mkdir -p /usr/src/app/upload_folder

# Expose the port the app runs on
EXPOSE 8080

# Set the entrypoint and command
ENTRYPOINT ["python3"]

CMD ["-m", "openapi_server"]
