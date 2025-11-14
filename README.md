# Python Flask Azure Service Bus Web App

This is a simple Flask web application that demonstrates integration with Azure Service Bus for sending and receiving messages.

## Features

- 🐍 Python 3.13 Flask web application
- 🚌 Azure Service Bus integration
- 📤 Send messages to Service Bus queue
- 📥 Receive messages from Service Bus queue
- 🏥 Health check endpoint
- 🌐 Web interface for testing

## Setup Instructions

### 1. Create Virtual Environment

```bash
# Create virtual environment using Python 3.13
C:\Users\ragangul\AppData\Local\Programs\Python\Python313\python.exe -m venv venv

# Activate virtual environment
# On Windows PowerShell:
.\venv\Scripts\Activate.ps1
# On Windows Command Prompt:
.\venv\Scripts\activate.bat
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure Environment Variables

Create a `.env` file with your Azure Service Bus configuration:

```
SERVICE_BUS_CONNECTION_STRING=your-azure-service-bus-connection-string
QUEUE_NAME=asbqueue
```

**Security Note:** Use the `.env.example` file as a template. Never commit actual secrets to version control.

### 4. Run the Application

```bash
python app.py
```

The application will be available at: http://localhost:5000

## API Endpoints

- `GET /` - Home page with web interface
- `POST /send-message` - Send message to Service Bus queue
- `GET /receive-messages` - Receive messages from Service Bus queue
- `GET /health` - Health check endpoint

## Azure App Service Deployment

### Requirements for Linux Web App

- Python 3.13 runtime
- Gunicorn WSGI server (included in requirements.txt)

### App Service Configuration

Set the following application settings in Azure App Service:

```
SERVICE_BUS_CONNECTION_STRING = [Your actual connection string]
QUEUE_NAME = asbqueue
SCM_DO_BUILD_DURING_DEPLOYMENT = true
```

### Startup Command

For Linux App Service, use this startup command:
```
gunicorn --bind=0.0.0.0 --timeout 600 app:app
```

## Project Structure

```
pythonASBEventHubappservice/
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── .env                  # Environment variables
├── templates/
│   └── index.html        # Web interface
└── README.md            # This file
```

## Testing the Application

1. **Health Check**: Visit `/health` to verify the app is running
2. **Send Message**: Use the web interface or POST to `/send-message`
3. **Receive Messages**: Use the web interface or GET `/receive-messages`

## Security Notes

- Never commit actual connection strings to version control
- Use Azure Key Vault in production
- Configure proper authentication and authorization
- Enable HTTPS in production