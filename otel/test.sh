docker run --rm -it --network host -e "OTEL_EXPORTER_OTLP_ENDPOINT=127.0.0.1:4317" \
-e "otlp_instance_id=test_insance_rpm" \
-e "OTEL_RESOURCE_ATTRIBUTES=service.namespace=AWSOTelCollectorRPMDemo,service.name=AWSOTelCollectorRPMDemoService" \
-e S3_REGION=eu-west-2 aottestbed/aws-otel-collector-sample-app:java-0.1.0
