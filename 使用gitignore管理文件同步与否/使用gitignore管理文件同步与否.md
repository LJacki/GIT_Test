# 使用gitignore管理文件同步与否

在官方的`Git`手册中找到了`gitignore`的相关介绍，[这里是连接](https://git-scm.com/docs/gitignore)。文中内容介绍的非常详细，这里摘录一部分作为参考：

## EXAMPLES

- The pattern `hello.*` matches any file or folder whose name begins with `hello`. If one wants to restrict this only to the directory and not in its subdirectories, one can prepend the pattern with a slash, i.e. `/hello.*`; the pattern now matches `hello.txt`, `hello.c` but not `a/hello.java`.
- The pattern `foo/` will match a directory `foo` and paths underneath it, but will not match a regular file or a symbolic link `foo` (this is consistent with the way how pathspec works in general in Git)
- The pattern `doc/frotz` and `/doc/frotz` have the same effect in any `.gitignore` file. In other words, a leading slash is not relevant if there is already a middle slash in the pattern.
- The pattern "foo/*", matches "foo/test.json" (a regular file), "foo/bar" (a directory), but it does not match "foo/bar/hello.c" (a regular file), as the asterisk in the pattern does not match "bar/hello.c" which has a slash in it.

**以下内容为谷歌翻译：**

- 该模式`hello.*`匹配名称以开头的任何文件或文件夹`hello`。如果只想将此限制于目录而不是其子目录，则可以在模式前面加上斜杠，即`/hello.*`；模式现在匹配`hello.txt`，`hello.c`但是不 匹配`a/hello.java`。
- 该模式`foo/`将匹配目录`foo`及其下的路径，但不匹配常规文件或符号链接`foo`（这与pathspec通常在Git中的工作方式一致）
- 模式`doc/frotz`和`/doc/frotz`在任何`.gitignore`文件中都具有相同的效果。换句话说，如果模式中已经存在中间斜杠，那么前导斜杠就无关紧要。
- 模式“ foo / *”匹配“ foo / test.json”（常规文件），“ foo / bar”（目录），但不匹配“ foo / bar / hello.c”（常规文件） ），因为该模式中的星号与其中带有斜杠的“ bar / hello.c”不匹配。

## 我的翻译

我的翻译就是我觉得比较重要的：

- 一行为一个`pattern`；
- 加\#为注释，建议注释不要再`pattern`后面，单独为一行；
- 如果`pattern`前面加`“!”`，表明不对此目录或文件做忽略操作；
- `“/Work”`为整个`Work`目录，包含其下子目录与文件；
- 如果`pattern`中已经有了中间`“/”`，那么第一个`“/”`就无关紧要了；
- `gitignore`操作只对`untracked`的文件有效，如果有`stage`的操作，需要先进行`unstaged`；

下面针对之前的`Vivado`工程，有个例子，其内容为：

```bash
# Vivado Project
# 制定忽略名称为Work和Mcs的文件夹；
/Work
/Mcs

# Simulation Filse
# !表明忽略除了这个文件或文件夹以外的文件或文件夹
# !*/Work/project_1.sim/sim_1/behav/modelsim/*.do


# 保留bat文件
# !*/Work/auto_prj.bat
# !*/Work/auto_prj.tcl

```

其含义为忽略`Work`以及`Mcs`目录下所有内容。

## 删除远程仓库上传的ignore文件

创建仓库时，没有提交`gitignore`文件，`commit`和`push`之后，远端就存在了这些文件；

而后如果再提交包含这些目录的`gitignore`文件，依然对于远端来说是进行了修改；

那么就希望可以删除远端仓库中的相关文件，而保留本地的文件；

这时候==不能==直接使用`git rm dircetory(想要删除的文件夹名称)`，会删除本地仓库中的文件；

可以使用如下指令删除缓冲；

```bash
git rm -r --cached directory(想要删除的文件夹名称)
```

之后在进行`commit`和`push`就可以将远程仓库中的相关文件删除了，之后可以直接使用`git add –all`来添加修改的内容，这样上传的文件就会收到`.gitignore`约束了。

第三部分内容参考：https://www.cnblogs.com/rainbowk/p/10932322.html