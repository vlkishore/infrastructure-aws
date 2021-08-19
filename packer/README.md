packer validate -var-file=config/qa.json packer-build.json

packer build -machine-readable -parallel-builds=1  -var-file=config/qa.json packer-build.json | tee build_artifact.txt

packer build -machine-readable -parallel-builds=1  -var-file=config/qa.json -only=community-qa-dashboard,community-qa-admin-dashboard  packer-build.json | tee build_artifact.txt
