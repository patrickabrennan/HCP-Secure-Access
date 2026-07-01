resource "time_sleep" "wait_for_worker_registration" {
  create_duration = "90s"
  depends_on = [
    aws_instance.boundary_self_managed_worker
  ]
}
