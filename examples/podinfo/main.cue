package main

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	runtime "k8s.io/apimachinery/pkg/runtime"
	"encoding/yaml"
)

_config: {
	meta: {
		name:      "podinfo"
		namespace: "default"
		labels: app: "podinfo"
	}
	image: "ghcr.io/stefanprodan/podinfo"
	tag:   "6.0.3"
	port:  9898
}

out: yaml.MarshalStream([ for x in resources {x}])

resources: [ID=_]: #KRM

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
