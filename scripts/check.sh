#!/bin/sh
set -e
(cd apps/mobile && flutter analyze && flutter test)
