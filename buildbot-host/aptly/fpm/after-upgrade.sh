#!/bin/sh
#
SERVICE="publish-incoming-debian-snapshots.service"

systemctl daemon-reload
systemctl is-active $SERVICE > /dev/null && systemctl restart $SERVICE
