# gitignore

git手册中的介绍：https://git-scm.com/docs/gitignore

## EXAMPLES

- The pattern `hello.*` matches any file or folder whose name begins with `hello`. If one wants to restrict this only to the directory and not in its subdirectories, one can prepend the pattern with a slash, i.e. `/hello.*`; the pattern now matches `hello.txt`, `hello.c` but not `a/hello.java`.
- The pattern `foo/` will match a directory `foo` and paths underneath it, but will not match a regular file or a symbolic link `foo` (this is consistent with the way how pathspec works in general in Git)
- The pattern `doc/frotz` and `/doc/frotz` have the same effect in any `.gitignore` file. In other words, a leading slash is not relevant if there is already a middle slash in the pattern.
- The pattern "foo/*", matches "foo/test.json" (a regular file), "foo/bar" (a directory), but it does not match "foo/bar/hello.c" (a regular file), as the asterisk in the pattern does not match "bar/hello.c" which has a slash in it.

谷歌翻译：

- 该模式`hello.*`匹配名称以开头的任何文件或文件夹`hello`。如果只想将此限制于目录而不是其子目录，则可以在模式前面加上斜杠，即`/hello.*`；模式现在匹配`hello.txt`，`hello.c`但是不 匹配`a/hello.java`。
- 该模式`foo/`将匹配目录`foo`及其下的路径，但不匹配常规文件或符号链接`foo`（这与pathspec通常在Git中的工作方式一致）
- 模式`doc/frotz`和`/doc/frotz`在任何`.gitignore`文件中都具有相同的效果。换句话说，如果模式中已经存在中间斜杠，那么前导斜杠就无关紧要。
- 模式“ foo / *”匹配“ foo / test.json”（常规文件），“ foo / bar”（目录），但不匹配“ foo / bar / hello.c”（常规文件） ），因为该模式中的星号与其中带有斜杠的“ bar / hello.c”不匹配。

ignore操作只对untracked的文件有效，如果有stage的操作，需要先进行unstaged；

**在使用.gitignore文件后如何删除远程仓库中以前上传的此类文件而保留本地文件**
在使用git和github的时候，之前没有写.gitignore文件，就上传了一些没有必要的文件，在添加了.gitignore文件后，就想删除远程仓库中的文件却想保存本地的文件。这时候**不可以直接使用"git rm directory"**，这样会删除本地仓库的文件。可以使用"**git rm -r –cached directory**"来删除缓冲，然后进行"**commit**"和"**push**"，这样会发现远程仓库中的不必要文件就被删除了，以后可以直接使用"**git add -A**"来添加修改的内容，上传的文件就会受到.gitignore文件的内容约束。

