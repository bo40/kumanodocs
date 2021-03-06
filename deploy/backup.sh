#!/bin/sh

cd /srv/kumanodocs/
SQL_BACKUP_PATH=deploy/backup
if [ ! -e ${SQL_BACKUP_PATH} ] ; then
    mkdir ${SQL_BACKUP_PATH}
fi
if test "07" = $(date +"%d") -o "22" = $(date +"%d"); then
    SQL_SEED=${SQL_BACKUP_PATH}/kumanodocs-database-backup-seed-$(date +"%Y-%m-%d").sqlite3
    cp db.sqlite3 ${SQL_SEED}
    gzip -c ${SQL_SEED} > ${SQL_SEED}.gz
    source deploy/venv/bin/activate
    ./deploy/upload_dropbox.py ${SQL_SEED}.gz
    rm ${SQL_SEED}.gz
    rm ${SQL_BACKUP_PATH}/kumanodocs-database-backup-diff-*
else
    SOURCE_BACKUP=${SQL_BACKUP_PATH}/kumanodocs-database-backup-seed-$(date +"%Y-%m").sqlite3
    DIFF_BACKUP=${SQL_BACKUP_PATH}/kumanodocs-database-backup-diff-$(date +"%Y-%m-%d").sqlite3
    if [ ! -e ${SOURCE_BACKUP} ]; then
        cp db.sqlite3 ${SOURCE_BACKUP}
        if [ -e ${SQL_BACKUP_PATH}/kumanodocs-database-backup-diff* ]; then
            rm ${SQL_BACKUP_PATH}/kumanodocs-database-backup-diff*
        fi
    fi
    sqldiff ${SOURCE_BACKUP} db.sqlite3 > ${DIFF_BACKUP}
fi
