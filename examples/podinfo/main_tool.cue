package main

import (
	"tool/cli"
	"tool/exec"
	"encoding/yaml"
	"text/tabwriter"
)

command: ls: {
	task: print: cli.Print & {
		text: tabwriter.Write([
			"KIND \tNAMESPACE \tNAME",
			for x in out {
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

command: "dry-run": {
	task: apply: exec.Run & {
		cmd:   "kubectl apply --dry-run=server -f -"
		stdin: yaml.MarshalStream(out)
	}
}
