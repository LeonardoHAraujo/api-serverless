#!/bin/bash
CODEBUILD_SRC_DIR='/home/leonardo/Documentos/api-serverless'
BUCKET_NAME='sls-lambda-code-bucket'

buildZip() {
  if test -f "$CODEBUILD_SRC_DIR/app.zip"; then
      rm -rf $CODEBUILD_SRC_DIR/app.zip
  fi

  if test -d "$CODEBUILD_SRC_DIR/app/.venv"; then
      rm -rf $CODEBUILD_SRC_DIR/app/.venv
  fi

  find . | grep -E '(__pycache__|\.pyc|\.pyo$)' | xargs rm -rf

  echo '================= DOWNLOADING DEPENDENCIES ================'
  cd $CODEBUILD_SRC_DIR/app
  poetry install --no-dev

  echo '====================== BUILD PACKAGES ======================'
  zip -r9 $CODEBUILD_SRC_DIR/app.zip . -x '*.venv*' '*.env*' '*poetry.lock*' '*__pycache__/*' '*.vscode/*' '*manage.py*' '*htmlcov/*' '*.pytest_cache/*' '*tests/*'
  cd $CODEBUILD_SRC_DIR/app/.venv/lib/*/site-packages
  zip -ru9 $CODEBUILD_SRC_DIR/app.zip . -x '*__pycache__/*' '*_distutils_hack/*' '*pip*' '*pkg_resources/*' '*setuptools*' '*wheel*' '*_virtualenv*' '*distutils-precedence*' '*.dist-info*'
  cd $CODEBUILD_SRC_DIR

  echo '========================== MD5SUM =========================='
  md5sum app.zip
}

if [ $1 == 'deploy' ]; then
  buildZip

  echo "========================== CREATE BUCKET =========================="
  aws s3api create-bucket \
      --bucket $BUCKET_NAME \
      --region us-east-1 \
      --profile my-aws

  echo "========================== UPLOAD =========================="
  aws s3 cp app.zip s3://$BUCKET_NAME/app.zip --profile my-aws --region us-east-1

  echo "========================== DEPLOY STACK =========================="
  aws cloudformation deploy \
    --template $CODEBUILD_SRC_DIR/stack.yaml \
    --stack-name sls-api-crud \
    --region us-east-1 \
    --profile my-aws \
    --capabilities CAPABILITY_NAMED_IAM \
    --no-fail-on-empty-changeset
fi


# aws s3 api list-object-versions --bucket $BUCKET_NAME --prefix $PIPELINE_NAME/app.zip --max-items 1 > artifactVersion.json --profile lets-prd --region us-east-1
# echo $(ls -lh "$CODEBUILD_SRC_DIR/app.zip")
# rm $CODEBUILD_SRC_DIR/art

# aws lambda update-function-code --function-name LambdaName --zip-file fileb://app.zip --profile lets-prd
