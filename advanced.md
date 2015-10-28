---
layout: home
title: Dynamic Cluster as a Service - Advanced setup
slug: advanced
permalink: /advanced.html
---
# Advanced Setup

The basic setup creates a cluster with one cloud resource, which runs worker nodes in one tenant/project and in one availability zone. However, Dynamic Cluster allows the use of multiple tenant/project/cloud accounts and multiple availability zones. A resource is a unique combination of a cloud account and an availability zone. 

We present two examples here to demonstrate how to set up multiple availability zones and multiple tenants.

## Multiple availability zones

This setup runs worker nodes in multiple zones with one cloud account. This is a typical use case for a large national research organisation with a large cloud resource allocation.

In order to launch worker nodes in several zones, we add a resource for each zone. For example, the cloud section in Dynamic Cluster's config file would look like:

	cloud:
	  c3-tas:
	    type: openstack
	    reservation:
	      queue:
	      account:
	      property: TAS
	    quantity:
	      min: 10
	      max: 25
	    priority: 5
	    config:
	      username: your_username
	      password: your_password
	      project: your_tenant_name
	      image_uuid: your_image_uuid
	      flavor: m1.large
	      auth_url: https://keystone.rc.nectar.org.au:5000/v2.0/
	      key_name: your_key
	      security_groups:
	        - your_security_group
	      availability_zone: tasmania
	      instance_name_prefix: pbsdyntas
	      userdata_file: /opt/userdata.sh
	  c3-sa:
	    type: openstack
	    reservation:
	      queue:
	      account:
	      property: SA
	    quantity:
	      min: 5
	      max: 10
	    priority: 4
	    config:
	      username: your_username
	      password: your_password
	      project: your_tenant_name
	      image_uuid: your_image_uuid
	      flavor: m1.large
	      auth_url: https://keystone.rc.nectar.org.au:5000/v2.0/
	      key_name: your_key
	      security_groups:
	        - your_security_group
	      availability_zone: sa
	      instance_name_prefix: pbsdynsa
	      userdata_file: /opt/userdata.sh
	  c3-mel:
	    type: openstack
	    reservation:
	      queue:
	      account:
	      property: MEL
	    quantity:
	      min: 10
	      max: 15
	    priority: 4
	    config:
	      username: your_username
	      password: your_password
	      project: your_tenant_name
	      image_uuid: your_image_uuid
	      flavor: m1.large
	      auth_url: https://keystone.rc.nectar.org.au:5000/v2.0/
	      key_name: your_key
	      security_groups:
	        - your_security_group
	      availability_zone: melbourne-qh2
	      instance_name_prefix: pbsdynmel
	      userdata_file: /opt/userdata.sh

Most of the variables can be the same for all resources, but the following ones should be set properly:

* resource name
* reservation -> property
* quantity
* priority
* config -> availability zone
* config -> instance_name_prefix

In Torque, the value of "reservation -> property" will be set to the *property* attribute of a worker node. When a user submits a job, the user can request the job to be distributed to a worker node with that property. In the above example, if a user wants to submit a job to the Melbourne zone, the job script can have the following line:

	#PBS -l nodes=1:ppn=1:MEL

Each resource has quantity values that specifies the minimum number and the maximum number of worker nodes in this resource. Priority shows the order of resources when they are used. A resource with a smaller value comes before one with a bigger value. If they have the same value, the one with less worker nodes comes first. Quantity and priority give users a way to specify distribution of worker nodes among zones.

"Config -> availability zone" is the availability zone that worker nodes will be launched on. "config -> instance_name_prefix" is the name prefix of worker nodes in this resource. Dynamic Cluster uses this name prefix to get a list of instances that belong to this resource. Please be aware that the resource name, reservation property and the zone and name prefix in config should match, otherwise you will create confusion in the setup.

## Multiple cloud accounts (multiple tenants/projects)

Dynamic Cluster has the ability to manage resources on behalf of users, as long as necessary permissions are set up. AWS has a mature and comprehensive authorization system that can manage multiple identities and grant them access to a subset of required permissions. However, this is still evolving in OpenStack. The minimum requirement is that Dynamic Cluster needs an account to start and delete instances for users. There are several ways to do this, although they are not as ideal as the AWS system, and this largely depends on your user policies as to what can be done. One approach is for users to add a cluster administrator to their OpenStack project so that the sysadmin can put their own OpenStack account in Dynamic Cluster to start/delete instances for users. Ideally a service account could instead be created for Dynamic Cluster and then there is no need to use someone's personal account.

Once access is granted, we can set up Dynamic Cluster to make use of it. The following config snippet comes from eRSA's system. The use case here is that there is a shared worker node pool (using eRSA's cloud resource allocation) that is for all users. Each registered tenant/project has a dedicated pool from their cloud resource allocation that is only for users from this tenant/project. Jobs targeted at the dedicated pool should land on compute nodes in the dedicated pool first. If the dedicated pool is full, jobs will overflow to the shared pool. Jobs that are not targeted at any dedicated pool should only land in the shared pool. 

	cloud:
	  default:
	    type: openstack
	    reservation:
	      queue:
	      account:
	      property:
	    quantity:
	      min: 1
	      max: 16
	    priority: 1
	    config:
	      username: your_username
	      password: your_password
	      project: your_tenant_name1
	      image_uuid: your_image_uuid
	      flavor: m1.xlarge
	      auth_url: https://keystone.rc.nectar.org.au:5000/v2.0/
	      key_name: your_key
	      security_groups:
	        - your_security_group
	      availability_zone: sa
	      instance_name_prefix: pbswn-default
	      userdata_file: /etc/dynamiccluster/userdata_salt.sh
	  test:
	    type: openstack
	    reservation:
	      queue:
	      account: test
	      property:
	    quantity:
	      min: 1
	      max: 5
	    priority: 1
	    config:
	      username: your_username
	      password: your_password
	      project: your_tenant_name2
	      image_uuid: your_image_uuid
	      flavor: m1.small
	      auth_url: https://keystone.rc.nectar.org.au:5000/v2.0/
	      key_name: your_key
	      security_groups:
	        - your_security_group
	      availability_zone: sa
	      instance_name_prefix: pbswn-test
	      userdata_file: /etc/dynamiccluster/userdata_salt.sh
	      
