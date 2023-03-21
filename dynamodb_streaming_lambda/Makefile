.PHONY: init plan destroy apply lint insert update

init:
	terraform init

plan: lint
	terraform plan --out tfstate.plan

apply: plan
	terraform apply "tfstate.plan"

lint:
	terraform fmt && terraform validate

destroy:
	terraform destroy

insert:
	python3 insert_rows.py

update:
	python3 update_rows.py