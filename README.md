# 🛡️ Global Shield: Multi-Region Infrastructure Guard

A high-availability, multi-region cloud architecture featuring automated failover and a real-time monitoring dashboard. This project demonstrates enterprise-grade resilience using AWS S3, CloudFront, and Route 53.

## 🚀 Overview


An interactive demonstration of multi-region disaster recovery using AWS services. Features automatic failover between US-EAST-1 and US-WEST-2, with real-time monitoring dashboards that visualize system health and failover states.

**[🚀 Try the Live Demo](https://d3ko3s70so24u1.cloudfront.net/)**

### Key Features

* **Active-Passive Failover:** Automated traffic shifting via CloudFront Origin Groups.
* **Multi-Region Resilience:** Redundant hosting across US East and US West.
* **Real-Time Dashboard:** A professional "Dark Mode" monitoring interface with simulated "Incident" and "Recovery" modes.
* **Infrastructure as Code:** Entire stack deployed via Terraform for 1-click reproducibility.
* **Latency Monitoring:** Integrated health checks to ensure the fastest response times for users.

---

## 🏗️ Architecture

The infrastructure consists of the following components:

1. **CloudFront (CDN):** Acts as the entry point, providing global caching and SSL termination.
2. **Origin Groups:** Configured with primary (East) and secondary (West) origins.
3. **S3 Buckets:** Two buckets configured for static website hosting, each containing a region-specific dashboard.
4. **Route 53 Watchdog:** Health checks monitoring the primary endpoint's availability.

---

## 🛠️ Tech Stack

* **Cloud Provider:** AWS (S3, CloudFront, Route 53, IAM)
* **IaC:** Terraform
* **Frontend:** HTML5, Tailwind CSS, JavaScript (Vanilla)
* **Icons/Styling:** JetBrains Mono & Inter fonts for a high-tech terminal aesthetic.

---

## 📂 Project Structure

├── main.tf                 # Main infrastructure logic (S3, CloudFront, OAC)
├── providers.tf            # AWS Provider aliases for East/West regions
├── enhanced-dashboard.html # Primary Region (Blue) UI
├── enhanced-failover.html  # Secondary Region (Amber) UI

---

## 🚦 Getting Started

### Prerequisites

* AWS CLI configured with appropriate permissions.
* Terraform installed.

### Deployment

1. **Clone the repository:**
```bash
git clone https://github.com/cybern3m3/global-shield.git
cd global-shield

```


2. **Initialize and Apply Terraform:**
```bash
terraform init
terraform apply

```


3. **Upload Assets:**
Once the buckets are created, sync your dashboards:
```bash
aws s3 cp enhanced-dashboard.html s3://global-shield-primary-[id]/index.html --content-type "text/html"
aws s3 cp enhanced-failover-dashboard.html s3://global-shield-secondary-[id]/index.html --content-type "text/html"

```



---

## 🧪 Testing the Failover

1. Visit the **CloudFront URL** provided in the Terraform outputs.
2. The dashboard will show **US-EAST-1** as the active region (Blue interface).
3. Click the **"Simulate Failover"** button to view the emergency Amber interface.
4. (Optional) Manually disable the primary S3 bucket's public access to witness CloudFront's automated origin-switching logic in real-time.

---

## 💰 Cost Analysis

| Service | Monthly Cost | Notes |
|---------|--------------|-------|
| S3 Storage | $0.00 | Within free tier |
| S3 Requests | $0.00 | Within free tier |
| CloudFront | $0.00-$0.10 | First 1TB free |
| Route 53 Health Check | $0.50 | Optional |
| **Total** | **$0.00-$0.60** | Essentially free! |

---

🔮 Future Enhancements

- [ ] Add Lambda@Edge for dynamic routing
- [ ] Implement automatic failback detection
- [ ] Add real-time WebSocket updates
- [ ] Integrate CloudWatch metrics visualization
- [ ] Add WAF rules for security
- [ ] Custom domain with HTTPS certificate
- [ ] CI/CD pipeline with GitHub Actions
- [ ] Automated testing with Terratest

---

## 👤 Author

**[Anyasi Chineme]**

* LinkedIn: [www.linkedin.com/in/Anyasichineme]
* MEDIUM: [securecloudlab]

---

