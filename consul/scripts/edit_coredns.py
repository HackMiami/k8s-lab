import subprocess


# need to get the fowrard ip for consul
# this is the service ip for consul-dns

def get_consul_dns_ip():
    cmd = "kubectl get svc -n consul | grep consul-dns | awk '{print $3}'"
    ip = subprocess.check_output(cmd, shell=True)
    return ip.decode('utf-8').strip()


# neet to build the new coredns configmap
def build_coredns_configmap():
    ip = get_consul_dns_ip()
    config = f'''
data:
  Corefile: |
    .:53 {{
      errors
      health {{
        lameduck 5s
      }}
      ready
      kubernetes cluster.local in-addr.arpa ip6.arpa {{
        pods insecure
        fallthrough in-addr.arpa ip6.arpa
        ttl 30
      }}
      prometheus :9153
      forward . /etc/resolv.conf {{
        max_concurrent 1000
      }}
      cache 30
      loop
      reload
      loadbalance
    }}
    consul {{
      errors
      cache 10
      forward . {ip}
    }}
'''
    return config


# need to patch the coredns configmap
def patch_coredns_configmap():
    config = build_coredns_configmap()
    cmd = f"kubectl patch configmap coredns -n kube-system -p '{config}'"
    subprocess.check_output(cmd, shell=True)


if __name__ == "__main__":
    patch_coredns_configmap()
