# guacamole9

## Usage

### Keys

-t <type>            - type of log file, can be apache, php
-f <file>            - name of log file, can be plain-text or gzipped
-z                   - gunzip log file before processing
-A "<goaccess args>" - arguments to pass to goaccess, for example '-a -o output'
-n                   - try to anonimyze log file (for php)

### Apache access log

Plain text log to console

`./script.sh -t apache -f access.log -A "-a"`

Plain text log to html output

`./script.sh -t apache -f access.log -A "-a -o output.html"`

Gzipped text log to html output

`./script.sh -t apache -f access.log.gz -z -A "-a -o output.html"`

