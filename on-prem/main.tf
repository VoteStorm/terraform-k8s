
resource "null_resource" "masters" {
  count = var.masters

  provisioner "local-exec" {
    command = "multipass launch ${var.multipass_image} --name k8s-master-${count.index} --memory ${var.masters_memory}G --disk ${var.masters_disk}G --cpus ${var.masters_cpu} --cloud-init init/k8s.yaml"
  }
}

resource "null_resource" "workers" {
  depends_on = [null_resource.masters]
  count      = var.workers

  provisioner "local-exec" {
    command = "multipass launch ${var.multipass_image} --name k8s-worker-${count.index} --memory ${var.workers_memory}G --disk ${var.workers_disk}G --cpus ${var.workers_cpu} --cloud-init init/k8s.yaml"
  }
}

resource "null_resource" "init_cluster" {
  depends_on = [null_resource.workers]

  provisioner "local-exec" {
    command = <<EOT
      multipass transfer ./shell/cluster-init.sh k8s-master-0:/home/ubuntu/cluster-init.sh
      multipass exec k8s-master-0 -- bash -c "chmod +x /home/ubuntu/cluster-init.sh && sudo bash /home/ubuntu/cluster-init.sh"
    EOT
  }
}

resource "null_resource" "join_all" {
  depends_on = [null_resource.init_cluster]
  provisioner "local-exec" {
    command = "bash shell/join-all.sh"
  }
}


resource "null_resource" "cleanup" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      echo "Deleting all multipass VMs..."
      for name in $(multipass list | awk 'NR>1 {print $1}'); do
        multipass delete --purge $name || true
      done
    EOT
  }
}