# Modern Datalake Reference Architecture
This repo contains the configuration necessary to spin up a MinIO powered open-source and modern data lake. It can be used for training, experimentation, curriculum development, and hands-on demonstration. It is not production-grade.

### Key Components
- [MinIO](https://min.io/docs/minio/linux/index.html) - S3 compatible object storage layer for data
- [Dremio](https://docs.dremio.com/) - A lakehouse management service that offers a data catalog, SQL interface, and Iceberg compatible compute engine.
- [Apache Iceberg](https://iceberg.apache.org/docs/1.3.1/) - The table format we use to store our data in the lake giving us many benefits like ACID compliance, schema evolution, and data time travel.
- [Project Nessie](https://projectnessie.org/) - Git like version control for data.
- [Apache Spark](https://spark.apache.org/docs/latest/) - Our compute engine for data ingestion and transformation.
- [Jupyter Notebooks](https://docs.jupyter.org/en/latest/) - An interactive python environment for data science and data engineering.

### Building the Docker Image locally
Note that our docker-compose.yml references a local image for spark_notebook that needs to be built before we can spin up the environment with compose.
```bash
$ docker build -t spark_notebook .
```


### Spinning up the environment
We will spin up our docker services individually in separate terminals to make logging easier to track.
1. Copy the .env.example file to .env
    ```bash
    $ cp .env.example .env
    ```
1. Spin up minio
    ```bash
    $ docker-compose up minioserver
    ```
1. Log into the minio web UI at localhost:9001 using username=minioadmin password=minioadmin
1. In minio create a new bucket called "warehouse". This is where we will be storing our ingested and processed data.
1. In minio create an access key - copy the access key and secret key into the .env file in the root under MINIO_ACCESS_KEY and MINIO_SECRET_ACCESS_KEY respectively.
1. Spin up jupyter notebooks with spark
    ```bash
    $ docker compose up spark_notebook
    ```
1. Spin up the remaining services in the compose file
    ```bash
    $ docker compose up nessie dremio
    ```
1. Login to jupyter notebooks using the login URL+token. You will find this inside the logs of the spark_notebook container and it generally looks something like this:
    ```
        To access the server, open this file in a browser:
            file:///home/docker/.local/share/jupyter/runtime/jpserver-12-open.html
        Or copy and paste one of these URLs:
            http://aa164f013267:8888/tree?token=37ef29fcfb6179914503d30d17ba470ba1e3a38d23468644
            http://127.0.0.1:8888/tree?token=37ef29fcfb6179914503d30d17ba470ba1e3a38d23468644
    ```
1. Inside Jupyter run notebooks/spark_table_create.ipynb to use spark to create our first Iceberg table and register it with Nessie.
1. Login to Dremio at http://localhost:9047/ . You will need create a new admin account in order login.
1. Now lets add Nessie as a catalog inside Dremio so we can easily query our tables. To do this click on Add Source and Select Nessie. Use the following values:
    ```
    General Section
        Name=Nessie
        Nessie Endpoint URL=http://nessie:19120/api/v2
        Nessie Authentication Type=None
    Storage Section
        AWS Root path=s3://warehouse
        AWS Access Key=[MINIO_ACCESS_KEY from .env]
        AWS Secret Key=[MINIO_SECRET_ACCESS_KEY from .env]
        Encrypt Connection=Unchecked
    ```
1. Add the following custom connection properties and then add the source to Dremio:
    ```
        Name: fs.s3a.path.style.access Value: true
        Name: fs.s3a.endpoint Value: minio:9000
        Name: dremio.s3.compat Value: true
    ```

1. You should now be able to click on the nessie.names table in Dremio and run the following query to view the data we previously inserted in the spark notebook:
    ```
    SELECT * FROM Nessie.names;
    ```
Congrats you are now running a modern data lake stack entirely on your laptop :-)