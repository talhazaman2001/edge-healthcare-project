import logging
import boto3
import time
from typing import Any, Dict, Optional
from datetime import datetime, timezone
from botocore.exceptions import ClientError

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def setup_aws_clients():
    """Initialise AWS clients with error handling."""
    try:
        return {
            'sagemaker': boto3.client('sagemaker'),
            'cloudwatch': boto3.client('cloudwatch'),
            'runtime': boto3.client('sagemaker-runtime')
        }
    except Exception as e:
        logger.error(f"Failed to initialise AWS clients: {e}")
        raise 

def log_metric(name: str, value: float, unit: str = 'None', dimensions: Optional[Dict] = None):
    """"Send metric to CloudWatch."""
    try: 
        clients = setup_aws_clients()
        clients['cloudwatch'].put_metric_data(
            Namespace = 'MLOps/ModelMetrics',
            MetricData = [{
                'MetricName': name,
                'Value': value,
                'Unit': unit,
                'Timestamp': datetime.now(timezone.utc),
                'Dimensions': dimensions or []
            }]
        )
    except Exception as e:
        logger.error(f"Failed to log metric {name}: {e}")
        raise 

    