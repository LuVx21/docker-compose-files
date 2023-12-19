```bash
mkdir -p $HOME/docker/kafka-console-ui/{data,log}

docker run -itd --name kafka-console-ui \
-p 57766:7766 \
--platform linux/amd64 \
-v $HOME/docker/kafka-console-ui/data:/app/data \
-v $HOME/docker/kafka-console-ui/log:/app/log \
wdkang/kafka-console-ui
```

> https://github.com/xxd763795151/kafka-console-ui
