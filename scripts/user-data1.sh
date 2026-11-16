#!/bin/bash
dnf install -y nginx
systemctl enable --now nginx

cat > /usr/share/nginx/html/index.html <<EOF
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Librería Tinta</title>
</head>
<body>
  <h1>Librería Tinta</h1>
  <p>Tu librería de barrio.</p>
  <ul>
    <li><strong>Dirección:</strong> Calle de los Libros 42</li>
    <li><strong>Horario:</strong> Lunes a Sábado de 10:00 a 20:00</li>
    <li><strong>Recomendación del mes:</strong> <em>La sombra del viento</em>, de Carlos Ruiz Zafón</li>
  </ul>
  <hr>
  <small>Desplegado por Marinés Antón en el servidor $(hostname) el $(date '+%d/%m/%Y %H:%M')</small>
</body>
</html>
EOF
