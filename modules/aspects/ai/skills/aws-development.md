---
name: aws-development
description: Use when building AWS serverless architectures, debugging Lambda issues, optimizing DynamoDB queries, implementing IAM policies, or resolving CloudFormation failures
---

# AWS Development

Guidelines for building applications on AWS with security, performance, and cost optimization.

## When to Use

- Lambda timeout issues or cold starts
- DynamoDB query performance problems
- IAM permission errors (Access Denied)
- CloudFormation stack failures
- API Gateway 502/504 errors
- S3 bucket policy violations
- EventBridge pattern matching issues

## When NOT to Use

- Multi-cloud abstractions (use delivery-and-infra)
- Generic cloud architecture patterns
- Kubernetes on AWS (use delivery-and-infra)

## Core AWS Principles

1. **Well-Architected Framework** - Security, Reliability, Performance, Cost, Operations, Sustainability
2. **Least Privilege** - Minimal IAM permissions
3. **Defense in Depth** - Multiple security layers
4. **Automation First** - Infrastructure as Code
5. **Pay for What You Use** - Cost optimization
6. **Design for Failure** - Assume components will fail

## IAM Security Best Practices

### IAM Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:GetObject", "s3:PutObject"],
    "Resource": "arn:aws:s3:::my-bucket/uploads/*",
    "Condition": {
      "StringEquals": {"s3:x-amz-acl": "private"}
    }
  }]
}
```

### Security Checklist
- [ ] Enable MFA for all users
- [ ] Use IAM roles instead of access keys
- [ ] Rotate credentials regularly
- [ ] Enable CloudTrail for audit logging
- [ ] Enable encryption at rest and in transit
- [ ] Use AWS Secrets Manager for sensitive data

## Serverless Architecture

### Lambda Best Practices
```python
from aws_lambda_powertools import Logger, Tracer, Metrics
from aws_lambda_powertools.utilities.typing import LambdaContext
from typing import Dict, Any
import boto3
import os

logger = Logger()
tracer = Tracer()
metrics = Metrics()

@metrics.log_metrics
@tracer.capture_lambda_handler
@logger.inject_lambda_context
def lambda_handler(event: Dict[str, Any], context: LambdaContext) -> Dict[str, Any]:
    """Process S3 events with observability."""
    try:
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table(os.environ['TABLE_NAME'])
        
        for record in event['Records']:
            bucket = record['s3']['bucket']['name']
            key = record['s3']['object']['key']
            metrics.add_metric(name="FilesProcessed", unit="Count", value=1)
            process_file(bucket, key, table)
            
        return {'statusCode': 200, 'body': 'Success'}
    except Exception as e:
        logger.exception("Error processing event")
        metrics.add_metric(name="ProcessingErrors", unit="Count", value=1)
        raise
```

### API Gateway + Lambda (SAM)
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Globals:
  Function:
    Timeout: 30
    Runtime: python3.11
    Environment:
      Variables:
        TABLE_NAME: !Ref UserTable

Resources:
  UserApi:
    Type: AWS::Serverless::Api
    Properties:
      StageName: prod
      Cors:
        AllowMethods: "'GET,POST,PUT,DELETE'"
        AllowOrigin: "'*'"

  GetUserFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: src/
      Handler: get_user.lambda_handler
      Events:
        GetUser:
          Type: Api
          Properties:
            RestApiId: !Ref UserApi
            Path: /users/{id}
            Method: get
            
  UserTable:
    Type: AWS::DynamoDB::Table
    Properties:
      BillingMode: PAY_PER_REQUEST
      AttributeDefinitions:
        - AttributeName: id
          AttributeType: S
      KeySchema:
        - AttributeName: id
          KeyType: HASH
      PointInTimeRecoverySpecification:
        PointInTimeRecoveryEnabled: true
```

## Storage Solutions

