import boto3
import json
import numpy as np
import csv
import io

def test_endpoint():
    runtime = boto3.client('sagemaker-runtime')
    
    # Create test data with features
    features = np.array([1.0, 2.0])  # Example with 2 features
    
    # Convert to CSV string 
    csv_buffer = io.StringIO()
    np.savetxt(csv_buffer, features, delimiter=',', fmt='%.1f')
    payload = csv_buffer.getvalue()
    
    print(f"Sending payload: {payload}")  # Debug print
    
    try:
        response = runtime.invoke_endpoint(
            EndpointName='dev-lstm-endpoint',
            ContentType='text/csv',
            Accept='text/csv',
            Body=payload
        )
        
        # Parse response
        result = response['Body'].read().decode()
        print(f"Endpoint response: {result}")
        
    except Exception as e:
        print(f"Error invoking endpoint: {str(e)}")
        print(f"Error type: {type(e)}")
        # Check CloudWatch logs for more details
        print("Please check CloudWatch logs at: /aws/sagemaker/Endpoints/dev-lstm-endpoint")

if __name__ == "__main__":
    test_endpoint()