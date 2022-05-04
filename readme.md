# API Serverless AWS

Criação de estrutura inicial para implementação de uma api gateway com cloudformation.

Como rodar:
- Parametrize o seu `build.sh` com as informações necessárias de acordo com sua aws. Exemplo:

    ```
    KEY_S3='app.zip' # Nome do arquivo zip/code.
    PROFILE='my-aws' # Seu profile na aws (~/.aws/credentials).
    REGION='us-east-1' # A região que deseja operar.
    STACK_FILE='stack.yaml' # A pilha para seu cloudformation.
    STACK_NAME='sls-api-crud' # Nome da pilha la no cloudformation da aws.
    BUCKET_NAME='sls-lambda-code-bucket' # Nome do bucket para guardar o code.
    CODEBUILD_SRC_DIR='/home/leonardo/Documentos/api-serverless' # Diretório.
    ```

- Após isso você poderá rodar três comandos.
    - `./build.sh deploy`
    - `./build.sh update`
    - `./build.sh clean`


    ```
    deploy: Faz upload do código e constrói toda a pilha.
    update: Atualiza código das funções listadas nele e atualiza a pilha.
    clean: Apaga tudo. Desde o bucket com o código ate a pilha.
    ```

- Após isso, basta desenvolver a estrutura do código e a pilha, pois a infra é automatizada para deploy.

