#!/bin/bash
awk -F ":" '{print $1}' /etc/passwd
exit 0
