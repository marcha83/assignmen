# This project cover testing example:

vagrant setup with CentOS 6 (i386) image for VirtualBox virtualizer
ansible provision  setup that include services:
- HAproxy:
      * SSL frontend temination with self-signed certificate 
      * only TLS protocol, strong ciphers, with generated DH key and enabled HSTS 
      * SSL backend to nginx server 

- nginx:
      * separate server block
      * SSL with self-signed certificate
      * example of microcaching with exclude caching areas
      * example of configuration security headers, deny access to important files and folders

- pgp-fpm:
      * separate pool for php web aplication
      * process management (ondemand setup) with number of workers, timeout..

- redis:
      * basic redis setup with crontab script that load some key value


#  Requirements

Install on host machine: 
- virtualbox (2.0 and up)
- vagrant (5.2 and up)
- ansible (2.3 and up)


# Usage

1. clone git project in any directory on host machine

   $ git clone https://github.com/marcha83/assignment.git

2. move to vagrant directory under cloned git project
   
   $ cd ./assignment/vagrant/

3. setup ansible variables under playbook.yml (if you wish to change), e.g.

    vars:
      - domain_name: assignment   -->  URL domain name 
      - php_fpm_pool: assignmentpool  -->  php-fpm pool web application setup 

3. vagrant up

   $ vagrant up


# Testing

On host machine (add domain_name under hosts file or use IP address):

https://ip_address_host_machine:8443  --> microcache every 4s

https://ip_address_host_machine:8443/administrator/time.php  --> exclude cache

https://ip_address_host_machine:8443/test/test.php  --> deny (return 404)

https://ip_address_host_machine:8443/test.html  -->  deny (return 403)

-----------------------------------------------------------------------------------------------------------------

# Commands document  

- self-signed certificate cmd is cover under nginx_php-fpm.yml and haproxy.yml playbooks
   
   nginx:
   
   $ openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=HR/ST=Zagreb/L=Zagreb/O=IT/CN={{ domain_name }}.localhost" \
    -keyout /etc/nginx/{{ domain_name }}.key  -out /etc/nginx/{{ domain_name }}.cert
    chmod 0640 /etc/nginx/{{ domain_name }}.key 

    haproxy (from previous step bundle SSL certificate and key file in a single PEM file: 
    
   $  cat /etc/nginx/{{ domain_name }}.cert /etc/nginx/{{ domain_name }}.key > /etc/haproxy/{{ domain_name }}_front.pem

-  cmd for generate a DH key

    $  openssl dhparam -out /etc/haproxy/certs/dhparams.pem 2048


 # Extra explanations

- php-fpm --> process management

Best option for process management depends on application usage and request load. 

    - Static, best for: single pool running single app/group of apps.
    - Dynamic, best for: multiple pools, all/most of them handling 10k+ requests/day
    - Ondemand, best for: large number of pools, many of which handle very low load (few hundred requests/day or less) 

For this testing example and not 'heavy' application I choose ondemand setup, because it dosen't alocate all resources after starting php-fpm services but spawns them as they are needed.

- php-fpm --> listen directive (UNIX socket or TCP)

Because this test example application is running under same guest machine I choose UNIX socket listen directive so they can avoid some checks and operations (like routing) which makes them faster and lighter than IP sockets.
