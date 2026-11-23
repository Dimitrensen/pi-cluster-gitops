This a home lab project which combines LLMOps, K3s, Prometheus & Grafana for Observability, and ArgoCD.

The local model is qwen2.5-coder:1.5b on the Hailo AI HAT. Open WebUI, from https://github.com/open-webui/open-webui, is the chat page.

There is also Agentic Ansible Playbooks developed right now called via MCP server. An agent can be used via the terminal in order to configure playbooks without manual input other than chatting. The playbooks are covering automation and configuration areas that are outside K3s' scope.

The hardware used has been 3x Pi5s, 1 K3s Control Plane and 2 K3s Worker Nodes.

Networking can be local without capability for remote access, for remote access Tailscale can be utilized, if WiFI IPs are not static due to Network changes then MagicDNS is a necessary upgrade