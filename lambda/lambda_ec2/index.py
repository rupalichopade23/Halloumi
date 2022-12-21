import boto3
import os
def get_instance_id():
    ec2_client = boto3.client("ec2")
    Filters=[
        {
          "Name": "instance-id",
          "Values": ["i-081a0e77d790fc3b3"]
        
        }
    ]
    response = ec2_client.describe_instances(
        Filters= Filters
    )
    print(response)
    instance_id = response["Reservations"][0]["Instances"][1]["InstanceId"]
    print(instance_id)
    return instance_id
    
def add_tags(instance_id):
    ec2_client = boto3.client("ec2")
    
    response = ec2_client.create_tags(
      DryRun=False,
      Resources = [instance_id],
      Tags=[
        {
          'Key': 'name',
          'Value': 'ec2'
        },
      ]
    )

def stop_instance():
    ec2_client = boto3.client("ec2")
    response = ec2_client.stop_instances(
      InstanceIds=[
        'i-081a0e77d790fc3b3',
      ]
    )
def lambda_handler(event, context):
    instance_id = get_instance_id()
    add_tags(instance_id)
    stop_instance()

    


    
