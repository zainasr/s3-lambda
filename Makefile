.PHONY: init plan apply destroy package clean

# Variables
TF_DIR = ./terraform
LAMBDA_DIR = ./lambda

init:
	cd $(TF_DIR) && terraform init

plan: package
	cd $(TF_DIR) && terraform plan -out=tfplan

apply:
	cd $(TF_DIR) && terraform apply "tfplan"

package:
	@echo "Packaging Lambda and Layers..."
	mkdir -p $(LAMBDA_DIR)/dist
	# Create Layer zip (Installing dependencies into the correct folder structure)
	pip install -r $(LAMBDA_DIR)/requirements.txt -t $(LAMBDA_DIR)/layer/python/
	cd $(LAMBDA_DIR)/layer && zip -r ../dist/layer.zip python
	# Create Lambda zip
	cd $(LAMBDA_DIR)/src && zip -r ../dist/function.zip .

clean:
	rm -rf $(LAMBDA_DIR)/dist
	rm -rf $(LAMBDA_DIR)/layer/python/*
	find . -type d -name ".terraform" -exec rm -rf {} +