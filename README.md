# aws-IAAC
Ansible-based Infrastructure-as-Code repository for provisioning AWS resources (VPC, subnet, IGW, security group, EC2) and related automation tasks (create AMIs, manage EC2 keypairs, apply RHEL hardening, and configure Ansible Automation Platform artifacts). It’s targeted at operators who use Ansible + AWS (and an AAP/infra collection) to build and manage AWS test/dev infrastructure.

# Stack
Language(s): YAML (Ansible playbooks)
Framework / runtime: Ansible playbooks (uses Ansible collections rather than an app framework)
Notable libraries / collections: amazon.aws (AWS modules: ec2_vpc_net, ec2_instance, ec2_ami, ec2_key, etc.), infra.aap_configuration (infra.aap_configuration-3.3.0 tarball present), ansible.builtin modules (copy, lineinfile, pause, set_stats)
How it's organized
Code
README.md                     short repo description
ansible.cfg                   Ansible configuration
aws.yml                       Playbook: provision VPC, subnet, IGW, route table, SG, launch EC2
create_image.yml              Playbook: create AMI from an EC2 instance (reads ec2_data set by aws.yml)
hardning.yml                  Playbook: apply CIS/RHEL password & SSH hardening
key.yml                       Playbook: create/manage EC2 keypair and register creds/templates with AAP via infra.aap_configuration
key_copy.yml                  Variant that copies a local id_rsa into /tmp and uses the AAP API
sample.yml                    Example/sample playbook
clean.sh                      small helper script (cleanup)
collections/requirements.yml  Ansible collections requirements (references local tar.gz)
infra-aap_configuration-3.3.0.tar.gz  Bundled collection file (infra.aap_configuration)
id_rsa, id_rsa.pub            Private/public key files committed in repo (sensitive)
.DS_Store, .vscode/           editor/OS artifacts
How it fits together:

aws.yml is the main provisioning playbook that creates network resources and an EC2 instance and then sets ec2_data (instance id) via ansible.builtin.set_stats. create_image.yml expects that instance id (it references ec2_data) to create an AMI. key.yml and key_copy.yml handle EC2 keypair creation and/or registering SSH credentials and Job Templates on an Ansible Automation Platform controller via the infra.aap_configuration collection or direct API calls. hardning.yml is a configuration playbook to apply CIS/RHEL SSH/password policies on hosts.
How to run it
Install required collections (requirements reference a local tarball):
From the repository root:
Code
ansible-galaxy collection install -r collections/requirements.yml
(the requirements.yml references the bundled infra-aap_configuration-3.3.0.tar.gz)
Provide AWS credentials and any controller credentials as environment variables:
Example:
Code
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=ap-south-1
The playbooks also use variables like ami_id, keypair_name, and private_key_path (see key.yml).
Run provisioning / tasks:
Code
ansible-playbook aws.yml
ansible-playbook create_image.yml       # expects ec2_data (instance id) to be available/supplied
ansible-playbook key.yml
ansible-playbook hardning.yml
Notes / requirements:

Many playbooks assume the amazon.aws collection is available and that you have appropriate AWS IAM permissions (VPC, EC2, AMI, keypair, SG, routing).
create_image.yml expects an instance id in ec2_data (aws.yml sets this via set_stats and a pause); in CI you may need to pass that variable between jobs or run both playbooks in sequence on the same control machine.
The repo currently contains private keys (id_rsa) and a bundled collection tarball — these are sensitive and may need removal/rotation before sharing.
Try asking
