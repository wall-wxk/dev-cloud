# 云开发环境

该项目用于构建前端云开发环境。

## 使用方式

1. 将项目上传到服务器
2. cd到项目根目录，运行命令,进行镜像的创建
```
docker build --build-arg SSH_PORT=[ssh端口] --build-arg ARCH=x86 -t [镜像名] .
```

ps: 如果是mac系统，则使用以下命令创建镜像
```
docker build --build-arg SSH_PORT=[ssh端口] --build-arg ARCH=arm -t [镜像名] .
```

3. 创建挂载卷
```
docker volume create [卷名]
```

4. 启动容器
```
docker run -itd --name ［容器名] -p [ssh端口]:22 --mount source=[挂载卷],target=/mnt  [镜像名]
```

5. 进入容器
```
docker exec -it [容器名] /bin/bash
```

## 配置信息
- `root`用户初始密码为: `hello#fe1024`
- 默认安装软件
  - Git
  - Node.js (默认安装 v14.21.1)
  - npm (默认使用淘宝源)
  - yarn (默认3.2.4)
  - nrm
  - nvm
  - vim

## 注意事项

### 文件格式
使用`window`系统修改`bash`相关文件时，需要确认格式为`unix`。
　　
以`nvm.bashsrc`文件为例，修改格式的操作步骤如下：
- vi 打开`nvm.bashsrc`文件
- 输入`:set ff`，回车确认，可以显示当前的文件格式。正确的格式为：`fileformat=unix`
- 如果显示`fileformat=dos`，则需要修改文件格式。因为`linux`不识别`dos`格式。
- 输入`:set ff=unix`，回车确认，修改格式
- 输入`:wq`，保存修改即可。

### 更新容器

更新容器后，需要将本机的`~/.ssh/known_hosts`删除对应的项，重新认证。

## 改进与建议

[欢迎提意见](https://github.com/wall-wxk/dev-cloud/issues)