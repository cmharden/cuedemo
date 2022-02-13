package main

import (
	"text/tabwriter"
	"tool/cli"
	"encoding/yaml"
)

command: ls: {
	task: print: cli.Print & {
		text: tabwriter.Write([
			"KIND \tNAMESPACE \tNAME",
			for x in resources {
				"\(x.kind)  \t\(x.metadata.namespace) \t\(x.metadata.name)"
			},
		])
	}
}

command: oyaml: {
	task: print: cli.Print & {
		text: yaml.MarshalStream(out)
	}
}
