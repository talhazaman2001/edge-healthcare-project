import greengrasssdk
import json
import numpy as np
from tensorflow.keras.models import load_model

# Initialize Greengrass client
client = greengrasssdk.client('iot-data')

# Load the pre-trained LSTM model
model = load_model('/greengrass-machine-learning/lstm_model.h5')

def lambda_handler(event, context):
    try:
        # Parse input data (e.g., health metrics)
        data = json.loads(event['body'])
        input_data = np.array(data['metrics']).reshape(1, -1, 1)  # Reshape for LSTM

        # Run inference
        prediction = model.predict(input_data).tolist()

        # Publish result to AWS IoT Core 
        response = {
            'patient_id': data['patient_id'],
            'prediction': prediction
        }

        # Send result to the cloud for further processing
        client.publish(
            topic = 'healthcare/prediction/result',
            payload = json.dumps(response)
        )

    except Exception as e:
        client.publish(
            topic = 'healthcare/prediction/error',
            payload = f"Error processing prediction: {str(e)}"
        )

    return 'Inference complete'


