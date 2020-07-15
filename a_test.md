git删除了本地文件，从远程仓库中恢复
在本地删除了文件，使用git pull，无法从远程项目中拉取下来

具体操作
查看项目的状态，会显示出你删除的数据

git status     
进入被删除的文件的目录下,假设删除的文件名为 test.txt
然后进行下列操作，可以成功找回：

git reset HEAD test.txt
git checkout test.txt


其中git-bash.exe可以让我们使用Linux的命令去操作Git。而git-cmd.exe则是使用Windows命令操作Git。
事实证明还是使用Linux指令操作Git比较方便，所以我们双击git-bash.exe，在本地创建ssh key：
$ ssh-keygen -t rsa -C "your_email@youremail.com"
后面的是你注册GitHub时候的邮箱地址，后面的一些操作我们默认回车就可以。如下：
————————————————
版权声明：本文为CSDN博主「光仔December」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/acmman/article/details/77621253

验证是否绑定本地成功，在git-bash中验证，输入指令：
$ ssh -T git@github.com
如果第一次执行该指令，则会提示是否continue继续，如果我们输入yes就会看到成功信息：

由于GitHub每次执行commit操作时，都会记录username和email，所以要设置它们：

git config --global user.name ""
git config --global user.eamil""


此时我们需要将本地仓库上传至GitHub，我们在G盘下创建了一个名为“git_repo”的文件夹，
作为本地仓库，然后在其中放置了一个Web应用的源代码（学生信息管理系统）

git init
git add *
git commit -m "commit"

git remote add orgin url



总结：代码先提交到本地库，然后提交远程库，远程库也可以更新到本地库。
创建新仓库的指令：
git init //把这个目录变成Git可以管理的仓库
git add README.md //文件添加到仓库
git add . //不但可以跟单一文件，还可以跟通配符，更可以跟目录。一个点就把当前目录下所有未追踪的文件全部add了 
git commit -m "first commit" //把文件提交到仓库
git remote add origin git@github.com:yourname/youremail.git //关联远程仓库
git push -u origin master //把本地库的所有内容推送到远程库上
————————————————
版权声明：本文为CSDN博主「光仔December」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/acmman/article/details/77621253
