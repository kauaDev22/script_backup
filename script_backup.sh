#!/bin/bash
# Script gerador de scripts de backup para cada servidor

# Lista de servidores
SERVIDORES=("SFw1" "SFw2" "SLogs" "SMariaDB" "SNas" "SProxy" "SPveMaster" "SPveSlave" "SSamba" "SWeb1" "SWeb2" "SWeb3" "SZabbix")

# Caminho para salvar os scripts gerados
DESTINO_SCRIPTS="./scripts_backup"

# IP do servidor NFS
IP_SERVIDOR_NFS="10.200.200.5"

# Cria o diretório para os scripts, se não existir
mkdir -p $DESTINO_SCRIPTS

# Gera um script de backup para cada servidor
for SERVIDOR in "${SERVIDORES[@]}"; do
  SCRIPT="$DESTINO_SCRIPTS/backup_$SERVIDOR.sh"
  cat << EOF > $SCRIPT
#!/bin/sh
# Script de backup para $SERVIDOR

# VARIÁVEIS
NOME_SERVIDOR=\$(hostname)
IP_SERVIDOR_NFS="$IP_SERVIDOR_NFS"
DATA=\$(date +%Y-%m-%d_%H-%M)
DIA_SEMANA=\$(date +%A)
DESTINO="/nfs"
ARQLOG="/tmp/backup-diario-\$DIA_SEMANA.log"

# Monta o NFS
/bin/mount -t nfs \$IP_SERVIDOR_NFS:/backups/$SERVIDOR \$DESTINO

AGORA=\$(date +%d/%m-%H:%M)
echo "\\n Início do backup servidor \$NOME_SERVIDOR..[\$AGORA]" > \$ARQLOG

# BACKUP DO DIRETÓRIO /backups/$SERVIDOR
AGORA=\$(date +%d/%m-%H:%M)
echo "\\n Cópia do diretório backups/$SERVIDOR ..... \$AGORA" >> \$ARQLOG

tar -zcvf \$DESTINO/\$DATA-$SERVIDOR.\$NOME_SERVIDOR.tgz /backups/$SERVIDOR >> \$ARQLOG 2>> \$ARQLOG

AGORA=\$(date +%d/%m-%H:%M)
echo "\\n Cópia do diretório backups/$SERVIDOR encerrada \$AGORA" >> \$ARQLOG

# Desmonta o NFS
umount /nfs
EOF

  # Torna o script gerado executável
  chmod +x $SCRIPT
done

echo "Scripts de backup gerados em: $DESTINO_SCRIPTS"
