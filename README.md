[[_TOC_]]





# Devops Engineer Code Challenge



## Challenge 1 - Chart de Helm



#### Contexto

Modifica el "Ping Helm Chart" para desplegar la aplicación con las siguientes restricciones:

- Aislar grupos de nodos específicos prohibiendo el sheduling de pods en estos grupos de nodos --> **Taint**
  - Suponemos que los nodos tienen un taint. Un "taint" por definición, prohíbe el scheduling de todos aquellos pods que no lo "toleren"
  - Dado que es una restricción estricta, se usará `requiredDuringSchedulingIgnoredDuringExecution`
- Asegúrese de que no se asigne (schedule) un pod en un nodo que ya tenga un pod del mismo tipo. --> **Antiafinidad**
  - Los pods se despliegan en diferentes zonas de disponibilidad. Deberemos hacer uso de `topologyKey`



#### **Solución**

El Chart se encuentra en challenge1

Dado que no se especifica cual es el "Ping Helm Chart" ni se facilita ningún enlace, se va a crear y desplegar un Chart de ejemplo:

```yaml
# Esto crea un chart con una nginx de ejemplo
helm create ping
```

Este Chart permite definir tolerations y tains. Editamos el fichero `values.yaml` y añadimos:

```yaml
# A modo de ejemplo, esta aplicación solo tolera el tain type=apps
tolerations:
- key: "type"
  operator: "Equal"
  value: "apps"
  effect: "NoSchedule"

# Dado que se especifica que solo puede haber estrictamente un pod por zona, se configura requiredDuringSchedulingIgnoredDuringExecution y topology.kubernetes.io/zone
# kubernetes.io/hostname        - Un pod por nodo --> Pruebas en local
# topology.kubernetes.io/zone   - Un pod por zona --> El que se especifica en el challenge que deberemos usar en los cluster AKS
# topology.kubernetes.io/region - Un pod por region
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          app: ping
      topologyKey: kubernetes.io/hostname
```

Desplegamos:

```bash
helm -n test install ping ./ping --values values.yaml

kubectl taint node nodo1 type=apps:NoSchedule
kubectl taint node nodo2 type=apps:NoSchedule
kubectl taint node nodo3 type=infra:NoSchedule # En este nodo no se podrá ejecutar la aplicacion

kubectl -n test scale deployment ping --replicas=3
```

Verificamos que se comporta como se espera:

IMAGENES

Finalmente la empaquetamos:

- Chart: ping
- Version: 0.1.0

```bash
helm package .
```



## Challenge 2 - Desplegar con Terraform



#### Contexto

Tenemos el siguiente escenario:

- Private Registry basado en Azure Container Registry (ACR) --> **reference.azurecr.io**
- Instancia de AKS + ACR --> **instance.azurecr.io**

Todos los Charts se encuentran en el ACR principal. 

Se nos pide:

- Crear un módulo Terraform reutilizable, de forma que cada vez que se cree una instancia nueva (AKS+ACR) copie los Charts al nuevo registry y los despliegue en el clúster
- Usar un local provider
- Debe pasar las validaciones proporcionadas por los comandos `terraform fmt` y `terraform validate`.
- Debe tener el siguiente formato:

```
module "chart" {
    . . .
    acr_server = "instance.azurecr.io"
    acr_server_subscription = "c9e7611c-d508-4fbf-aede-0bedfabc1560"
    source_acr_client_id = "1b2f651e-b99c-4720-9ff1-ede324b8ae30"
    source_acr_client_secret = "Zrrr8~5~F2Xiaaaa7eS.S85SXXAAfTYizZEF1cRp"
    source_acr_server = "reference.azurecr.io"
    charts = [
        {
            chart_name = <chart_name>
            chart_namespace = <chart_namespace>
            chart_repository = <chart_repository>
            chart_version = <chart_version>
            values = [
                {
                    name = <name>
                    value = <value>
                },
                {
                    name = <name>
                    value = <value>
                }
            ]
            sensitive_values = [
                {
                    name = <name>
                    value = <value>
                },
                {
                    name = <name>
                    value = <value>
                }
            ]
        },
        {
        . . .
        }
    ]
}
```



#### Solución

Para el desarrollo y validación del módulo se ha simulado un entorno en Azure con la cuenta gratuita, donde se ha desplegado:

- Un ACR de referencia
- Un instancia AKS+ACR

Para más info ver el anexo

El módulo se encuentra en challenge2

En definitiva, para lanzar el despliegue debemos

```bash
# Inicializar el directorio de trabajo
terraform init

# Pasar los checks
terraform validate
terraform fmt
terraform plan

# Lanzamos el terraform
terraform apply
```

Finalmente verificamos que la aplicación está ejecutándose en el nuevo clúster

```bash
helm --kubeconfig kubeconfig list -A
NAME    NAMESPACE       REVISION        UPDATED                                         STATUS          CHART           APP VERSION
ping    test            1               2023-10-15 19:30:01.460642195 +0200 CEST        deployed        ping-0.1.0      1.16.0

kubectl --kubeconfig kubeconfig -n test get all
NAME                        READY   STATUS    RESTARTS   AGE
pod/ping-657bdc6fc9-jh8pv   1/1     Running   0          81s

NAME           TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/ping   ClusterIP   10.0.100.186   <none>        80/TCP    81s

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ping   1/1     1            1           81s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/ping-657bdc6fc9   1         1         1       81s
```









# Anexo: desplegar entorno

Haciendo uso de la licencia gratuita, se ha simulado en entorno para poder validar el proceso

Todos los despliegues se han realizado con terraform y los ficheros se encuentran en anexo



## ACR referencia

La única especificación es que el formato debe ser: reference.azurecr.io

Usaremos este ACR cono repositorio principal. Aquí se encontraran todas las imágenes y charts.





## AKS+ACR instancia

Como disponemos de la versión gratuita, se ha creado un clúster de kubernetes (AKS) mínimo, con un único nodo.

En cuanto al ACR, el único requisito es que tuviera el formato instance.azurecr.io, que debe ser único globalmente en Azure y ya estaba cogido, por lo que se ha nombrado como `instance20231014`





