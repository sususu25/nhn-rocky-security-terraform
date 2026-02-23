#!/usr/bin/env python3
import json, sys, os

TF_OUT = os.environ.get("TF_OUTPUT_JSON", "tf_output.json")
ANSIBLE_USER = os.environ.get("ANSIBLE_USER", "rocky")

def load_outputs(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def main():
    out = load_outputs(TF_OUT)

    # Terraform output -json 형식: { "name": { "value": ... }, ... }
    backend_ips = (out.get("backend_mgmt_private_ips", {}) or {}).get("value", {})  # dict
    bastion_fip = (out.get("bastion_fip", {}) or {}).get("value", None)            # str or None

    if not backend_ips:
        print("ERROR: backend_mgmt_private_ips is empty. Did you run apply?", file=sys.stderr)
        sys.exit(2)

    # ProxyJump 옵션 (bastion 있을 때만)
    ssh_common_args = ""
    if bastion_fip:
        ssh_common_args = f"-o ProxyJump={ANSIBLE_USER}@{bastion_fip} -o StrictHostKeyChecking=no"

    inventory = {
        "rocky_servers": {
            "hosts": { name: {"ansible_host": ip} for name, ip in backend_ips.items() },
            "vars": {
                "ansible_user": ANSIBLE_USER,
                "ansible_become": True,
                "ansible_become_method": "sudo",
                "ansible_become_user": "root",
                **({"ansible_ssh_common_args": ssh_common_args} if ssh_common_args else {})
            }
        }
    }

    print(json.dumps(inventory, indent=2))

if __name__ == "__main__":
    main()
