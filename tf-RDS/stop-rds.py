import sys
import botocore
import boto3
from botocore.exceptions import ClientError

"""
#def lambda_handler(event, context):
"""
session = boto3.Session(profile_name='rds')
#dev_s3_client = session.client('s3')
rds = session.client('rds',region_name="eu-west-2")
#rds = boto3.client('rds',region_name="eu-west-2",profile_name="rds")
#    lambdaFunc = boto3.client('lambda')

#    print 'Trying to get Environment variable'
"""
    try:
        funcResponse = lambdaFunc.get_function_configuration(
            FunctionName='RDSInstanceStop'
        )

        DBinstance = funcResponse['Environment']['Variables']['DBInstanceName']

        print 'Stoping RDS service for DBInstance : ' + DBinstance

    except ClientError as e:
        print(e)    
"""
db_instances = rds.describe_db_instances()
#for i in range(len(db_instances)):
for i in range(len(db_instances['DBInstances'])):    

            try:
                DBName = db_instances['DBInstances'][i]['DBName']
                

            except KeyError:
                DBName = "+++ DBName gave KeyError +++"
           

            MasterUsername = db_instances['DBInstances'][i]['MasterUsername']
            DBInstanceClass = db_instances['DBInstances'][i]['DBInstanceClass']
            DBInstanceIdentifier = db_instances['DBInstances'][i]['DBInstanceIdentifier']
            DBInstanceState = db_instances['DBInstances'][i]['DBInstanceStatus']

            Endpoint = db_instances['DBInstances'][i]['Endpoint']
            Address = db_instances['DBInstances'][i]['Endpoint']['Address']
            if "dwp" in DBInstanceIdentifier:
                print("{} {} {} {} {} {} {}".format(i, Address, MasterUsername, DBName, DBInstanceClass,DBInstanceIdentifier, DBInstanceState))

                if "available" in DBInstanceState:
                    try:
                        response = rds.stop_db_instance(DBInstanceIdentifier=DBInstanceIdentifier)
                        print('Stop Success :: '+ DBInstanceIdentifier)
                        
                    except ClientError as e:
                            print(e)    
exit()
"""
    return
    {
        'message' : "Script execution completed. See Cloudwatch logs for complete output"
    }
"""
