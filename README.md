# Modern Datalake Reference Tech Stack
This repo contains the configuration necessary to spin up a MinIO powered open-source and modern datalake. It can be used for training, experimentation, and hands-on demonstration. It is not production-grade.

## Modern Datalake on MinIO Training
This datalake is pre-configured for ease of use with the guided exercises in the [MinIO Modern Datalakes](https://www.youtube.com/@MINIO) training series on youtube. Follow along with the guided exercises there to learn more.

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
1. We will spin up Dremio, Nessie, and MinIO via docker compose.
    ```bash
    $ docker compose up -d
    ```
1. Tail the docker compose logs with and wait until you see the following indicating all containers have started up:
    ```
    $ docker compose logs -f
    ...output truncated...

    dremio  | 2024-03-25 18:08:25,886 [main] INFO  com.dremio.dac.server.DremioServer - Started on http://localhost:9047
    dremio  | Dremio Daemon Started as master
    ```
1. Using the mc command line tool create an alias for the minio server called minio1. Then create a bucket called warehouse where we will store our iceberg tables and metadata.
    ```bash
    $ mc alias set minio1 http://localhost:9050 minioadmin minioadmin
    Added `minio1` successfully.

    $ mc mb minio1/warehouse
    Bucket created successfully `minio1/warehouse`.
    ```
1. Execute the dremio initialization script which will create the first user and setup the connection between Dremio, Nessie, and MinIO
    ```bash
    $ sh init_dremio.sh
    ...output truncated...

    -----------------------------------------------
    Dremio first time lab initialization complete
    -----------------------------------------------
    ```
1. Login to Dremio at http://localhost:9053/ using username=admin password=bad4admins.
1. You should now be able to run [SQL](https://docs.dremio.com/current/reference/sql) commands using the Dremio SQL runner against the iceberg tables in the datalake. For example you can try this:
    ```SQL
    # Create a fact_orders table partitioned by day:
    CREATE TABLE nessie.fact_orders
    (
        order_id     BIGINT,
        customer_id  BIGINT,
        order_amount DECIMAL (10, 2),
        order_ts     TIMESTAMP
    ) PARTITION BY (DAY (order_ts));

    # Insert three rows into the fact_orders table:
    INSERT INTO nessie.fact_orders
    VALUES (111, 456, 36.17, '2024-01-07 08:12:23'),
       (112, 789, 67.15, '2024-01-07 08:23:00'),
       (113, 789, 21.00, '2024-01-08 11:12:23');

    # Retrieve all the inserted rows to view them:
    SELECT * FROM Nessie.fact_orders;
    ```

Congrats you are now running a modern data lake stack powered by MinIO entirely on your machine :-).

### Optional Spark Notebooks
If you would like to interact with Iceberg tables using Python and Spark instead of Dremio and SQL simply do the following:

1. Startup a Jupyter Labs notebook container that is configured to run Apache Spark as a single node cluster.
    ```bash
    $ docker compose --profile with_ipython_notebook up -d
    ```
1. Navigate to JupyterLab in your browser at http://127.0.0.1:9070/lab
1. Inside Jupyter run spark_table_create.ipynb to create an example iceberg table and register it with Nessie. 

You can switch back and forth between Dremio/Spark and SQL/Python respectively. Modern datalakes make it relatively easy to swap in and out components like compute engines, runtime evironments, table formats etc.

### Tearing down the environment
1. Spin down all containers and delete volumes with this command
    ```bash
    $ docker compose --profile with_ipython_notebook down --volumes
    ```
