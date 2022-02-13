package main

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	runtime "k8s.io/apimachinery/pkg/runtime"
)

// tags
_hpa: *false | bool @tag(hpa,type=bool)

// _config holds common configuration for our application
_config: {
	meta: {
		name:      "podinfo"
		namespace: "default"
		labels: app: "podinfo"
	}
	image:    "ghcr.io/stefanprodan/podinfo"
	tag:      "6.0.3"
	port:     9898
	replicas: 1 // not used if hpa tag is set
	hpa: {
		cpu:         75
		memory:      "500Mi"
		minReplicas: 1 // only used if hpa tag is set
		maxReplicas: 4 // only used if hpa tag is set
	}
}

// resources will hold the resources we want to deploy
resources: [ID=_]: #KRM

// out will contains a YAML encoded stream of Kubernetes resources
out: [ for x in resources {x}]

// We'll define KRM to ensure all of our resources comply with Kubernetes Resource Model
#KRM: {
	metav1.#TypeMeta
	metadata:          metav1.#ObjectMeta
	["spec" | "data"]: runtime.#Object
}

#KRM: {
	apiVersion: string
	kind:       string
	metadata: name:      string
	metadata: namespace: string
}
