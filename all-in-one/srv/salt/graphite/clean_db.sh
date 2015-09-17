#!/bin/bash
find /var/lib/carbon/whisper/emuwn-* -mtime +1 -type f | grep -E "/var/lib/carbon/whisper/[^/]*" -o | uniq | xargs rm -rf
