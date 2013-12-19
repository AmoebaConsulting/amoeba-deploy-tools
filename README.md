Amoeba Deploy Tools
===================

Amoeba Deploy Tools (ADT) is a ruby gem that enables rapid creation of servers using the Chef config
management system. Using Chef today there are many tools and best practices, and we have found that
often setting up a chef "kitchen" can be tedious. Additionally, we believe in supporting server-less
deploys. That is, we don't like to maintain and run a separate chef server just to manage our boxes.

ADT integrates a number of other tools (`chef-solo`, and `librarian`, and others) and we provide a
[skeleton Kitchen](http://github.com/AmoebaConsulting/amoeba-kitchen-skel), so you can fork our
kitchen, install this gem, and deploy a node in minutes.

## Short introduction

First, you need ruby installed. Next, add `amoeba-deploy-tools` to your project Gemfile, or install
via the `gem` command:

    > gem install amoeba-deploy-tools

If you are preparing a server to install an application, change to that project's directory.
Otherwise, switch to a dir where you plan on running ADT from. And run:

    > amoeba init

The command will walk you through the process of initializing your kitchen. Now you've got a
kitchen all ready to go. We recommend you add it to version control (git). We do not recommend you
add the .amoeba.yml configuration file to git.

Next you must create a node definition, and run a deploy. A node definition sits in the kitchen's
`nodes/` directory. See this directory for a sample node you can copy / rename to make your own.

Once you have a node defined, just run:

    > amoeba node bootstrap --node <node-name>

... and the node will be provisioned. After provisioning, the node's metadata will be stored in the
`data_bags` folder. Our skeleton kitchen includes a basenode recipe that creates a deployment user
on the destination box, and disables root access. This user's name will be cached in the node's
databag and used for subsequent operations to the box. Now, as you make changes to the node, or any
cookbooks you create in `site-cookbooks`, you can push those changes by running:

    > amoeba node push --node <node-name>

Finally to setup Capistrano, you need only add the following to your existing Capfile:

    require 'amoeba_deploy_tools/capistrano'

For a full list of commends, run `amoeba help` or see below.

## Detailed Information

In essence, ADT is controlled by a configuration file, `.amoeba.yml`, specifying where your kitchen
will be located, and a copy of the kitchen itself. In the future, we will support specifying
deployment-related configuration in this file (such as SSH information). So we recommend you keep it
gitignored if it contains sensitive information. The kitchen should be kept under version control,
and you can either fork it prior to running `amoeba init` or you can let `amoeba init` make a copy
of our skeleton which you can add to version control later.

## Vagrant Testing

Using Vagrant to test your nodes is easy! Just install Vagrant, run `amoeba init` and modify the
kitchen's `Vagrantfile`, as necessary. Run `vagrant up` and watch as your VM comes alive.

Then, you can ensure the provider is setup correctly (see `data_bags/providers/vagrant.json`). You
must ensure the SSH port matches that in `Vagrantfile` (by default 2222), and you must point the
provider to the SSH key Vagrant uses (if you just installed Vagrant, this is by default correct,
`~/.vagrant.d/insecure_private_key`). You can, however, change the private key (for security
reasons if you plan on distributing the VM or using it in production) by specifying an alternative
one in the `Vagrantfile` configuration key `config.ssh.private_key_path` (see
[the following documentation](http://docs-v1.vagrantup.com/v1/docs/config/ssh/private_key_path.html)
on Vagrant for more information).

## Commands

### amoeba init [url] [--skeleton]

The URL is optional, but if specified will be used as the library's git repo. You can also specify
`--skeleton`, which will use the specified URL as a skeleton, and make a copy of it (useful if you
do not already have a Kitchen you wish to use in git, but want to start a new one based on the URL
specified).

The default URL is [Amoeba's skeleton](https://github.com/AmoebaConsulting/amoeba-kitchen-skel),
which will be copied (as if `--skeleton` was specified).
