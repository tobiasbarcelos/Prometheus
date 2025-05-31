#!/bin/bash

set -e

# Verifica se Prometheus já está instalado
if [ -f /usr/local/bin/prometheus ]; then
  echo "Prometheus já instalado. Pulando instalação do Prometheus."
else
  echo "Instalando Prometheus..."

  # Atualizar pacotes e instalar dependências
  sudo apt update -y
  sudo apt install wget curl -y

  # Baixar e instalar Prometheus
  wget https://github.com/prometheus/prometheus/releases/download/v2.50.1/prometheus-2.50.1.linux-amd64.tar.gz
  tar -xvzf prometheus-2.50.1.linux-amd64.tar.gz
  rm prometheus-2.50.1.linux-amd64.tar.gz
  sudo mv prometheus-2.50.1.linux-amd64 /opt/prometheus

  # Criar usuário e diretórios
  id -u prometheus &>/dev/null || sudo useradd --no-create-home --shell /bin/false prometheus
  sudo mkdir -p /etc/prometheus /var/lib/prometheus
  sudo cp /opt/prometheus/prometheus /usr/local/bin/
  sudo cp /opt/prometheus/promtool /usr/local/bin/
  sudo chmod +x /usr/local/bin/prometheus /usr/local/bin/promtool
  sudo cp -r /opt/prometheus/consoles /opt/prometheus/console_libraries /etc/prometheus/
  sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

  # Configuração do Prometheus
  sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF

  # Criar serviço systemd
  sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

  sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml
  sudo systemctl daemon-reload
  sudo systemctl enable prometheus
  sudo systemctl start prometheus
fi

# Instalar Node Exporter
if [ -f /usr/local/bin/node_exporter ]; then
  echo "Node Exporter já instalado. Pulando instalando."
else
  echo "Instalando Node Exporter..."

  wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
  tar -xvzf node_exporter-1.7.0.linux-amd64.tar.gz
  rm node_exporter-1.7.0.linux-amd64.tar.gz
  sudo mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
  rm -rf node_exporter-1.7.0.linux-amd64

  id -u nodeusr &>/dev/null || sudo useradd --no-create-home --shell /bin/false nodeusr

  sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=nodeusr
Group=nodeusr
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable node_exporter
  sudo systemctl start node_exporter
fi  

# Instalar Grafana

if systemctl is-active --quiet grafana server; then
  echo "Grafana já instalado e em execução."
else 
  echo "Instalando Grafana..."
  
  sudo apt update
  sudo apt install -y software-properties-common curl gnupg2
  curl -fsSL https://packages.grafana.com/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/grafana.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
  sudo apt update
  sudo apt install -y grafana

  sudo systemctl enable grafana-server
  sudo systemctl start grafana-server
fi

echo " Instalação concluída! Prometheus (9090), Node Exporter (9100) e grafana (3000) estão rodando."