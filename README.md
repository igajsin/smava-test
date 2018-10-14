# Smava-test
There is the coding challenge for the smava.com.
The task is described in the doc/scenario.pdf file.

# Prerequisites
The creating of credentials, ssh-keys etc is out of the scope of the task.
I assume that there is a user with enough permissions on the AWS, there are
an access and a secret key in the ~/.aws/credentials and an ssh-key on the AWS,
uploaded by the user.

# Usage
Clone the repository and run up/down scripts from the root of the repo. Like:
~~~bash
$ git@github.com:igajsin/smava-test.git
$ ./up
$ ./down
~~~

# Ideas
The application creates an infrastructure by Terraform and then configures it
by Ansible. It creates:

- a VPC with 2 subnets: web (public) and back (private)

- a bastion, a frontend with Nginx and a backend with the containerized
  application instances

- a bastion instance available only for ssh

- a frontend available only by http/https

- a backend not available from the internet

- many other things to make it work

As a result of "terraform apply", it populates an inventory for Ansible and it
can:

- run a docker image on the backend instance

- make Nginx on the frontend works as a reverse-proxy

There is an auto build on the docker hub, that builds an image from
the src/backend/Dockerfile. Dockerfile is based on Alpine Linux (based on
the MUSL). To make the Oracle Java 8.x works it requires to install the GLIBC.
As a first approach, it uses a pre-built apk-package.

# Todo

- add HTTPS support based on Let's encrypt

- build an own apk-package for GLIBC.

- add an image to the Readme with the application's architecture.
