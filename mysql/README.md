
创建后重启容器时出现:
`chown: changing ownership of '/var/lib/mysql/mysql.sock': No such file or directory.`

1. 每次执行前删除: mysql.sock
2. 使用[user label](https://github.com/docker-library/mysql/issues/939#issuecomment-1407613352)
3. 使用[volumes](https://github.com/docker-library/mysql/issues/939#issuecomment-1505515242)
```
    volumes:
      - $HOME/docker/mysql/data/:/var/lib/mysql
```
修改为:
```
    volumes:
      - db:/var/lib/mysql:rw

volumes:
  db:
```