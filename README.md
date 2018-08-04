# aws-ec2-amzn2-example

Example project for an EC2 autoscaling setup with Amazon Linux 2

## Deployment

```
make vpc STAGE=dev
```

### Make some requests

```
$ curl ....eu-central-1.elb.amazonaws.com
```

### Get service logs

```
export STAGE=dev AWS_REGION=eu-central-1
awsinfo logs --region ${AWS_REGION} -G -s "-5minutes" aws-ec2-amzn2-example-${STAGE}-ec2/service
```
