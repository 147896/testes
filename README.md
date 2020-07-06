# Teste DevOps

## Testando Infraestrutura como código com Terraform 0.12.

**Criaremos via Terraform os seguintes componentes:**   

* 1x Application Load Balancer  
* 2x EC2 Server  
* Servidor 01 deverá ter Nginx instalado.  
* Servidor 02 deverá ter Apache instalado.  
* 2x security groups  
  - Para o ALB  
  - Para as instancias EC2.  

**Usamos tudo default**  

Preferi criar o ambiente utilizando o que a AWS já disponibiliza como default. Assim, não precisamos nos preocupar em redefinir variáveis ou ajustar o ambiente para utilizar recursos customizados.      

* VPC Default
* Subnet Default
* IAM Role p/ SSM Session  

Assim, construímos a maioria dos itens do teste usando o `Data Sources` do Terraform para consultar os recursos default, citados acima, para servir de parâmetro para as construções dos recursos novos requeridos no teste.  

# Exemplos do trecho que data sources que utilizamos no teste  

```
data "aws_vpc" "default" {
   default = true
}
```  

**Estruturamos da seguinte forma**

- Criamos as instâncias EC2 utilizando o `user_data` do terraform para instalar os pacotes necessários como:  
  * Nginx  
  * Squid
  * Apache  
  * AWS ssm Agent  

- Instalamos adicionalmente o `Squid` para que a instância do `Apache` navegue através da instância do `Nginx`. Assim evitamos de definir um `internet-gateway`, deixando o Nginx assumir um ip publico apenas para outside.  

- Na instância do `Apache` setamos algumas variáveis de ambiente para setar a instância do `Nginx` como proxy de navegação.  
  * `http_proxy="${aws_instance.nginx.private_ip}:3128"`  
  * `https_proxy="${aws_instance.nginx.private_ip}:3128"`  

- Atachamos nas instâncias ec2 do `Nginx` e `Apache` um IAM Role, (que também foi criado via terraform), com uma policy para permissão de `assumeRole` para o SSM Session.  
Isso foi necessário para restringirmos o acesso via SSH às instâncias do `Nginx` e `Apache` apenas da sessão browser via console da AWS.  
Assim, não é necessário possuir, para esse teste, o arquivo .pem para acesso às instâncias.  

- Quando criamos o `Application Load Balancer`, criamos um `Target Group` e registramos a instância do Nginx na porta 80.  
Obs.: O Listener desse `ALB` é o `Target Group` recém criado.   

- Criamos os `Security Groups` para o ALB, Nginx e Apache respectivamente, ficando:   
  * ALB: liberando tráfego do mundo na porta 80. Obs.: Outside não é verdade.   
  * Ngnix: liberando apenas a inbound da rede privada nas portas 80 e 3128 (Squid).   
  * Apache: liberando apenas a inbound da rede privada na porta 80.   

**Antes de rodar o `terraform init`, tenha em mente**  

  - Definir o credentials aws em seu profile com access e secret key da conta `DEV` alvo dos testes.
    - Atachamos a esse usuário uma aws policy direta `AdministratorAccess`. Então, o usuário para os seus testes deverá ter essa policy diretamente atachada.   
  - Ou a utilização do aws-vault chaveando para a profile adequada para os seus testes.   

**Sequência dos comandos adotados, foram**   

  - `git clone https://github.com/147896/testes.git`    
  -  `cd testes`  
  - `terraform init`  
  - `terraform plan`  
  - `terraform apply -auto-approve`  
  -  Acessar o endereço do ALB via browser. Obs.: Esse endereço foi retornado pelo output do terraform.  
    - ALB-<number>.us-east-1.elb.amazonaws.com # para acessar o Nginx  
    -  ALB-<number>.us-east-1.elb.amazonaws.com/apache # para acessar o Apache   

**Referências**  
https://www.terraform.io/docs/providers/aws/  
https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html  


