The passage is excerpted from[GitHub package](https://flight-manual.atom.io/using-atom/sections/github-package/#open-any-issue-or-pull-request);

# GitHub package

The github package brings Git and GitHub integration right inside Atom.

- [Initialize](https://flight-manual.atom.io/using-atom/sections/github-package/#initialize-repositories)
- [Clone](https://flight-manual.atom.io/using-atom/sections/github-package/#clone-repositories)
- [Branch](https://flight-manual.atom.io/using-atom/sections/github-package/#branch)
- [Stage](https://flight-manual.atom.io/using-atom/sections/github-package/#stage)
- [Discard](https://flight-manual.atom.io/using-atom/sections/github-package/#discard-changes)
- [Commit](https://flight-manual.atom.io/using-atom/sections/github-package/#commit)
- [Amend and undo](https://flight-manual.atom.io/using-atom/sections/github-package/#amend-and-undo)
- [Publish and push](https://flight-manual.atom.io/using-atom/sections/github-package/#publish-and-push)
- [Fetch and pull](https://flight-manual.atom.io/using-atom/sections/github-package/#fetch-and-pull)
- [Resolve conflicts](https://flight-manual.atom.io/using-atom/sections/github-package/#resolve-conflicts)
- [Create a Pull Request](https://flight-manual.atom.io/using-atom/sections/github-package/#create-a-pull-request)
- [View Pull Requests](https://flight-manual.atom.io/using-atom/sections/github-package/#view-pull-requests)
- [Checkout a Pull Request](https://flight-manual.atom.io/using-atom/sections/github-package/#checkout-a-pull-request)
- [Open any Issue or Pull Request](https://flight-manual.atom.io/using-atom/sections/github-package/#open-any-issue-or-pull-request)
- [View Pull Request review comments](https://flight-manual.atom.io/using-atom/sections/github-package/#view-pull-request-review-comments)
- [Navigate Pull Request review comments](https://flight-manual.atom.io/using-atom/sections/github-package/#navigate-pull-request-review-comments)
- [Respond to a Pull Request review comment](https://flight-manual.atom.io/using-atom/sections/github-package/#respond-to-a-pull-request-review-comment)

Most of the functionality lives within the Git and GitHub dock items.

![The Git and GitHub panels](https://flight-manual.atom.io/using-atom/images/github-panels.png)

There are different ways to access them, probably the most common way is through their keybindings:

- Open the **Git** panel: Ctrl+9
- Open the **GitHub** panel: Ctrl+8

Another way is from the menu: `Packages -> GitHub -> Toggle Git Tab and Toggle GitHub Tab`

Or you can also toggle the Git panel from the Status Bar by clicking on the changed files icon:

![Open Git panel](https://flight-manual.atom.io/using-atom/images/github-open-git-panel.png)

------

## Initialize repositories

In case a project doesn't have a Git repository yet, you can create one from the Git panel.

![Initialize repositories](https://flight-manual.atom.io/using-atom/images/github-initialize.png)

## Clone repositories

To clone a repository, open the GitHub panel while you have no project folders open in Atom and click "Clone an existing GitHub repository". In the dialog, paste the URL of a repository and click "Clone". The new project will be added to the Tree View.

![GitHub panel](https://flight-manual.atom.io/using-atom/images/github-without-projects.png)

![Clone dialog](https://flight-manual.atom.io/using-atom/images/github-clone.png)

Alternately, run the `GitHub: Clone` command to open the Clone dialog any time.

## Branch

To open the branch tooltip, click the branch icon in the Status Bar. From there you can **create** or **switch** branches.

![Create or switch branches](https://flight-manual.atom.io/using-atom/images/github-branch.png)

## Stage

After making some changes, **stage** anything you want to be part of the next commit. Choose between staging...

- **All changes**: Click the "Stage All" button in the "Unstaged Changes" bar.
- **Files**: Double-click a file or select a file and press Enter.
- **Hunk**: Click on the "Stage Hunk" button or select a hunk and press Enter.
- **Lines**: Click on a line (or drag on multiple lines) to select, then click on the "Stage Selection" button. Or use the Cmd-/ key to toggle from hunk mode to line mode, then press Ctrl-Enter to stage just a single line.

Use the Ctrl-Left or Ctrl-Right arrow key to switch between file list and the diff view. Unstaging can be done in the same way.

![Stage changes](https://flight-manual.atom.io/using-atom/images/github-stage.png)

## Discard changes

If you no longer want to keep some changes, you can discard them. It's similar to staging, but accessible behind a context menu.

- **All changes**: Click the ... menu in the "Unstaged Changes" header and choose "Discard All Changes".
- **Files**: Right-click a file (or multiple) and choose "Discard Changes".
- **Hunk**: Click on the trash icon in the top bar of a hunk.
- **Lines**: Right-click on a line (or multiple) and choose "Discard Selection".

![Discard changes](https://flight-manual.atom.io/using-atom/images/github-discard.png)

## Commit Preview

To double check **all changes** that are going into your next commit, click the "**See All Staged Changes**" button above the commit message box. It lets you see all of your staged changes in a single pane. This "commit preview" can also serve as an inspiration for writing the commit message.

![Commit Preview](https://flight-manual.atom.io/using-atom/images/github-commit-preview.png)

## Commit

Once you've staged your changes, enter a commit **message**. Feel free to describe the commit in more detail after leaving an empty line. Finalize by clicking the **Commit** button. If you need more space, click the expand icon at the bottom right. It will open a commit editor in the center.

![Commit changes](https://flight-manual.atom.io/using-atom/images/github-commit.png)

To add multiple **co-authors** to a commit, click the "👤➕" icon in the bottom left corner of the commit message editor. Now you can search by name, email or GitHub username to give credit to a co-author.

![Commit with co-authors](https://flight-manual.atom.io/using-atom/images/github-commit-with-co-authors.png)

## Amend and undo

In case you forgot to commit a change and would like to add it to your previous commit, right-click on the last commit, then choose "Amend" from the context menu.

![Amend previous commit](https://flight-manual.atom.io/using-atom/images/github-amend.png)

If you want to edit the commit message of your last commit, or add/remove changes, click on the "Undo" button. It will roll back to the state just before you clicked on the commit button.

![Undo previous commit](https://flight-manual.atom.io/using-atom/images/github-undo.png)

## View commits

Once you've made some commits, click on a commit message in the recent commit list to see the full diff and commit message associated with each:

![View commit detai](https://flight-manual.atom.io/using-atom/images/github-commit-detail.png)

## Publish and push

When you're ready to share your changes with your team members, click the **Publish** button in the Status Bar. It will push your local branch to the remote repository. After making more commits, you can **Push** them as well from the Status Bar.

![Publish and push commits](https://flight-manual.atom.io/using-atom/images/github-publish-push.png)

## Fetch and pull

From time to time it's a good idea to click on the **Fetch** button to see if any other team member pushed changes. If so, click on **Pull** to merge the changes into your local branch.

![Fetch and pull commits](https://flight-manual.atom.io/using-atom/images/github-fetch-pull.png)

If you prefer to **rebase** when pulling, you can configure Git to make it the default behavior:

```
git config --global --bool pull.rebase true
```

Learn more about [merge vs. rebase](https://mislav.net/2013/02/merge-vs-rebase/).

## Resolve conflicts

Sometimes there can be conflicts when trying to merge. Files that have merge conflicts will show up in the "Merge Conflicts" list. Click on a file to open the editor. There you can **resolve** the conflict by picking a version or make further edits. Once done, stage the file and commit.

![Resolve conflicts](https://flight-manual.atom.io/using-atom/images/github-resolve-conflicts.png)

## Create a Pull Request

When your changes are ready to be reviewed by your team members, open the "GitHub" panel Ctrl+8 and click on **Open new pull request**. It will open the browser where you can continue creating a pull request. If commits haven't been pushed or the branch isn't published yet, the GitHub package will do that automatically for you.

![Create a Pull Request](https://flight-manual.atom.io/using-atom/images/github-create-a-pull-request.png)

## View Pull Requests

Once the pull request is created, it will appear under **Current pull request** at the top of the panel. Underneath is a list of **Open pull requests**. It lets you quickly find a pull request by avatar, title or PR number. It also lets you keep an eye on the CI status. Clicking on a pull request in the list opens a center pane with more details, the timeline and conversations.

![View Pull Requests](https://flight-manual.atom.io/using-atom/images/github-view-pull-requests.png)

## Open any Issue or Pull Request

You can open issues or pull requests from any repo on GitHub. To do so, run the `GitHub: Open Issue Or Pull Request` command and paste the URL from an issue or pull request. Then press the **Open Issue or Pull Request** button and it will open a center pane. This lets you keep an issue or pull request as a reference, when working in another repo.

![Open Issue or Pull Request](https://flight-manual.atom.io/using-atom/images/github-open-issue-or-pull-request.png)

## Checkout a Pull Request

To test a pull request locally, open it in the workspace center by clicking on the pull request in the "open pull requests" list from the GitHub tab, then click on the **Checkout** button. It will automatically create a local branch and pull all the changes. If you would like to contribute to that pull request, start making changes, commit and push. Your contribution is now part of that pull request.

![Checkout a pull request](https://flight-manual.atom.io/using-atom/images/github-checkout.png)

## View Pull Request review comments

To view review comments on a Pull Request, open the Reviews Tab from the **See Reviews** button from the footer of a Pull Request Pane. Alternatively, if the pull request has already been checked out, Reviews Tab can also be open from the same button on GitHub Tab.

![Open review tab from footer](https://flight-manual.atom.io/using-atom/images/github-see-review-footer.png)

## Navigate Pull Request review comments

You can see all the review summaries and comments of a pull request in the Reviews Tab. The comment section has a progress bar to help you keep track of how close are you to finish addressing the Pull Request comments (i.e. marking all comment threads on a Pull Request as "resolved"). Comment threads are greyed out after they have been resolved.

![Review tab](https://flight-manual.atom.io/using-atom/images/github-review-tab.png)

After the pull request branch has been checked out, you can click **Jump To File** to open the commented on file and make changes as per the review comment right in the editor. If you would like to get the full context of the review comment, click **Open Diff** to open the diff view with line highlighting.

![Jump to file from review tab](https://flight-manual.atom.io/using-atom/images/github-review-jump-to-file.png)

Conversely, in-editor comments are indicated by the comment icon in the gutter. Clicking the icon, either from within the editor or the diff view, will take you back to the Reviews Tab.

![Open review tab from diff](https://flight-manual.atom.io/using-atom/images/github-open-review-from-diff.png)

## Respond to a Pull Request review comment

To respond to a Pull Request review comment, type your message and click **Comment**; a single line comment will be created in the same thread as the comment you responded to. After addressing a Pull Request review comment, click **Resolve conversation** to mark the whole thread as "resolved". The progress bar in the "Comments" section will update accordingly.

![Respond to a Pull Request review comment](https://flight-manual.atom.io/using-atom/images/github-review-reply.png)
