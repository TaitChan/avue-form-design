npm run build
harbor=10.10.102.213:8443
image=harmony-workflow-avue-form
namespace=devshop
version=2.1.0
sudo docker buildx build -t $harbor/$namespace/$image:$version --platform linux/amd64 -o type=docker .
# 按需是否登陆harbor，是否推送镜像
harbor_password=Harbor12345
# docker login $harbor --username admin --password $harbor_password
docker push $harbor/$namespace/$image:$version