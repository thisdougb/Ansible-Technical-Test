# Technical Test Response

I bring up three nodes (app1, app2, web1) with Vagrant, and provision them with Ansible.   I use the vanilla ‘precise64’ Vagrant box without specifying or configuring provider, solely for portability.   For this test implementation I define static IPs within the Vagrantfile, these are automatically passed through to Ansible (used in nginx.conf template, and /etc/hosts) so only need to be defined once.   For readability I define Ansible groups also within the Vagrantfile, making it simple to increase the number of nodes (and their IPs) from within this single file.

I tell Ansible to wait for the application servers to become active (a port 8484 check) before starting nginx on the web1 node.   In a live environment we would do more than a simple port check, but it shows how a service can be provisioned as a whole rather than simply bringing up individual VMs and hoping they all came up in a consistent state.   Thus we ensure that our end-end service only becomes live if the application tier is ready for requests.

With a larger repo of code I’d be more inclined to checkout/compile the code on the Ansible host and deploy only the compiled binaries.   However with only a couple of code files it’s simpler to do a git checkout on the app nodes, this also avoids additional dependencies on the Vagrant/Ansible host machine.    I also chose to install the Go app/binary as a service, because it makes subsequent code deployments simpler and takes advantage of Ansible tasks to perform checks and control.   This avoids writing custom error checking or helper scripts.

I’ve included a simple shell script (./testApplication.sh) to make testing the application easier/quicker.   The script makes six http calls to the web1 node, echoing the output returned.   The url is http://192.168.33.10/ if you prefer to use a web browser for validation.

The requirement to validate the application after deployment was, to me, a little ambiguous in terms of testing during the 'single command' provisioning run.   I have assumed it was a requirement to have a 'yes or no' decision on the final state of the environment.   So I added an Ansible task to call the testApplication.sh script, and check each app node is in the output, failing if one is missing.  This runs at the end of the deployment, but is dependent on curl existing on the Ansible host (not checked for).   My intention here is to show the testing of web application content, rather than simply checking a port is open.

To prepare the environment:
```
$ git clone git@github.com:thisdougb/TechnicalTest.git
$ cd TechnicalTest
```

To launch and provision the environment:
```
$ vagrant up
$ sh testApplication.sh
Hi there, I'm served from app1!
Hi there, I'm served from app2!
Hi there, I'm served from app1!
Hi there, I'm served from app2!
Hi there, I'm served from app1!
Hi there, I'm served from app2!
```


######Bonus Point

Ansible’s orchestration power gives us the ability to perform abstract changes across multi-tier environments, while still being understandable and readable by your colleagues.   Here I use orchestration in its simplest form, ‘*for changes to the sample code, automate the build and delivery to the environment…with no service interruption.*’   For rolling code deployments we set the serial execution of Ansible to one, which runs the plays against the VMs serially and stopping on first failure.

In a live environment I’d be more inclined to enhance the orchestration of the code deployment by removing the application node from the load balancing nginx configuration on the web node, during the code deployment.

To re-deploy the application code from git: 
```
$ ansible-playbook provisioning/site.yml --tags appDeploy -e "serialCount=1"
```
To further show orchestration in Ansible, and the benefits of rolling updates in a live environment, I’ve also included a broken version of the Go app.   By overriding the buildBroken group variable we can tell Ansible to download a broken version of the Go app.   This version of the app code fails to compile.

The net effect of this in a multi-tier environment is that if we deploy a broken app we can avoid the entire site going offline by failing early (the Ansible way).  In this case the web1 node continues serving content from the app node that wasn’t affected by the failed deployment.

To deploy the broken Go application from git:
```
$ ansible-playbook provisioning/site.yml --tags appDeploy -e "buildBroken=true serialCount=1"
$ sh testApplication.sh
Hi there, I'm served from app2!
Hi there, I'm served from app2!
Hi there, I'm served from app2!
Hi there, I'm served from app2!
Hi there, I'm served from app2!
Hi there, I'm served from app2!
```
*To recover from this partially failed state, simply re-run the provisioning without the extra vars setting (remove: -e “buildBroken=true serialCount=1”)*

######Development Environment

Mac OSX, Ansible, Vagrant, VirtualBox running Ubuntu instances.
```
$ ansible --version
ansible 2.0.0.2
  config file = ./ansible.cfg
  configured module search path = Default w/o overrides
$ vagrant --version
Vagrant 1.8.4
$ vboxmanage --version
5.0.22r108108
$ uname -a
Darwin camus.lan 15.5.0 Darwin Kernel Version 15.5.0: Tue Apr 19 18:36:36 PDT 2016; root:xnu-3248.50.21~8/RELEASE_X86_64 x86_64
```
