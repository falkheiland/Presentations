---
marp: true
theme: gaia
_class: lead
paginate: true
backgroundColor: #fff
---

![bg left:40% 80%](./Media/scriptrunner-logo_rgb_original.svg)

# Git Workflow for use with ScriptRunner

How to use git while working with ScriptRunner.

**Falk Heiland**

https://github.com/falkheiland

https://fosstodon.org/@falkheiland

---

# Git ?

- version control system
- tracks changes of files in a repository
  - no wasting of time tracking and merging different versions manually
- easier collaboration
  -  Everyone has their local instance of the code, and everyone can work (on their branches) at the same time. 
  -  Git works offline because almost all operations run locally.
---

# Git Workflow

![height:400px](./Media/gitdiagram.svg)

--- 

- The Working Tree is the area where you are currently working
- The Staging Area is when git starts tracking and saving changes that occur in files
- The Local Repository is everything in your .git directory
- The Remote Repository is a separate Git repository intended to collect and host content pushed to it from one or more local repositories.
---

# Branching strategy

- branches are independent workspaces within the codebasis

## Gitflow

![height:200px](./Media/gitflow.svg)

---

## main branch :

- contains production code

## dev branch:

- contains development code
- long living branch

---
# Git and ScriptRunner

## Git

1. use a (self-)hosted  Git service (GitHub, GitLab, Gitea etc.)
2. create a repo `sr-scripts` with the default branch `main`
3. create an initial file `README.md`
4. create a development branch `dev`

---
## ScriptRunner

- does not make use of Git
- expects and manages your scripts in the ScriptRunner Library
- tags folders in the ScriptRunner Library

1. create a folder `GIT` in the ScriptRunner Library folder
2. create folders `main` and `dev` in `GIT`
3. clone the repo in the folders `main` and `dev`
4. checkout branch `main`in folder `main\sr-scripts`
5. checkout branch `dev`in folder `dev\sr-scripts`
---
## Folder structure

```shell
cd C:\ProgramData\ScriptRunner\ScriptMgr
tree
C:.
└───GIT
    ├───dev
    │   └───sr-scripts
    │       └───README.md

    └───main
    │   └───sr-scripts
    │       └───README.md
```
