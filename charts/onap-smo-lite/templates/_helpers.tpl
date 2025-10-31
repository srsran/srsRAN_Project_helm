#
# Copyright 2021-2025 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

{{/*
Expand the name of the chart.
*/}}
{{- define "onap-smo-lite.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "onap-smo-lite.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Common labels.
*/}}
{{- define "onap-smo-lite.labels" -}}
app.kubernetes.io/name: {{ include "onap-smo-lite.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels.
*/}}
{{- define "onap-smo-lite.selectorLabels" -}}
app.kubernetes.io/name: {{ include "onap-smo-lite.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Return the component-scoped name (e.g. release-component).
*/}}
{{- define "onap-smo-lite.componentName" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- printf "%s-%s" (include "onap-smo-lite.fullname" $root) $component | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Default collector.properties for the VES collector if the user does not override it.
*/}}
{{- define "onap-smo-lite.vesCollector.defaultCollectorProperties" -}}
collector.service.secure.port=8443
auth.method=certBasicAuth
header.authlist=sample1,$2a$10$0buh.2WeYwN868YMwnNNEuNEAMNYVU9.FSMJGyIKV3dGET/7oGOi6
collector.keystore.file.location=etc/keystore
collector.keystore.passwordfile=etc/passwordfile
collector.cert.subject.matcher=etc/certSubjectMatcher.properties
collector.truststore.file.location=etc/truststore
collector.truststore.passwordfile=etc/trustpasswordfile
collector.schema.checkflag=1
collector.schema.file={"v1":"./etc/CommonEventFormat_27.2.json","v2":"./etc/CommonEventFormat_27.2.json","v3":"./etc/CommonEventFormat_27.2.json","v4":"./etc/CommonEventFormat_27.2.json","v5":"./etc/CommonEventFormat_28.4.1.json","v7":"./etc/CommonEventFormat_30.2.1_ONAP.json"}
collector.externalSchema.checkflag=1
collector.externalSchema.schemasLocation=etc/externalRepo/
collector.externalSchema.mappingFileLocation=etc/externalRepo/schema-map.json
event.externalSchema.schemaRefPath=$.event.stndDefinedFields.schemaReference
event.externalSchema.stndDefinedDataPath=$.event.stndDefinedFields.data
collector.dmaap.streamid=fault=ves-fault|heartbeat=ves-heartbeat|pnfRegistration=ves-pnfRegistration|3GPP-FaultSupervision=ves-3gpp-fault-supervision|3GPP-Heartbeat=ves-3gpp-heartbeat|3GPP-Provisioning=ves-3gpp-provisioning
collector.dmaapfile=etc/ves-dmaap-config.json
collector.description.api.version.location=etc/api_version_description.json
event.transform.flag=0
collector.dynamic.config.update.frequency=5
{{- end -}}

{{/*
Default DMAAP configuration for the VES collector.
*/}}
{{- define "onap-smo-lite.vesCollector.defaultDmaapConfig" -}}
{
  "ves-fault": {
    "type": "message_router",
    "dmaap_info": {
      "location": "mtl5",
      "topic_url": "http://dmaap-message-router:3904/events/unauthenticated.SEC_FAULT_OUTPUT/"
    }
  },
  "ves-heartbeat": {
    "type": "message_router",
    "dmaap_info": {
      "location": "mtl5",
      "topic_url": "http://dmaap-message-router:3904/events/unauthenticated.SEC_HEARTBEAT_OUTPUT/"
    }
  },
  "ves-pnfRegistration": {
    "type": "message_router",
    "dmaap_info": {
      "location": "mtl5",
      "topic_url": "http://dmaap-message-router:3904/events/unauthenticated.VES_PNFREG_OUTPUT/"
    }
  },
  "ves-3gpp-fault-supervision": {
    "type": "message_router",
    "dmaap_info": {
      "location": "mtl5",
      "topic_url": "http://dmaap-message-router:3904/events/unauthenticated.SEC_3GPP_FAULTSUPERVISION_OUTPUT/"
    }
  },
  "ves-3gpp-heartbeat": {
    "type": "message_router",
    "dmaap_info": {
      "location": "mtl5",
      "topic_url": "http://dmaap-message-router:3904/events/unauthenticated.SEC_3GPP_HEARTBEAT_OUTPUT/"
    }
  },
  "ves-3gpp-provisioning": {
    "type": "message_router",
    "dmaap_info": {
      "location": "mtl5",
      "topic_url": "http://dmaap-message-router:3904/events/unauthenticated.SEC_3GPP_PROVISIONING_OUTPUT/"
    }
  }
}
{{- end -}}
