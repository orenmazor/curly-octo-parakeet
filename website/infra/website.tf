module "s3-website" {
  source  = "cloudposse/s3-website/aws"
  version = "0.17.1"

  hostname           = "jeffshinerstractorsimulator.com"
  encryption_enabled = false
  logs_enabled       = false
  parent_zone_id     = "Z08906992UQ6YARG37IQ4"
}
