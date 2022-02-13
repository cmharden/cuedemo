package main

import (
	corev1 "k8s.io/api/core/v1"
)

resources: serviceaccount: corev1.#ServiceAccount & {
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata:   _config.meta
}
