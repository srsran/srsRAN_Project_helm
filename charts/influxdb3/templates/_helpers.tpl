#
# Copyright 2021-2025 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

{{- define "influxdb3.fullname" -}}
{{- printf "%s-%s" .Release.Name "influxdb3" -}}
{{- end -}}
