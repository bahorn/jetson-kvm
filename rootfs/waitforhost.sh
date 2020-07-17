#!/bin/bash
ping $1 | grep --line-buffered "bytes from" | head -1 && exec ${@:2}
