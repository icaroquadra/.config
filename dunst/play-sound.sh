#!/usr/bin/env bash
# Chamado pelo dunst (script = ...) para apps que não tocam som próprio.
# O dunst passa: appname summary body icon urgency.
SOUND="${DUNST_SOUND:-/usr/share/sounds/freedesktop/stereo/complete.oga}"
pw-play "$SOUND" >/dev/null 2>&1 &
