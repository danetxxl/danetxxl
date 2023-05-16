#!/bin/bash

# Actualizar repositorios
sudo apt-get update

# Instalar paquetes necesarios
sudo apt-get install -y slapd ldap-utils

# Configuración de LDAP
sudo dpkg-reconfigure slapd

# Crear archivo de configuración
cat <<EOF | sudo tee /etc/ldap/ldap.conf
BASE    dc=example,dc=com
URI     ldap://localhost
EOF

# Reiniciar el servicio de LDAP
sudo systemctl restart slapd.service

# Agregar una entrada de ejemplo al directorio LDAP
cat <<EOF | sudo ldapadd -x -D cn=admin,dc=example,dc=com -W
dn: dc=example,dc=com
objectClass: top
objectClass: dcObject
objectClass: organization
o: Example Organization
dc: example

dn: cn=admin,dc=example,dc=com
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
userPassword: $(slappasswd -s password)
description: LDAP administrator
EOF

# Comprobar el contenido del directorio LDAP
sudo ldapsearch -x -b dc=example,dc=com
