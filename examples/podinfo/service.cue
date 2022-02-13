package main

import (
	corev1 "k8s.io/api/core/v1"
)

resources: service: corev1.#Service & {
	apiVersion: "v1"
	kind:       "Service"
	metadata:   _config.meta
	spec:       corev1.#ServiceSpec & {
		type:     "ClusterIP"
		selector: _config.meta.labels
		ports: [{
			port:       _config.port
			targetPort: "http"
			protocol:   "TCP"
			name:       "http"
		}]
	}
}
