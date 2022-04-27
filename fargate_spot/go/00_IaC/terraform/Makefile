shared-apply: # 更新の度手動実行（開発・本番共有リソースのため CD なし）
	cd environments/shared && \
	terraform init -backend-config=shared.tfbackend && \
	terraform fmt -recursive && \
	terraform destroy -auto-approve -var-file=shared.tfvars
# terraform apply -auto-approve -var-file=shared.tfvars

dev-apply: # 環境ごとに自動デプロイ
	cd environments/dev && \
	terraform init -backend-config=dev.tfbackend && \
	terraform fmt -recursive && \
	terraform destroy -auto-approve -var-file=dev.tfvars

prd-apply: # 環境ごとに自動デプロイ
	cd environments/prd && \
	terraform init -backend-config=prd.tfbackend && \
	terraform fmt -recursive && \
 	terraform apply -auto-approve -var-file=prd.tfvars
