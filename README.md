# Vagrant CKAN package installer

This project should speed up testing of the CKAN packages buit with
[ckan-packaging](https://github.com/ckan/ckan-packaging).

My idea is to create multi-machine Vagrantfile to set up required enviroment

    * Ubuntu 12.04 (Trusty)
    * Ubuntu 14.04 (Precise)
    * Ubuntu 16.04 (Xenial)

and pass CKAN package version as parameter and later to be installed by executing
the  provsioning shell script. In future could be used Ansible.


## Usage

  Currently, box and CKAN package are hardcoded and should be changed by hand before starting the vagrant with:

  ```
  $ vagrant up
  ```

***
  ## ToDo:

  * Use Ansible
  * Change `data/provisoning.sh` with `main.yml`
