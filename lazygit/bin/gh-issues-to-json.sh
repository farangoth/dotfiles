#!/bin/env sh
gh issue list --json number,title --template '{{range .}}{{tablerow .number .title}}{{end}}'
