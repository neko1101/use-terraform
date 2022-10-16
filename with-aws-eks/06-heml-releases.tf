resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"

  values = [
    "${file("helm_values/jenkins-values.yml")}"
  ]

  set_sensitive {
    name  = "controller.adminUser"
    value = "admin_user"
  }

  set_sensitive {
    name  = "controller.adminPassword"
    value = "admin!@#"
  }
}