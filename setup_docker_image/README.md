## setup_docker_image
這個資料夾是用來放置建立3060主機docker image的相關檔案。

### 檔案結構
```
setup_docker_image
|   docker-compose.yaml
|   Dockerfile
|   
\---app
        requirements.txt
```

### 檔案說明
- `docker-compose.yaml`: 用來設定docker image的相關設定
- `Dockerfile`: 用來建立docker image的指令
- `app/requirements.txt`: 用來設定docker image的python套件
- `app/`: 用來放置docker image的python程式

### 使用方法
1. 在`app/`資料夾中放置python程式
2. 在`app/requirements.txt`中放置python套件
3. 執行`docker-compose up (-d) --build`建立docker image，`-d`參數是用來背景執行
4. 如果要重新開啟docker container，可以執行`docker-compose up (-d)`
5. 執行`docker exec -it miniconda-container bash`連接至已啟動的docker container

### 可修改部分
- WORKDIR: 在`Dockerfile`中可以修改docker image的工作目錄，預設為`/app`，並且需要和`docker-compose.yaml`中的`volumes`設定相同
- `docker-compose.yaml`中的`volumes`設定: 可以修改docker image和本機端的檔案共享設定

### 注意事項
- `docker-compose.yaml`中的`volumes`設定，需要和`Dockerfile`中的`WORKDIR`設定相同，否則會無法共享檔案
- 本地的資料夾名稱不一定要和`app/`相同，但是需要和`docker-compose.yaml`中的`volumes`設定相同
- 需要導出conda環境，可以使用`conda list --export > /app/requirements.txt`指令，將conda環境導出到`app/requirements.txt`中
