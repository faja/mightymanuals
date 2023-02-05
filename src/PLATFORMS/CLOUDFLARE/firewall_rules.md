- [official docs](https://developers.cloudflare.com/firewall/)
- [tf resource - cloudflare_filter](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/filter)
- [tf resource - cloudflare_firewall_rule](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/firewall_rule) (at the time of writing provider version: 3.31.0)

---

- `firewall rules` are the first "rules" that are executed when processing incoming request, based on [cf docs](https://developers.cloudflare.com/waf/about/), the orders is the following:
    1. Firewall rules
    1. Custom rulesets
    1. Custom rules
    1. Rate limiting rules
    1. WAF Managed Rules
    1. Cloudflare Rate Limiting (previous version)
- supported acctions
    - `log`
    - `bypass`
    - `allow`
    - `challenge`
    - `managed_challenge`
    - `js_challenge`
    - `block`
- the above list in order of precedence, that means, if a requests matches two rules, with: `block` and `allow` actions, it will be `allowed` because, allow action has higher precedence (there are some exceptions to this behaviour, see [docs](https://developers.cloudflare.com/firewall/cf-firewall-rules/actions/) for details)
