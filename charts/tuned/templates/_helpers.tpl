{{- define "tuned.labels" -}}
app.kubernetes.io/name: tuned
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{- define "tuned.selectorLabels" -}}
app.kubernetes.io/name: tuned
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
