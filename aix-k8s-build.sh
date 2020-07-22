yum install -y \
    kubeadm-1.18.5 \
    kubectl-1.18.5 \
    kubelet-1.18.5 \
    --disableexcludes=kubernetes && \
    systemctl enable kubelet



 yum install -y \
    kubeadm-1.18.5 \
    kubelet-1.18.5 \
    --disableexcludes=kubernetes && \
    systemctl enable kubelet

#https://192.168.50.101:2379,https://192.168.50.102:2379,https://192.168.50.103:2379


#  Your Kubernetes control-plane has initialized successfully!

#To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

#You should now deploy a pod network to the cluster.
#Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#  https://kubernetes.io/docs/concepts/cluster-administration/addons/

#You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join apiserver.k8s.local:8443 --token vo6qyo.4cm47w561q9p830v \
    --discovery-token-ca-cert-hash sha256:46e177c317037a4815c6deaab8089da4340663efeeead40810d4f53239256671 \
    --control-plane --certificate-key ba869da2d611e5afba5f9959a5f18891c20fb56d90592225765c0b965e3d8783

#Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
#As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
#"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

#Then you can join any number of worker nodes by running the following on each as root:

kubeadm join apiserver.k8s.local:8443 --token vo6qyo.4cm47w561q9p830v \
    --discovery-token-ca-cert-hash sha256:46e177c317037a4815c6deaab8089da4340663efeeead40810d4f53239256671