SERVICE        = aws-ec2-amzn2-example

VENV           = venv
AWS            = venv/bin/aws

# Cloudformation stacks
VPC_STACK_NAME = $(SERVICE)-$(STAGE)-vpc
EC2_STACK_NAME = $(SERVICE)-$(STAGE)-ec2

$(VENV): requirements.txt
	virtualenv --python=python3.6 $(VENV)
	$(VENV)/bin/pip install -r requirements.txt
	touch $(VENV)

$(AWS): $(VENV)

.PHONY: vpc
vpc: $(AWS) guard-STAGE guard-AWS_REGION
	$(AWS) cloudformation deploy --stack-name $(VPC_STACK_NAME) \
		--template-file cloudformation/vpc.yml --capabilities CAPABILITY_NAMED_IAM \
		--region $(AWS_REGION) --no-fail-on-empty-changeset \
		--tags Service=$(SERVICE) \
		       Stage=$(STAGE) \
		--parameter-overrides Service=$(SERVICE) \
		                      Stage=$(STAGE)

.PHONY: deploy-ec2
deploy-ec2: $(AWS) guard-STAGE guard-AWS_REGION
	$(AWS) cloudformation deploy --stack-name $(EC2_STACK_NAME) \
		--template-file cloudformation/ec2.yml --capabilities CAPABILITY_NAMED_IAM \
		--region $(AWS_REGION) --no-fail-on-empty-changeset \
		--tags Service=$(SERVICE) \
		       Stage=$(STAGE) \
		--parameter-overrides Service=$(SERVICE) \
		                      Stage=$(STAGE) \
		                      VpcStack=$(VPC_STACK_NAME)

.PHONY: deploy
deploy: vpc deploy-ec2

.PHONY: guard-%
guard-%:
	@ if [ "${${*}}" = "" ]; then \
             echo "Environment variable $* not set"; \
             exit 1; \
        fi
