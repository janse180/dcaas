---
layout: home
title: Dynamic Cluster as a Service - expanding your cluster to the cloud
slug: home
permalink: /index.html
---
<p>
</p>

# Dynamic Cluster as a Service

  <section id="lead" class="lead">
    The Dynamic Cluster as a Service (DCaaS) project provides solutions for deploying dynamic clusters in the cloud, including reference architectures, example configurations and deployment tools.
    All solutions provided are based on the <a href="http://eresearchsa.github.io/dynamiccluster">Dynamic Cluster</a> software.
  </section>

## Overview

The Dynamic Cluster software enables the deployment of a dynamic cluster in the cloud. Clusters can be configured in a number of different ways, so we also need to consider several things when setting up a cluster in the cloud, including:

- Selection of cloud infrastructure (or middleware)
- Authentication mechanisms of the cloud
- Configuring cluster Workload Managers/Schedulers
- Performance / workload of jobs running in the cloud
- Decision on which jobs to Cloud Burst.
- Network connectivity
- Cloud Security

A typical cluster consists the following components:

* A job management (or queueing) system and a scheduler
* A central user authentication system
* A shared file system, unless some mechanism to stage in/out files is in place
* A configuration management system, such as puppet or salt stack, or simply use userdata script or cloudinit in the cloud
* A monitoring system

DCaaS provides example solutions to enable cluster administrators to easily set up a dynamic cluster in the cloud.

## Reference architecture

Here we present several reference architectures to give clsuter administrators a better idea on how to use <a href="http://eresearchsa.github.io/dynamiccluster">Dynamic Cluster</a> for different requirements.

Dynamic Cluster can be used in many different ways. The following configurations are just example solutions for common requirements.

* [Basic](./basic.html): A single-tenant, single zone cluster, suitable for new users who want to quickly get Dynamic Cluster running in the cloud and learn how to use/configure it. Uses only cloud infrastructure, with a single VM for the key components of the cluster (head node, submit node, NFS server, etc). 
* [Advanced](./advanced.html): Allows multiple tenants and project resource allocations and multiple zones. Can allow use of dedicated servers for key components including the head node, with the cloud used just for worker nodes.
* [Torque High Availability](./torqueha.html): Key components including the head node and submit nodes are set up on dedicated local servers or VMs with an HA configuration.
