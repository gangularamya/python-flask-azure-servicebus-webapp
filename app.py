from flask import Flask, render_template, request, jsonify
from azure.servicebus import ServiceBusClient, ServiceBusMessage
import os
import logging
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Azure Service Bus configuration from environment variables - NO HARDCODED SECRETS!
SERVICE_BUS_CONNECTION_STRING = os.getenv('SERVICE_BUS_CONNECTION_STRING')
QUEUE_NAME = os.getenv('QUEUE_NAME', 'asbqueue')

def get_servicebus_client():
    """Create and return a Service Bus client"""
    try:
        if not SERVICE_BUS_CONNECTION_STRING:
            logger.error("SERVICE_BUS_CONNECTION_STRING environment variable is not set")
            return None
        return ServiceBusClient.from_connection_string(SERVICE_BUS_CONNECTION_STRING)
    except Exception as e:
        logger.error(f"Error creating Service Bus client: {str(e)}")
        return None

@app.route('/')
def hello_world():
    """Home page with hello world message"""
    try:
        return render_template('index.html')
    except Exception as e:
        # Fallback to simple HTML if template is missing
        connection_status = "✅ Connection string configured" if SERVICE_BUS_CONNECTION_STRING else "❌ Connection string not configured"
        return f'''
        <!DOCTYPE html>
        <html>
        <head>
            <title>Flask Azure Service Bus App</title>
            <style>
                body {{ font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }}
                .container {{ background: #f5f5f5; padding: 30px; border-radius: 10px; }}
                button {{ background: #0078d4; color: white; padding: 10px 20px; border: none; border-radius: 5px; margin: 10px; cursor: pointer; }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🐍 Flask Azure Service Bus App - Secure Version 🔐</h1>
                <p>Hello World! Your Flask app is running securely!</p>
                <p><strong>Status:</strong> {connection_status}</p>
                <p><strong>Queue:</strong> {QUEUE_NAME}</p>
                
                <div style="background: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin: 15px 0;">
                    <strong>🔐 Security:</strong> No hardcoded secrets in source code!<br>
                    Configuration loaded from environment variables.
                </div>
                
                <h3>Configuration Required:</h3>
                <p>Set these environment variables:</p>
                <ul>
                    <li><code>SERVICE_BUS_CONNECTION_STRING</code> - Your Azure Service Bus connection string</li>
                    <li><code>QUEUE_NAME</code> - Queue name (default: asbqueue)</li>
                </ul>
                
                <h3>API Endpoints:</h3>
                <ul>
                    <li><a href="/health">/health</a> - Health check</li>
                    <li>POST /send-message - Send message to Service Bus</li>
                    <li>GET /receive-messages - Receive messages from Service Bus</li>
                </ul>
                
                <button onclick="window.location.href='/health'">Health Check</button>
                
                <div id="result"></div>
                
                <script>
                async function sendTestMessage() {{
                    try {{
                        const response = await fetch('/send-message', {{
                            method: 'POST',
                            headers: {{'Content-Type': 'application/json'}},
                            body: JSON.stringify({{'message': 'Hello from Azure App Service!'}})
                        }});
                        const data = await response.json();
                        document.getElementById('result').innerHTML = '<p style="color: green;">✅ ' + data.message + '</p>';
                    }} catch (error) {{
                        document.getElementById('result').innerHTML = '<p style="color: red;">❌ Error: ' + error.message + '</p>';
                    }}
                }}
                
                async function receiveMessages() {{
                    try {{
                        const response = await fetch('/receive-messages');
                        const data = await response.json();
                        document.getElementById('result').innerHTML = '<p style="color: blue;">📨 Received ' + data.messages_count + ' messages</p>';
                    }} catch (error) {{
                        document.getElementById('result').innerHTML = '<p style="color: red;">❌ Error: ' + error.message + '</p>';
                    }}
                }}
                </script>
                
                <button onclick="sendTestMessage()">Send Test Message</button>
                <button onclick="receiveMessages()">Receive Messages</button>
            </div>
        </body>
        </html>
        '''

@app.route('/send-message', methods=['POST'])
def send_message():
    """Send a message to Azure Service Bus queue"""
    try:
        data = request.get_json()
        message_content = data.get('message', 'Hello from Flask App!')
        
        # Create Service Bus client
        servicebus_client = get_servicebus_client()
        if not servicebus_client:
            return jsonify({'error': 'Failed to connect to Service Bus'}), 500
        
        # Send message to queue
        with servicebus_client:
            sender = servicebus_client.get_queue_sender(queue_name=QUEUE_NAME)
            with sender:
                message = ServiceBusMessage(f"{message_content} - Sent at {datetime.now()}")
                sender.send_messages(message)
                logger.info(f"Message sent to queue: {message_content}")
        
        return jsonify({
            'status': 'success',
            'message': f'Message sent to queue: {QUEUE_NAME}',
            'content': message_content
        })
        
    except Exception as e:
        logger.error(f"Error sending message: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/receive-messages', methods=['GET'])
def receive_messages():
    """Receive messages from Azure Service Bus queue"""
    try:
        messages = []
        
        # Create Service Bus client
        servicebus_client = get_servicebus_client()
        if not servicebus_client:
            return jsonify({'error': 'Failed to connect to Service Bus'}), 500
        
        # Receive messages from queue
        with servicebus_client:
            receiver = servicebus_client.get_queue_receiver(queue_name=QUEUE_NAME, max_wait_time=5)
            with receiver:
                received_msgs = receiver.receive_messages(max_message_count=10, max_wait_time=5)
                for msg in received_msgs:
                    messages.append({
                        'body': str(msg),
                        'message_id': msg.message_id,
                        'enqueued_time': str(msg.enqueued_time_utc)
                    })
                    receiver.complete_message(msg)
                    logger.info(f"Message received and completed: {str(msg)}")
        
        return jsonify({
            'status': 'success',
            'messages_count': len(messages),
            'messages': messages
        })
        
    except Exception as e:
        logger.error(f"Error receiving messages: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health_check():
    """Health check endpoint"""
    config_status = "configured" if SERVICE_BUS_CONNECTION_STRING else "not configured"
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'python_version': '3.13',
        'service_bus_queue': QUEUE_NAME,
        'connection_status': config_status,
        'security': 'No hardcoded secrets'
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)