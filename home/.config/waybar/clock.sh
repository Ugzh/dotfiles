#!/bin/sh

text=$(date '+%-I:%M%P')
tooltip=$(cal -m)

jq -cn --arg text "$text" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'