In this setup, a sysadmin's account has been added to all user projects that need to use the cluster. That's why *username* and *password* in config are the same. The only difference is *project* in config which indicates which user project to use. Access control on resources is configured in *reservation*. This example has two resources: one _default_ resource that is for all users, and one _test_ resource that is for authorized users only. When a worker node is launched for the _test_resource, Dynamic Cluster will use MAUI's reservation mechanism to create an account reservation. If you run 

	showres -n
	
you'll see something like

	cw-vm-d0fa.sa.nectar.org.au       User             test.1        N/A    1   -INFINITY    INFINITE  Fri Sep 25 14:05:17
	
This means the worker node *cw-vm-d0fa.sa.nectar.org.au* is reserved for the *test* account.

When a user needs to submit a job to this worker node, he/she needs to add the account name in qsub command.

	qsub -A test job.script
	
We can use Torque's submit filter to restrict authorized users to use this account name when submitting the job. If the user is not in the list, submission will be rejected.

The submit filter is configured in torque.cfg ($TORQUE_HOME/torque.cfg).

	SUBMITFILTER /var/spool/torque/qsub_filter
	
and the *qsub_filter* is a script. Here is an example: (the filter script is also used to check other job parameters, e.g. number of cores, memory)

	#!/usr/bin/env python
	# -*- coding: utf-8 -*-
	
	import sys
	import os
	import getpass
	import re
	import pwd
	
	VALID_PROPS=["cloud", "SA"]
	
	def get_tenants(username):
		config_file="/var/spool/torque/accounts.conf"
		with open(config_file) as f:
			content = f.readlines()
		tenants=[]
		for line in content:
			if username in line or '*' in line:
				tenants.append(line.split(" ")[0])
		return tenants
	
	def main(argv=None):
		account_string=None
		node_count=0
		ppn_count=1
	        username=None
		memory=0
		property=None
		for line in sys.stdin:
			sys.stdout.write(line)
			if re.match("^ *#PBS  *-A  *", line):
				account_string=line[line.find(" -A ")+4:].strip()
			if re.match("^ *#PBS  *-l  *", line):
				m=re.search(" *nodes=(.*)", line)
				if m:
					nodes_res=m.groups()[0].split(':')
					if not nodes_res[0].isdigit():
						sys.stderr.write("Nodes number must be an integer.\n")
						return -1
					node_count=int(nodes_res[0])
	                                username=pwd.getpwuid( os.getuid() )[ 0 ]
	                                #sys.stderr.write("GOT USERNAME [%s]\n" % username)
					if node_count>1:
						sys.stderr.write("Sorry, multi-node jobs are currently not supported.\n")
						return -1
					if len(nodes_res)>1 and nodes_res[1].startswith("ppn="):
						ppn_str=nodes_res[1][4:].strip()
						if not ppn_str.isdigit():
							sys.stderr.write("ppn must be an integer.\n")
							return -1
						ppn_count=int(ppn_str)
						if len(nodes_res)>2:
							property=nodes_res[2]
					elif len(nodes_res)>1:
						property=nodes_res[1]
				m=re.search("ncpus=(0*[1-9][0-9]?)", line)
				if m:
					node_count=1
					ppn_count=int(m.groups()[0])
				m=re.search(" *mem=(0*[1-9][0-9]*)([a-zA-Z][a-zA-Z])", line)
				if m:
					memory=int(m.groups()[0])
					mtag=m.groups()[1]
					if mtag.lower() == "gb":
						memory=memory*1024*1024
					elif mtag.lower() == "mb":
						memory=memory*1024
					elif mtag.lower() == "kb":
						memory=memory
					else:
						sys.stderr.write("Memory should be either in Kilo Bytes(kb, KB) or Mega Bytes (mb, MB) or Giga Bytes (gb, GB). Please fix the script.\n")
						return -1
		if node_count>0 and memory>0 and memory/(node_count*ppn_count)>4000000.:
			sys.stderr.write("You have asked for too much memory. In the cloud 4GB memory is allocated for each core. (But in theroy usable memory is a bit less because some are used by the system, etc.) Please fix the script.\n")
			return -1
		for i in range(len(argv)):
			if argv[i]=="-A":
				account_string=argv[i+1]
				break
		tenants=[]
		if account_string is not None:
			tenants=get_tenants(getpass.getuser())
			if account_string not in tenants:
				sys.stderr.write("You are not allowed to submit your jobs to %s\n" % account_string)
				sys.stderr.write("Your valid account strings are %s\n" % tenants)
				return -1
	        if property is not None and property not in (VALID_PROPS+tenants):
	                sys.stderr.write("Sorry, node property must be one in the list %s.\n" % (VALID_PROPS+tenants))
	                return -1
		return 0
	
	
	if __name__ == '__main__':
	    sys.exit(main(sys.argv[1:]))
	
and the user list is in /var/spool/torque/accounts.conf

	test user1 user2 user3
	
Then only user1, user2 and user3 can submit jobs to the *test* resource.
