#!/bin/bash
sudo service httpd start
sudo service mysqld start
PATH=../bin:$PATH lapis server devel
