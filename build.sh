#!/bin/bash

KEY_S3='app.zip'
PROFILE='my-aws'
REGION='us-east-1'
STACK_FILE='stack.yaml'
STACK_NAME='sls-api-crud'
BUCKET_NAME='sls-lambda-code-bucket'
CODEBUILD_SRC_DIR='/home/leonardo/Documentos/api-serverless'

function buildZip {
  if test -f "$CODEBUILD_SRC_DIR/$KEY_S3"; then
      rm -rf $CODEBUILD_SRC_DIR/$KEY_S3
  fi

  if test -d "$CODEBUILD_SRC_DIR/app/.venv"; then
      rm -rf $CODEBUILD_SRC_DIR/app/.venv
  fi

  find . | grep -E '(__pycache__|\.pyc|\.pyo$)' | xargs rm -rf

  echo '================= DOWNLOADING DEPENDENCIES ================'
  cd $CODEBUILD_SRC_DIR/app
  poetry install --no-dev

  echo '====================== BUILD PACKAGES ======================'
  zip -r9 $CODEBUILD_SRC_DIR/$KEY_S3 . -x '*.venv*' '*.env*' '*poetry.lock*' '*__pycache__/*' '*.vscode/*' '*manage.py*' '*htmlcov/*' '*.pytest_cache/*' '*tests/*'
  cd $CODEBUILD_SRC_DIR/app/.venv/lib/*/site-packages
  zip -ru9 $CODEBUILD_SRC_DIR/$KEY_S3 . -x '*__pycache__/*' '*_distutils_hack/*' '*pip*' '*pkg_resources/*' '*setuptools*' '*wheel*' '*_virtualenv*' '*distutils-precedence*' '*.dist-info*'
  cd $CODEBUILD_SRC_DIR

  echo '========================== MD5SUM =========================='
  md5sum $KEY_S3
}

function buildClean {
  rm -rf $KEY_S3 app/poetry.lock app/.venv/
}

if [ $1 == 'deploy' ]; then
  buildZip

  echo "========================== CREATE BUCKET =========================="
  is_exists_bucket=false
  buckets=$(aws s3 ls --profile $PROFILE --region $REGION)

  for buck in $buckets; do
    if [ $buck == $BUCKET_NAME ]; then
      is_exists_bucket=true
    fi
  done

  if [ $is_exists_bucket == false ]; then
    aws s3api create-bucket \
      --bucket $BUCKET_NAME \
      --region $REGION \
      --profile $PROFILE

  else
    echo "Bucket $BUCKET_NAME already exists."
  fi

  echo "========================== UPLOAD =========================="
  if ! find $CODEBUILD_SRC_DIR -name $KEY_S3; then
    echo "File $KEY_S3 is not exists."

  else
    aws s3 cp $KEY_S3 s3://$BUCKET_NAME/$KEY_S3 --profile $PROFILE --region $REGION
  fi

  echo "========================== DEPLOY STACK =========================="
  if ! aws cloudformation describe-stacks --region $REGION --profile $PROFILE --stack-name $STACK_NAME; then
    aws cloudformation deploy \
      --template $CODEBUILD_SRC_DIR/$STACK_FILE \
      --stack-name $STACK_NAME \
      --region $REGION \
      --profile $PROFILE \
      --capabilities CAPABILITY_NAMED_IAM \
      --no-fail-on-empty-changeset

  else
    echo "Stack $STACK_NAME already exists."
  fi

  buildClean

elif [ $1 == 'update' ]; then
  buildZip

  echo "========================== UPDATE CODE FUNCTIONS =========================="
  is_exists_bucket=false
  buckets=$(aws s3 ls --profile $PROFILE --region $REGION)

  for buck in $buckets; do
    if [ $buck == $BUCKET_NAME ]; then
      is_exists_bucket=true
    fi
  done

  if [ $is_exists_bucket == false ]; then
    echo "Bucket $BUCKET_NAME not found."

  else
    aws s3 cp $KEY_S3 s3://$BUCKET_NAME/$KEY_S3 --profile $PROFILE --region $REGION
  fi

  if ! aws cloudformation describe-stacks --region $REGION --profile $PROFILE --stack-name $STACK_NAME; then
    echo "Stack $STACK_NAME does not exist, please run deploy."

  else
    aws cloudformation deploy \
      --template $CODEBUILD_SRC_DIR/$STACK_FILE \
      --stack-name $STACK_NAME \
      --region $REGION \
      --profile $PROFILE \
      --capabilities CAPABILITY_NAMED_IAM \
      --no-fail-on-empty-changeset
  fi

  # List of functions to update.
  aws lambda update-function-code \
    --function-name slsFunc \
    --s3-bucket $BUCKET_NAME \
    --s3-key $KEY_S3 \
    --region $REGION \
    --profile $PROFILE

  aws lambda update-function-code \
    --function-name slsAuth \
    --s3-bucket $BUCKET_NAME \
    --s3-key $KEY_S3 \
    --region $REGION \
    --profile $PROFILE

  buildClean

elif [ $1 == 'clean' ]; then
  echo "========================== DELETE BUCKET =========================="
  is_exists_bucket=false
  buckets=$(aws s3 ls --profile $PROFILE --region $REGION)

  for buck in $buckets; do
    if [ $buck == $BUCKET_NAME ]; then
      is_exists_bucket=true
    fi
  done

  if [ $is_exists_bucket == true ]; then
    aws s3 rm "s3://$BUCKET_NAME" \
      --recursive \
      --region $REGION \
      --profile $PROFILE

    aws s3api delete-bucket \
      --bucket $BUCKET_NAME \
      --region $REGION \
      --profile $PROFILE

  else
    echo "Bucket $BUCKET_NAME not found."
  fi

  echo "========================== DELETE STACK =========================="
  if ! aws cloudformation describe-stacks --region $REGION --profile $PROFILE --stack-name $STACK_NAME; then
    echo "Stack $STACK_NAME not found."

  else
    aws cloudformation delete-stack \
      --stack-name $STACK_NAME \
      --region $REGION \
      --profile $PROFILE
  fi

  buildClean

fi

