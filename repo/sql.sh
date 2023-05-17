#!/bin/bash

# Solicitar las credenciales para el usuario administrador de MySQL
read -p "Ingrese el nombre de usuario de MySQL: " username
read -s -p "Ingrese la contraseña de MySQL: " password
echo

# Crear la base de datos
mysql -u $username -p$password -e "CREATE DATABASE IF NOT EXISTS mydatabase;"

# Seleccionar la base de datos
mysql -u $username -p$password -D mydatabase -e "

-- Crear la tabla 'usuarios'
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL
);

-- Crear la tabla 'productos'
CREATE TABLE IF NOT EXISTS productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    precio DECIMAL(10,2) NOT NULL
);

-- Insertar datos de ejemplo en la tabla 'usuarios'
INSERT INTO usuarios (nombre, email) VALUES
    ('Usuario 1', 'usuario1@example.com'),
    ('Usuario 2', 'usuario2@example.com');

-- Insertar datos de ejemplo en la tabla 'productos'
INSERT INTO productos (nombre, precio) VALUES
    ('Producto 1', 10.50),
    ('Producto 2', 15.25);
"

echo "La base de datos y las tablas han sido creadas correctamente."
