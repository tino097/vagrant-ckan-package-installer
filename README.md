# Vagrant CKAN package installer

This project should speed up testing of the CKAN packages built with
[ckan-packaging](https://github.com/ckan/ckan-packaging).

My idea is to create multi-machine Vagrantfile to set up required enviroments:

    * Ubuntu 12.04 (Trusty)
    * Ubuntu 14.04 (Precise)
    * Ubuntu 16.04 (Xenial)

and pass CKAN package version as parameter and later to be installed by executing
the  provsioning shell script. In future could be used Ansible.
This script should set up CKAN as described in [docs](http://docs.ckan.org/en/latest/maintaining/installing/install-from-package.html)


## Usage

  Currently, box and CKAN package are hardcoded and should be changed by hand before starting the vagrant with:

  ```
  $ vagrant up
  ```

>NOTE: Use `vagrant destroy` before installing new package on same environment
***

# Selenium Tests

As part of the CKAN package installer, selenium tests are added. These tests should
check if the package is sucessfully installed and perform basic tesing of the CKAN instance.

To be able to start tests first create virtual environment with

   ```
   $ virtualenv default
   ```
Install `selenium`:
   ```
   (default)$ pip install selenium
   ```

Download webdirver, for this project im using [Chrome](https://sites.google.com/a/chromium.org/chromedriver/downloads) webdriver


After downloading unzip it to:

  ```
  (default)$ unzip chromedriver_linux64.zip
  ```
Move the webdriver to `/usr/local/bin`

Tests should be started by navigating to `selenium-ckan-testing` folder and install `pytests`

    ```
    (default)$ pip install pytest
    (default)$ pytest ckan
    ```

To be continued ...
