package main

import (
	"tool/cli"
	"tool/exec"
	"encoding/yaml"
	"text/tabwriter"
	"tool/file"
)

flux_path: "cluster/"

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

command: bootstrap: {
	owner: exec.Run & {
		cmd:    "gh repo view --json owner --jq .owner.login"
		stdout: string
	}
	repo: exec.Run & {
		cmd:    "gh repo view --json name --jq .name"
		stdout: string
	}
	flux: exec.Run & {
		cmd:    "flux bootstrap github --owner \(owner.stdout) --repository \(repo.stdout) --path \(flux_path)"
		stdout: string
	}
}

command: install: {
	install_path: flux_path + "cue-controller"
	version:      "v0.0.1-alpha.2"
	verify_flux:  file.Mkdir & {
		path:          flux_path
		createParents: true
	}
	install_crds: exec.Run & {
		$after: verify_flux
		cmd:    "curl -sL -o \(install_path)/crds.yaml https://github.com/phoban01/cue-flux-controller/releases/download/\(version)/cue-controller.crds.yaml"
	}
	install_controller: exec.Run & {
		$after: install_crds
		cmd:    "curl -sL -o \(install_path)/controller.yaml https://github.com/phoban01/cue-flux-controller/releases/download/\(version)/cue-controller.deployment.yaml"
	}
	add: exec.Run & {
		$after: install_controller
		cmd:    "git add \(install_path)"
	}
	commit: exec.Run & {
		$after: add
		cmd:    "git commit -m '[cuelang] add cue-controller manifests'"
	}
	push: exec.Run & {
		$after: commit
		cmd:    "git push"
	}
}
