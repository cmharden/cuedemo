package main

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

resources: podinfo: appsv1.#Deployment & {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata:   _config.meta
	spec:       appsv1.#DeploymentSpec & {
		if _hpa == false {
			replicas: _config.replicas
		}
		selector: matchLabels: app: _config.meta.name
		template: {
			metadata: labels: app: _config.meta.name
			spec: corev1.#PodSpec & {
				serviceAccountName: resources.serviceaccount.metadata.name
				containers: [
					{
						name: "podinfo"
						command: [
							"./podinfo",
							"--port=\(_config.port)",
						]
						image: "\(_config.image):\(_config.tag)"
						ports: [{
							containerPort: _config.port
						}]
					},
				]
			}
		}
	}
}
