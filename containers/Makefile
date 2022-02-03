.PHONY: deploy
deploy:
	docker buildx build --platform linux/amd64 -f Dockerfile.ubuntu -t trap-ubuntu .
	aws ecr get-login-password --region ca-central-1 | docker login --username AWS --password-stdin 816164989508.dkr.ecr.ca-central-1.amazonaws.com
	docker tag trap-ubuntu:latest 816164989508.dkr.ecr.ca-central-1.amazonaws.com/ctf_ubuntu:latest
	docker push 816164989508.dkr.ecr.ca-central-1.amazonaws.com/ctf_ubuntu:latest
	aws ecs update-service --deployment-configuration minimumHealthyPercent=0 --cluster ctf --service ctf --force-new-deployment --region ca-central-1 --no-cli-pager
	aws ecs wait services-stable --cluster ctf --service ctf --region ca-central-1


