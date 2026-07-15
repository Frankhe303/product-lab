#!/bin/bash
# 同步 product-lab 文件到腾讯云 COS + 开启静态网站托管
# Usage: bash scripts/sync-to-cos.sh
set -e
cd "$(dirname "$0")/.."
source /mnt/d/my_learning/software_make_workspace/.venv/bin/activate
source .cos.env

python3 -c "
from qcloud_cos import CosConfig, CosS3Client
import os

c = CosConfig(Region=os.environ['COS_REGION'],
    SecretId=os.environ['COS_SECRET_ID'],
    SecretKey=os.environ['COS_SECRET_KEY'])
cl = CosS3Client(c)
b = os.environ['COS_BUCKET']

# 确保静态网站托管已开启
cl.put_bucket_website(Bucket=b, WebsiteConfiguration={
    'IndexDocument': {'Suffix': 'index.html'},
    'ErrorDocument': {'Key': 'index.html'}
})

files = [
    ('index.html', 'text/html; charset=utf-8'),
    ('detail.html', 'text/html; charset=utf-8'),
    ('README.md', 'text/html; charset=utf-8'),
    ('.github/workflows/deploy.yml', 'text/yaml'),
]
for k, ct in files:
    cl.upload_file(Bucket=b, LocalFilePath=k, Key=k, EnableMD5=False, ContentType=ct)
    cl.put_object_acl(Bucket=b, Key=k, ACL='public-read')
    print(f'  ✅ {k}')

print(f'🔗 https://{b}.cos-website.{os.environ[\"COS_REGION\"]}.myqcloud.com')
"