# Global Shield: multi-region failover on AWS

Global Shield keeps a website online when an AWS region fails. The site is hosted on S3 in two regions, us-east-1 and us-west-2, behind one CloudFront distribution. If the primary returns errors, CloudFront retries the request against the backup region on its own, with no DNS change and no one on call. Everything is built with Terraform and runs inside the AWS Free Tier.

**Live demo:** https://d3ko3s70so24u1.cloudfront.net/

## How it works

1. **CloudFront** is the single entry point and serves the site over HTTPS.
2. **An origin group** lists the primary bucket (us-east-1) and the backup (us-west-2). When the primary fails, CloudFront switches per request at the edge.
3. **Two S3 buckets** host the site, each with its own dashboard: blue for the primary region, amber for the backup.
4. **A Route 53 health check** watches the primary, so an outage is visible even while CloudFront is already serving the backup.

The backup region is just an S3 bucket, so it costs almost nothing until it's needed. That's the main design choice: real failover without paying for idle servers in a second region.

## Repository

```
terraform/
├── main.tf                          # S3 website buckets, CloudFront origin group, Route 53 health check, uploads
├── providers.tf                     # provider aliases for us-east-1 and us-west-2
├── variables.tf
├── enhanced-dashboard.html          # primary region dashboard (blue)
└── enhanced-failover-dashboard.html # backup region dashboard (amber)
```

Built with Terraform, S3, CloudFront, Route 53 and IAM. The dashboards are plain HTML, Tailwind CSS and JavaScript.

## Deploy it

You need the AWS CLI with permissions to create these resources, and Terraform.

```bash
git clone https://github.com/cyberN3m3/Global-Shield-Dashboard.git
cd Global-Shield-Dashboard/terraform
terraform init
terraform apply
```

Terraform uploads both dashboards. To update one by hand:

```bash
aws s3 cp enhanced-dashboard.html s3://global-shield-primary-<id>/index.html --content-type "text/html"
aws s3 cp enhanced-failover-dashboard.html s3://global-shield-secondary-<id>/index.html --content-type "text/html"
```

## Test the failover

1. Open the CloudFront URL from the Terraform outputs. The blue dashboard shows us-east-1 as the active region.
2. Click **Simulate Failover** to see the amber backup dashboard. This button is a demo of the interface only.
3. To test the real failover, block public access on the primary bucket. CloudFront starts serving the backup region's page.

## Cost

| Service | Per month | Notes |
| --- | --- | --- |
| S3 storage and requests | $0.00 | Inside the Free Tier |
| CloudFront | $0.00 to $0.10 | First 1 TB is free |
| Route 53 health check | $0.50 | Optional |
| Total | $0.00 to $0.60 | |

## What I'd add next

- Automatic failback once the primary recovers
- CloudWatch metrics on the dashboard
- WAF rules and a custom domain with its own certificate
- A GitHub Actions pipeline and Terratest checks for the Terraform

---

Anyasi Chineme · [GitHub](https://github.com/cyberN3m3)
