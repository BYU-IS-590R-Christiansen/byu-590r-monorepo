#!/bin/bash

# Script to upload book images to S3 bucket
# Usage: upload_images.sh <bucket_name> <books_directory>

set -e

BUCKET_NAME=$1
BOOKS_DIR=$2

if [ -z "$BUCKET_NAME" ]; then
    echo "Error: S3 bucket name not provided"
    exit 1
fi

if [ -z "$BOOKS_DIR" ]; then
    echo "Error: Books directory not provided"
    exit 1
fi

if [ ! -d "$BOOKS_DIR" ]; then
    echo "Warning: Book images directory not found: $BOOKS_DIR"
    echo "Skipping book image upload - directory will be created during deployment"
    exit 0
fi

# Files to upload (only the ones used in the seeder)
FILES_TO_UPLOAD=(
    "hp1.jpeg"
    "hp2.jpeg"
    "hp3.jpeg"
    "hp4.jpeg"
    "hp5.jpeg"
    "hp6.jpeg"
    "hp7.jpeg"
    "mb1.jpg"
    "mb2.jpg"
    "mb3.jpg"
    "bom.jpg"
)

UPLOADED_COUNT=0

for local_file in "${FILES_TO_UPLOAD[@]}"; do
    s3_key="images/$local_file"
    local_path="$BOOKS_DIR/$local_file"
    
    if [ -f "$local_path" ]; then
        echo "Uploading $local_file to s3://$BUCKET_NAME/$s3_key"
        
        # Upload without ACL since bucket has public access blocked
        # Retry up to 3 times if upload fails
        MAX_RETRIES=3
        RETRY=0
        UPLOAD_SUCCESS=false
        
        while [ $RETRY -lt $MAX_RETRIES ] && [ "$UPLOAD_SUCCESS" = false ]; do
            if aws s3 cp "$local_path" "s3://$BUCKET_NAME/$s3_key" 2>/dev/null; then
                ((UPLOADED_COUNT++))
                echo "Uploaded $local_file successfully"
                UPLOAD_SUCCESS=true
            else
                ((RETRY++))
                if [ $RETRY -lt $MAX_RETRIES ]; then
                    echo "Upload attempt $RETRY failed, retrying in 2 seconds..."
                    sleep 2
                else
                    echo "Failed to upload $local_file after $MAX_RETRIES attempts"
                fi
            fi
        done
    else
        echo "Warning: File not found: $local_path"
    fi
done

if [ $UPLOADED_COUNT -gt 0 ]; then
    echo "Uploaded $UPLOADED_COUNT book images to S3 under /images folder"
else
    echo "Warning: No book images were uploaded"
fi

exit 0

