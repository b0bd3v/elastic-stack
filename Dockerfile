# Use the official Ubuntu 20.04 as a base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    apt-transport-https \
    openjdk-11-jdk \
    gnupg && \
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list' && \
    apt-get update && \
    apt-get install -y elasticsearch && \
    apt-get clean

# Update Elasticsearch configuration
RUN sed -i 's/#node.name: node-1/node.name: node-1/' /etc/elasticsearch/elasticsearch.yml && \
    sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml && \
    sed -i 's/#discovery.seed_hosts: \["host1", "host2"\]/discovery.seed_hosts: ["127.0.0.1"]/' /etc/elasticsearch/elasticsearch.yml && \
    sed -i 's/#cluster.initial_master_nodes: \["node-1", "node-2"\]/cluster.initial_master_nodes: ["node-1"]/' /etc/elasticsearch/elasticsearch.yml

# Change ownership of Elasticsearch files
RUN chown -R elasticsearch:elasticsearch /var/lib/elasticsearch /var/log/elasticsearch

# Start Elasticsearch service
RUN service elasticsearch start

# Expose ports for HTTP (9200) and transport (9300)
EXPOSE 9200 9300

# Switch to elasticsearch user
USER elasticsearch

# Set the command to run Elasticsearch
CMD ["/usr/share/elasticsearch/bin/elasticsearch", "-E", "discovery.type=single-node"]
