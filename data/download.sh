#!/bin/bash

# Download all the parquet files from opensky flights sample dataset https://opensky-network.org/datasets/flights_data5_develop_sample/
wget -O- https://opensky-network.org/datasets/flights_data5_develop_sample/ | grep -oE 'flights_data5_develop_sample_.*?parquet' | xargs -n 1 -I {} echo "https://opensky-network.org/datasets/flights_data5_develop_sample/{}" | uniq | xargs -P 10 -n 1 wget