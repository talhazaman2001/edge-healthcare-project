import json
import boto3
import logging

# Initialise the API Gateway Management API Client
apigateway_management = boto3.client('apigatewaymanagementapi', endpoint_url = 'https://example.com')

# Set up Logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    # Log the incoming event from IoT Greengrass
    logger.info((f"Recieved event from Greengrass: {json.dumps(event)}"))

    # Extract the payload from the event (predictive analytics)
    payload = event.get('body', None)
    if not payload:
        logger.error("No data provided from Greengrass for analytics..")
        return # Early exit if no input
    
    # Process the analytics data from IoT Greengrass
    try:
        analytics_result = json.loads(payload)
        logger.info(f"Analytics result from Greengrass: {analytics_result}")

        # Send alert to WebSocket API Gateway
        connection_id = "mock-connection-id"
        send_alert(connection_id, analytics_result)

    except Exception as e:
        logger.error(f"Error processing analytics from Greengrass: {e}")
        return
    
def send_alert(connection_id, message):
    try:
        apigateway_management.post_to_connection(
            ConnectionId = connection_id,
            Data = json.dumps(message)
        )
        logger.info(f"Alert sent to connection ID {connection_id}: {message}")

    except Exception as e:
        logger.error(f"Error sending alert to WebSocket: {e}")