# Service Setup and Deployment Guide

## Backend Services Setup

1. **Create Virtual Environment**
   - Navigate to each service folder and run:
     ```bash
     python -m venv venv
     ```

2. **Install Requirements**
   - Install dependencies from requirements.txt:
     ```bash
     pip install -r requirements.txt
     ```

3. **Run Services**
   - Activate the virtual environment:
     - Windows:
       ```bash
       .\venv\Scripts\activate
       ```
     - Linux/Mac:
       ```bash
       source venv/bin/activate
       ```
   - Start the application:
     ```bash
     python app.py
     ```

## Frontend Deployment

1. **Build WAR File**
   - Generate the deployment package:
     ```bash
     mvn clean package
     ```

2. **Deploy to Tomcat**
   - Move the generated `.war` file to your Tomcat installation's `webapps` directory
   - Tomcat will automatically deploy the application
