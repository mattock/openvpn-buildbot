#!/bin/sh
#
SERVICE="publish-incoming-debian-snapshots.service"

systemctl daemon-reload
systemctl enable $SERVICE
systemctl start $SERVICE