### S3 Best Practices
```python
import boto3
from botocore.exceptions import ClientError
from datetime import datetime

class S3Service:
    def __init__(self):
        self.s3_client = boto3.client('s3')
    
    def upload_with_metadata(self, file_path: str, bucket: str, key: str) -> bool:
        """Upload with encryption and lifecycle policy."""
        try:
            self.s3_client.upload_file(
                file_path, bucket, key,
                ExtraArgs={
                    'ServerSideEncryption': 'AES256',
                    'StorageClass': 'STANDARD_IA',
                    'Metadata': {'uploaded_by': 'api', 'timestamp': str(datetime.utcnow())}
                }
            )
            return True
        except ClientError as e:
            logger.error(f"Upload failed: {e}")
            return False
    
    def generate_presigned_url(self, bucket: str, key: str, expiration: int = 3600) -> str:
        """Generate presigned URL for temporary access."""
        return self.s3_client.generate_presigned_url(
            'get_object',
            Params={'Bucket': bucket, 'Key': key},
            ExpiresIn=expiration
        )
```

### DynamoDB Patterns
```python
import boto3
from boto3.dynamodb.conditions import Key, Attr

class UserRepository:
    def __init__(self):
        dynamodb = boto3.resource('dynamodb')
        self.table = dynamodb.Table('Users')
    
    def get_user(self, user_id: str) -> dict:
        """Get user by partition key."""
        response = self.table.get_item(Key={'id': user_id})
        return response.get('Item')
    
    def query_by_status(self, status: str) -> list:
        """Query using GSI."""
        response = self.table.query(
            IndexName='status-index',
            KeyConditionExpression=Key('status').eq(status),
            FilterExpression=Attr('active').eq(True)
        )
        return response['Items']
    
    def batch_write(self, users: list) -> bool:
        """Efficient batch writing."""
        with self.table.batch_writer() as batch:
            for user in users:
                batch.put_item(Item=user)
        return True
```

## Event-Driven Architecture

### SQS + Lambda with Partial Batch Failures
```python
from typing import Dict, Any
import json

def sqs_handler(event: Dict[str, Any], context) -> Dict[str, Any]:
    """Process SQS messages with proper error handling."""
    failed_messages = []
    
    for record in event['Records']:
        try:
            message = json.loads(record['body'])
            if not process_message(message):
                failed_messages.append({'itemIdentifier': record['messageId']})
        except Exception as e:
            logger.exception(f"Failed: {record['messageId']}")
            failed_messages.append({'itemIdentifier': record['messageId']})
    
    # Return partial batch failures for retry
    return {'batchItemFailures': failed_messages} if failed_messages else {'statusCode': 200}
```

### EventBridge Pattern Matching
```yaml
UserEventRule:
  Type: AWS::Events::Rule
  Properties:
    EventBusName: !Ref CustomEventBus
    EventPattern:
      source: ["myapp.users"]
      detail-type: ["User Created", "User Updated"]
    Targets:
      - Arn: !GetAtt ProcessUserFunction.Arn
        Id: "ProcessUserTarget"
```

## Monitoring and Observability

### CloudWatch Custom Metrics
```python
import boto3
import time
from contextlib import contextmanager

class CloudWatchMetrics:
    def __init__(self, namespace: str):
        self.cloudwatch = boto3.client('cloudwatch')
        self.namespace = namespace
    
    def put_metric(self, name: str, value: float, unit: str = 'Count', dimensions: dict = None):
        """Put custom metric to CloudWatch."""
        metric_data = {
            'MetricName': name,
            'Value': value,
            'Unit': unit,
            'Timestamp': time.time()
        }
        if dimensions:
            metric_data['Dimensions'] = [{'Name': k, 'Value': v} for k, v in dimensions.items()]
        
        self.cloudwatch.put_metric_data(Namespace=self.namespace, MetricData=[metric_data])
    
    @contextmanager
    def timer(self, metric_name: str, dimensions: dict = None):
        """Time operations and emit metrics."""
        start = time.time()
        try:
            yield
        finally:
            duration = (time.time() - start) * 1000
            self.put_metric(metric_name, duration, 'Milliseconds', dimensions)
```

### X-Ray Distributed Tracing
```python
from aws_xray_sdk.core import xray_recorder, patch_all

patch_all()  # Auto-instrument AWS SDK calls

@xray_recorder.capture('database_query')
def query_database(user_id: str) -> dict:
    """Database query with X-Ray tracing."""
    subsegment = xray_recorder.current_subsegment()
    subsegment.put_metadata('user_id', user_id)
    
    try:
        result = database.query(user_id)
        subsegment.put_annotation('success', True)
        return result
    except Exception as e:
        subsegment.put_annotation('success', False)
        subsegment.add_exception(e)
        raise
```

