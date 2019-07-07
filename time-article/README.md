# 个人博客文章归档时间轴

同步github某项目的某个目录方法。

- 1，切换到一个空目录中。

  ```
  $cd /home/wordpress/timer/
  ```

- 2，初始化。

  ```
  [root@eryajf timer]$git init
  Initialized empty Git repository in /home/wordpress/timer/.git/
  ```

- 3，与远程仓库建立连接。

  ```
  [root@eryajf timer]$git remote add -f origin https://github.com/eryajf/shellabout.git
  Updating origin
  remote: Enumerating objects: 28, done.
  remote: Counting objects: 100% (28/28), done.
  remote: Compressing objects: 100% (22/22), done.
  remote: Total 53 (delta 6), reused 26 (delta 5), pack-reused 25
  Unpacking objects: 100% (53/53), done.
  From https://github.com/eryajf/shellabout
   * [new branch]      master     -> origin/master
  ```

- 4，开启sparse checkout 模式

  ```
  [root@eryajf timer]$git config core.sparsecheckout true
  ```

- 5，通过sparse-checkout定义想要checkout的目录。

  ```
  [root@eryajf timer]$echo time-article >> .git/info/sparse-checkout
  ```

- 6，直接pull即可。

  ```
  [root@eryajf timer]$git pull origin master
  From https://github.com/eryajf/shellabout
   * branch            master     -> FETCH_HEAD
  [root@eryajf timer]$ls
  time-article
  ```