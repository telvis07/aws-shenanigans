Create a DynamoDB table with `cars` data with streaming enabled. Trigger a lambda for stream events.

Uses `cars` database from AWS certication class: https://bitbucket.org/awsdevguru/awsdevassoc/src/master/DynamoDB/

### Setup

```bash
# runs terraform fmt, validate, plan and apply
make apply

# insert rows
python3 insert_rows.py

# update rows
python3 update_rows.py

# run terraform destroy
make destroy
```


References:
* https://bitbucket.org/awsdevguru/awsdevassoc/src/master/DynamoDB/
* https://docs.aws.amazon.com/lambda/latest/dg/with-ddb-example.html
* https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html
* https://developer.hashicorp.com/terraform/tutorials/aws/lambda-api-gateway