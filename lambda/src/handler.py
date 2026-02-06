import os
import subprocess
import boto3
import urllib.parse

# Initialize the S3 Client outside the handler (Best Practice: Connection Reuse)
s3 = boto3.client('s3')

def lambda_handler(event, context):
    # 1. Extract Bucket and Key from the S3 Event
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    # Keys can have spaces or special chars encoded as '+' or '%20'
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
    
    # Define paths
    download_path = f"/tmp/{os.path.basename(key)}"
    output_path = f"/tmp/processed-{os.path.basename(key)}"
    dest_bucket = os.environ['DEST_BUCKET']

    try:
        print(f"Starting processing for {source_bucket}/{key}")

        # 2. Download the file from S3 to Lambda's local /tmp
        s3.download_file(source_bucket, key, download_path)

        # 3. Call a Bash Script or Binary (The "Internal" Way)
        # Here we use 'convert' (from ImageMagick) or a custom bash script.
        # For this example, let's assume we have a simple shell script in our Layer or Src.
        # We'll use a standard shell command to 'compress' via a subprocess.
        
        # Example: Using a shell command to resize via the 'Pillow' logic 
        # but triggered through a bash-like orchestration
        process_command = f"cp {download_path} {output_path}" # Placeholder for real logic
        subprocess.run(process_command, shell=True, check=True)
        
        # 4. Upload the processed file to the Destination Bucket
        s3.upload_file(output_path, dest_bucket, f"resized-{os.path.basename(key)}")
        
        print(f"Successfully processed and uploaded to {dest_bucket}")

    except Exception as e:
        print(f"Error: {e}")
        raise e
    finally:
        # 5. Clean up /tmp to keep the 'Warm' container fresh
        if os.path.exists(download_path):
            os.remove(download_path)
        if os.path.exists(output_path):
            os.remove(output_path)

    return {"status": "200", "message": "Image Processed"}