## Cost Optimization

### Lambda Optimization
- Use AWS Lambda Power Tuning for memory sizing
- Implement connection pooling and reuse
- Use provisioned concurrency for consistent traffic
- Batch operations (DynamoDB limit: 25 items)

### S3 Lifecycle Policies
```yaml
S3Bucket:
  Type: AWS::S3::Bucket
  Properties:
    LifecycleConfiguration:
      Rules:
        - Id: ArchiveOldFiles
          Status: Enabled
          Transitions:
            - TransitionInDays: 30
              StorageClass: STANDARD_IA
            - TransitionInDays: 90
              StorageClass: GLACIER
        - Id: DeleteOldLogs
          Status: Enabled
          ExpirationInDays: 2555
          Prefix: logs/
```

## Infrastructure as Code (CDK)

```python
from aws_cdk import Stack, Duration, RemovalPolicy
from aws_cdk import aws_lambda as _lambda
from aws_cdk import aws_apigateway as apigw
from aws_cdk import aws_dynamodb as dynamodb

class ServerlessApiStack(Stack):
    def __init__(self, scope, construct_id, **kwargs):
        super().__init__(scope, construct_id, **kwargs)
        
        # DynamoDB table
        table = dynamodb.Table(
            self, "UserTable",
            partition_key=dynamodb.Attribute(name="id", type=dynamodb.AttributeType.STRING),
            billing_mode=dynamodb.BillingMode.PAY_PER_REQUEST,
            point_in_time_recovery=True,
            removal_policy=RemovalPolicy.DESTROY
        )
        
        # Lambda function
        fn = _lambda.Function(
            self, "UserHandler",
            runtime=_lambda.Runtime.PYTHON_3_11,
            code=_lambda.Code.from_asset("lambda"),
            handler="index.handler",
            timeout=Duration.seconds(30),
            environment={"TABLE_NAME": table.table_name}
        )
        table.grant_read_write_data(fn)
        
        # API Gateway
        api = apigw.RestApi(self, "UserApi", rest_api_name="User Service")
        api.root.add_resource("users").add_method("GET", apigw.LambdaIntegration(fn))
```

## Quick Reference

| Service | Use Case | Key Consideration |
|---------|----------|-------------------|
| Lambda | Event processing, APIs | Cold starts, memory tuning |
| DynamoDB | NoSQL, high throughput | Partition key design, GSI limits |
| S3 | Object storage | Lifecycle policies, encryption |
| SQS | Async messaging | Partial batch failures, DLQ |
| EventBridge | Event routing | Pattern matching syntax |
| API Gateway | REST APIs | Throttling, caching |

## Common Issues

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Lambda timeout | Cold start, slow dependency | Increase timeout, use provisioned concurrency |
| DynamoDB throttling | Hot partition | Redesign partition key, use on-demand |
| S3 403 Forbidden | Bucket policy, IAM | Check both bucket policy AND IAM permissions |
| API Gateway 502 | Lambda error/timeout | Check Lambda logs in CloudWatch |
| CloudFormation rollback | Resource conflict, limits | Read stack events for specific error |

## Troubleshooting Commands

```bash
# CloudFormation
aws cloudformation describe-stack-events --stack-name mystack

# Lambda logs
aws logs tail /aws/lambda/function-name --follow

# DynamoDB metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ConsumedReadCapacityUnits \
  --dimensions Name=TableName,Value=MyTable

# Cost analysis
aws ce get-cost-and-usage \
  --time-period Start=2023-01-01,End=2023-02-01 \
  --granularity MONTHLY \
  --metrics BlendedCost

# Security analysis
aws config get-compliance-details-by-config-rule \
  --config-rule-name s3-bucket-public-read-prohibited
```

## Remember

> AWS is a toolkit, not a solution. Choose the right service for each job, design for failure, and always monitor costs. Security and performance are not afterthoughts.