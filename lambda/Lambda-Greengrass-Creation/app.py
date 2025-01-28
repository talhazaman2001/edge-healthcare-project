import json
import boto3
import logging
import os

# Initialise Greengrass client
greengrass_client = boto3.client('greengrass')

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# IOT Thing and Certificate ARNs
thing_arn = os.getenv('THING_ARN')
cert_arn = os.getenv('CERTIFICATE_ARN')

def lambda_handler(event, context):
    try: 
        # Create Greengrass Group
        group_response = greengrass_client.create_group(Name = "IoTGreenGrassGroup")
        group_id = group_response['Id']
        logger.info(f"Created Greengrass Group: {group_id}")

        # Create Greengrass Core Definition
        core_definition_response = greengrass_client.create_core_definiton(
            Name = "IOTGreengrassCoreDefinition",
            InitialVersion = {
                'Cores': [
                    {
                        'Id' : 'IoTGreengrassCore',
                        'ThingArn' : thing_arn,
                        'CertificateArn' : cert_arn,
                        'SyncShadow' : True
                    }
                ]
            }
        )

        core_definition_id = core_definition_response['Id']
        logger.info(f"Created Greengrass Core Definition: {core_definition_id}")

        # Create Greengrass Function Definition
        function_definition_response = greengrass_client.create_function_definition(
            Name = "IoTGreengrassFunctionDefinition",
            InitialVersion = {
                'Functions': [
                    {
                        'Id': 'IoTGreengrassFunction',
                        'FunctionArn': 'arn:aws:lambda:eu-west-2:463470963000:function:IoTGreenGrassFunction',
                        'FunctionConfiguration' : {
                            'MemorySize' : 1024,
                            'Timeout' : 3,
                            'Pinned' : True,
                            'Environment' : {
                                'Variables' : {}
                            }
                        }
                    }
                ]
            }
        )
        function_definition_id = function_definition_response['Id']
        logger.info(f"Created Greengrass Function Definition: {function_definition_id}")

        # Create Greengrass Group Version
        group_version_response = greengrass_client.create_group_version(
            GroupId = group_id,
            CoreDefinitionVersionArn = core_definition_response['LatestVersionArn'],
            FunctionDefinitionVersionArn = function_definition_response['LatestVersionArn']
        )
        logger.info(f"Created Greengrass Group Version: {group_version_response['Version']}")

        return {
            'message' : "Greengrass Group and resources created successfully."
        }
    
    except Exception as e:
        return {
            'error' : (f"Error creating Greengrass Group: {str(e)}")
        }
    
