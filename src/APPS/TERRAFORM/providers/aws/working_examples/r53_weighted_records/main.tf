/*
 *
 * this config creates lb.${name}    dns record in specified zone
 * this config creates green.${name} dns record in specified zone
 * this config creates blue.${name}  dns record in specified zone
 *
 */

locals {
  zone_id = "ABCDEFGHIJKLMNOPRSTUW" # zone.domain (account name/account id)
  name    = "blabla"

  green_weight     = 100
  green_lb_name    = "aaabbbcccdddeeefffggghhh12345678990.elb.us-east-1.amazonaws.com"
  green_lb_zone_id = "ZYXPLKAJDMSX42"

  //// blue disabled for now
  //blue_weight     = 10
  //blue_lb_name    = ""
  //blue_lb_zone_id = ""
}

resource "aws_route53_record" "green-weighted" {
  zone_id = local.zone_id
  name    = "lb.${local.name}"
  type    = "A"

  set_identifier = "green-${local.name}"

  weighted_routing_policy {
    weight = local.green_weight
  }

  alias {
    name                   = local.green_lb_name
    zone_id                = local.green_lb_zone_id
    evaluate_target_health = false
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "green-direct" {
  zone_id = local.zone_id
  name    = "green.${local.name}"
  type    = "A"

  alias {
    name                   = local.green_lb_name
    zone_id                = local.green_lb_zone_id
    evaluate_target_health = false
  }
}

//// blue disabled for now
//resource "aws_route53_record" "blue-weighted" {
// // same as green...
//}
//resource "aws_route53_record" "blue-direct" {
// // same as green...
//}
