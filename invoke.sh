#!/bin/bash
$($@ &> /dev/null &)
exit 0
