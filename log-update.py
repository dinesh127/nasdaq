import boto3
import os

# Configuration
s3_bucket = 'your-s3-bucket-name'
log_directory = '/var/log/'
log_files = ['syslog', 'auth.log']  # Add more log files if needed
s3_client = boto3.client('s3')

def upload_log_to_s3(file_name, s3_bucket, s3_key):
    try:
        s3_client.upload_file(file_name, s3_bucket, s3_key)
        print(f"Uploaded {file_name} to s3://{s3_bucket}/{s3_key}")
    except Exception as e:
        print(f"Error uploading {file_name}: {e}")

def export_logs():
    for log_file in log_files:
        file_path = os.path.join(log_directory, log_file)
        if os.path.exists(file_path):
            upload_log_to_s3(file_path, s3_bucket, log_file)
        else:
            print(f"{file_path} does not exist")

if __name__ == "__main__":
    export_logs()
