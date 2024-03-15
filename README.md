# Modern Datalake Reference Tech Stack
This repo contains the configuration necessary to spin up a MinIO powered open-source and modern data lake. It can be used for training, experimentation, curriculum development, and hands-on demonstration. It is not production-grade.

### System Dependencies
The following system level dependencies must be installed before using this repository. Please refer to the links below for OS specfic instruction on how to install:
* [Docker](https://docs.docker.com/engine/install/)
* [Docker Compose](https://docs.docker.com/compose/install/)
* [mc](https://min.io/docs/minio/linux/reference/minio-mc.html)
* [jq](https://jqlang.github.io/jq/download/)

### Key Components
- [MinIO](https://min.io/docs/minio/linux/index.html) - S3 compatible object storage layer for data
- [Dremio](https://docs.dremio.com/) - A lakehouse management service that offers a data catalog, SQL interface, and Iceberg compatible compute engine.
- [Apache Iceberg](https://iceberg.apache.org/docs/1.3.1/) - The table format we use to store our data in the lake giving us many benefits like ACID compliance, schema evolution, and data time travel.
- [Project Nessie](https://projectnessie.org/) - Git like version control for data.
- [Apache Spark](https://spark.apache.org/docs/latest/) - Our compute engine for data ingestion and transformation.
- [JupyterLab](https://docs.jupyter.org/en/latest/) - An interactive python environment for data science and data engineering.


### Spinning up the environment
1. Copy the .env.example file to .env
    ```bash
    $ cp .env.example .env
    ```
1. We will spin up our services via docker compose.
    ```bash
    $ docker compose --profile with_ipython_notebook up
    ```
1. Log into the minio web UI at http://localhost:9001 using username=minioadmin password=minioadmin
1. In minio create a new bucket called "warehouse". This is where we will be storing our ingested and processed data.
1. Navigate to JupyterLab in your browser at http://127.0.0.1:8888/lab
1. Inside Jupyter run notebooks/spark_table_create.ipynb to use spark to create our first Iceberg table and register it with Nessie.
1. Login to Dremio at http://localhost:9047/ using username=admin password=bad4admins.
1. You should now be able to click on the nessie.names table in Dremio and run the following query to view the data we previously inserted in the spark notebook:
    ```
    SELECT * FROM Nessie.names;
    ```
Congrats you are now running a modern data lake stack entirely on your laptop :-). Feel free to experiment further inside Dremio and Jupyter with SQL and Python respectively.
