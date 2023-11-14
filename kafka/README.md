```bash
MAIN=$HOME/docker/kafka-console-ui
mkdir -p $MAIN/{data,log}
docker run -d -p 57766:7766 \
-v $MAIN/data:/app/data -v $MAIN/log:/app/log wdkang/kafka-console-ui
```
> https://github.com/xxd763795151/kafka-console-ui
