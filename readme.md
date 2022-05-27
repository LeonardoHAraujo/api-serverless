# API Serverless AWS

*Powered by Leonardo Araújo*

Creation of an initial structure to implement a gateway api with cloudformation.

## How to run

- Parameterize your `build.sh` with the necessary information according to your aws. Example:

    ```
    KEY_S3='app.zip' # Name of file zip/code.
    PROFILE='my-aws' # Your profile in aws (~/.aws/credentials).
    REGION='us-east-1' # A região que deseja operar.
    STACK_FILE='stack.yaml' # Name file for your stack cloudformation.
    STACK_NAME='sls-api-crud' # Name of stack into cloudformation aws.
    BUCKET_NAME='sls-lambda-code-bucket' # Bucket name for store code.
    CODEBUILD_SRC_DIR='/home/leonardo/Documentos/api-serverless' # Directory.
    ```

- After this, you can run the following commands:
    - `./build.sh deploy`
    - `./build.sh update`
    - `./build.sh clean`

    ```
    deploy: Make upload of code and create stack.
    update: Update code of functions list in build and update stack.
    clean: Delete all. Bucket with code and stack clear.
    ```

- After this, can you developer a structure of code and stack, because the deploy is automatic.

