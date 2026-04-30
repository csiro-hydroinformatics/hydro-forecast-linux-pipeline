# HOWTO

## ssh keypairs

set up Apr 2026

creating keys:

```sh
repos=(cruise-control numerical-sl-cpp datatypes swift swift-py-dev qpp chypp sf-stack)

for repo in "${repos[@]}"; do
  ssh-keygen -t ed25519 -C "hydro-fc-pipeline-${repo}" -f ~/.ssh/hydro_fc_${repo//-/_} -N ""
done
```

listing public keys:

```sh
for f in ~/.ssh/hydro_fc_*.pub; do echo "=== $f ==="; cat "$f"; echo; done
```

Needs base64 encoding to avoid newlines in keys messing things up in the scripts:

```sh
repos=(cruise-control numerical-sl-cpp datatypes swift swift-py-dev qpp chypp sf-stack)
for repo in "${repos[@]}"; do
  base64 -w 0 ~/.ssh/hydro_fc_${repo//-/_} > ~/.ssh/hydro_fc_${repo//-/_}.b64
  echo  # base64 -w 0 doesn't add a trailing newline, this adds one to the file
done
```

to list in order to add the private key in the azdo pipeline as secrets:

<!-- ```sh
for f in ~/.ssh/hydro_fc_*.b64; do echo "=== $f ==="; cat "$f"; echo; done
``` -->

```sh
for f in ~/.ssh/hydro_fc_*.b64; do
  repo=$(basename "$f" .b64)
  repo=${repo#hydro_fc_}
  keyname="SSH_KEY_$(echo "$repo" | tr '[:lower:]-' '[:upper:]_')"
  echo "=== Variable name: ${keyname} ==="
  cat "$f"
  echo
done
```

key names:

* SSH_KEY_SF_STACK
* SSH_KEY_CRUISE_CONTROL
* SSH_KEY_NUMERICAL_SL_CPP
* SSH_KEY_DATATYPES
* SSH_KEY_SWIFT
* SSH_KEY_SWIFT_PY_DEV
* SSH_KEY_QPP
* SSH_KEY_CHYPP

The keys only ever exist in Azure DevOps secret storage and in the ephemeral container's memory — never on disk in the repo.

