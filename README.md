# OPA on Cloud Run

This tutorial walks you through deploying [Open Policy Agent](https://www.openpolicyagent.org) on [Cloud Run](https://cloud.google.com/run).

## Tutorial

```
PROJECT_ID=$(gcloud config get-value project)
```

```
gcloud iam service-accounts create open-policy-agent
```

```
SERVICE_ACCOUNT="open-policy-agent@${PROJECT_ID}.iam.gserviceaccount.com"
```

```
export BUCKET_NAME=oocr
```

```
gsutil mb gs://${BUCKET_NAME}
```

```
gsutil cp bundle.tar.gz gs://${BUCKET_NAME}/
```

```
gsutil iam ch "serviceAccount:${SERVICE_ACCOUNT}:roles/storage.objectViewer" gs://${BUCKET_NAME}
```

```
BQ_CONNECTOR_URL=$(gcloud run services describe opa-bq-connector \
  --platform managed \
  --region us-west1 \
  --format json | \
  jq -r '.status.url')
```

```
gcloud run services add-iam-policy-binding opa-bq-connector \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role='roles/run.invoker' \
  --platform managed \
  --region us-west1
```

```
gcloud beta run deploy open-policy-agent \
  --args='--server,--log-format,text,--addr,0.0.0.0:8181,-c,/config.yaml' \
  --concurrency 80 \
  --cpu 2 \
  --image gcr.io/${PROJECT_ID}/opa:0.24.0-ext \
  --memory '2G' \
  --min-instances 1 \
  --no-allow-unauthenticated \
  --platform managed \
  --port 8181 \
  --region us-west1 \
  --service-account ${SERVICE_ACCOUNT} \
  --set-env-vars="BUCKET_NAME=${BUCKET_NAME},BQ_CONNECTOR_URL=${BQ_CONNECTOR_URL}" \
  --timeout 300
```

```
OPA_URL=$(gcloud run services describe open-policy-agent \
  --platform managed \
  --region us-west1 \
  --format json | \
  jq -r '.status.url')

```

```
curl -i "${OPA_URL}/v1/data/http/example/authz" \
  -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -d '{"input": {"path": "/health","method": "GET"}}'
```

```
bq query "select * from ${PROJECT_ID}:opa.decision_logs"
```
