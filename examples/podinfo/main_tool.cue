package main

import (
	"tool/cli"
	"tool/exec"
	"encoding/yaml"
	"text/tabwriter"
	"tool/file"
)

version:   "v0.0.1-alpha.3"
flux_path: "./examples/podinfo/cluster/"

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
	install_path: "./cluster/cue-controller"
	mkdir:        file.Mkdir & {
		path:          install_path
		createParents: true
	}
	install_crds: exec.Run & {
		$after: mkdir
		cmd:    "curl -sL -o \(install_path)/crds.yaml https://github.com/phoban01/cue-flux-controller/releases/download/\(version)/cue-controller.crds.yaml"
	}
	install_controller: {
		deploy: exec.Run & {
			$after: install_crds
			cmd:    "curl -sL -o \(install_path)/deploy.yaml https://github.com/phoban01/cue-flux-controller/releases/download/\(version)/cue-controller.deployment.yaml"
		}
		rbac: exec.Run & {
			$after: install_crds
			cmd:    "curl -sL -o \(install_path)/rbac.yaml https://github.com/phoban01/cue-flux-controller/releases/download/\(version)/cue-controller.rbac.yaml"
		}
	}
	diff: exec.Run & {
		$after: install_controller
		cmd: ["git", "diff", "--stat", install_path]
		stdout: *"" | string
	}
	if diff.stdout != "" {
		add: exec.Run & {
			cmd: ["git", "add", install_path]
		}
		commit: exec.Run & {
			$after: add
			cmd: ["git", "commit", "-m", "cue-controller: install \(version)"]
		}
		push: exec.Run & {
			$after: commit
			cmd: ["git", "push"]
		}
	}
}
