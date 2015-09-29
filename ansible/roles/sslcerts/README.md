SSL cert deployment
===================

For each host that has SSL certs, create a file in:

    /etc/ansible/host_vars/host.example.org

If you are using a local inventory file (with ansible-playbook -i production),
this should be in the "host_vars" directory at the root of your playbook.

Example contents:

<pre>
sslcertificates:
    - wildcard.example.org
    - www.example.net
</pre>

This assumes that the keys/certs are in:

    /etc/ansible/files/etc/ssl/private/wildcard.example.org.key
    /etc/ansible/files/etc/ssl/private/wildcard.example.org.crt

etc.
