# 1. Start with a Python base image
FROM python:3.8-slim

# 2. Set the working directory inside the container
WORKDIR /app

# 3. Copy the requirements file from your app folder into the container
COPY app/requirements.txt .

# 4. Install the Python dependencies from that file
RUN pip install -r requirements.txt

# 5. Copy the rest of the application code from your app folder
COPY app/ .

# 6. Expose the port the app runs on
EXPOSE 5000

# 7. Command to run the application
CMD ["python", "app.py"]




# Start with a Python base image
# FROM python:3.8-slim

# # Set the working directory
# WORKDIR /app

# # Copy the requirements file and install dependencies
# COPY app/requirements.txt .
# RUN pip install -r requirements.txt

# # Copy the application code
# COPY ./app .

# # Expose the port the app runs on
# EXPOSE 5000

# # Command to run the application
# CMD ["python", "app.py"]
