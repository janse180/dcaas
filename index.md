---
layout: home
title: Cluster in the cloud - expanding your cluster to the cloud
slug: home
permalink: /index.html
---
<p>
</p>


  <section id="lead" class="lead">
    The Cluster in the Cloud project gives you ideas and reference architecture in expanding your cluster to the cloud.
    All solutions provided are based on <a href="http://eresearchsa.github.io/dynamiccluster">Dynamic Cluster</a>.
  </section>

## Overview

Dynamic Cluster is a key element in the deployment of dynamic cluster in the cloud. Apart from that, we also need to consider several things when running a cluster in the cloud.

Some aspects to consider:

- Selection of cloud system
- Authentication Mechanisms of the cloud
- Configuring Workload Managers/Schedulers
- Performance / workload of jobs running in the cloud
- Decision on which jobs to Cloud Burst.
- Network connectivity
- Cloud Security

A typical cluster consists the following components:

* A queueing system and a scheduler
* A central user system
* A shared file system, unless some mechanism to stage in/out files is in place
* A configuration management system, such as puppet or salt stack, or simply use userdata script or cloudinit in the cloud
* A monitoring system

## Reference architecture

We present several reference architecture here to give readers a better idea on how to use <a href="http://eresearchsa.github.io/dynamiccluster">Dynamic Cluster</a>.

It can be used in many different ways. The following setups are just examples.

* All in one: suitable for new users who want to quickly get Dynamic Cluster running in the cloud and learn how to use/configure it.
* Torque HA: this is the model used by eResearch SA to provide cluster in the cloud solution to users.
