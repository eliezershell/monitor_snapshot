#!/bin/bash

# Verifica se o ID do volume foi fornecido
if [ -z "$1" ]; then
  echo -----------------------------------------------------------------------------------------------------
  echo "O script deve ser executado especificando o ID do Volume com o seguinte formato: $0 <volume-id>"
  exit 1
fi

VOLUME_ID=$1

# Cria a snapshot e captura o ID da snapshot
SNAPSHOT_ID=$(aws ec2 create-snapshot --volume-id "$VOLUME_ID" --query "SnapshotId" --output text)

if [ -z "$SNAPSHOT_ID" ]; then
  echo -----------------------------------------------------------------------------------------------------
  echo "Erro ao criar a snapshot. Verifique se o ID do Volume está correto."
  exit 2
fi

echo "Snapshot criada com sucesso. ID da snapshot: $SNAPSHOT_ID"

# Captura o tempo de início
inicio=$(date +%s)

echo -----------------------------------------------------------------------------------------------------
echo "Monitorando a snapshot $SNAPSHOT_ID..."
echo "Início: $(date)"

# Loop para monitorar o estado da snapshot
while true; do
  estado=$(aws ec2 describe-snapshots --snapshot-ids "$SNAPSHOT_ID" --query "Snapshots[0].State" --output text)
  
  if [ "$estado" == "completed" ]; then
    echo -----------------------------------------------------------------------------------------------------
    echo "Snapshot $SNAPSHOT_ID concluída!"
    break
  elif [ "$estado" == "error" ]; then
    echo -----------------------------------------------------------------------------------------------------
    echo "Ocorreu um erro ao criar a snapshot $SNAPSHOT_ID."
    exit 3
  fi

  # Aguarda 1 minuto antes de checar novamente
  sleep 60
done

# Captura o tempo de término
fim=$(date +%s)

# Calcula o tempo total em segundos
tempo_total=$((fim - inicio))

# Converte para horas, minutos e segundos
horas=$(( (tempo_total % 86400) / 3600 ))
minutos=$(((tempo_total % 3600) / 60))
segundos=$((tempo_total % 60))

if [ $tempo_total -ge 3600 ]; then
  echo -----------------------------------------------------------------------------------------------------
  echo "Tempo total para concluir a snapshot: $horas horas, $minutos minutos e $segundos segundos."
else
  echo -----------------------------------------------------------------------------------------------------
  echo "Tempo total para concluir a snapshot: $minutos minutos e $segundos segundos."
fi

exit 0