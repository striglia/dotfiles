---
description: "Establish a local git repo on GitHub with public/private options"
allowed-tools: ["Bash", "Read"]
---

# GitHub Repository Establishment

Establishes the current local git repository on GitHub. 

Usage: `/user:gh-establish [public|private] [repo-name]`

Arguments:
- `public|private` (optional): Repository visibility. Defaults to private.
- `repo-name` (optional): Repository name. Defaults to current directory name.

This command will:
1. Check if current directory is a git repository
2. Get the current directory name as default repo name
3. Create a new GitHub repository using `gh repo create`
4. Add the GitHub remote as 'origin'
5. Push the current branch to GitHub

Examples:
- `/user:gh-establish` - Create private repo with current directory name
- `/user:gh-establish public` - Create public repo with current directory name  
- `/user:gh-establish private my-project` - Create private repo named "my-project"
- `/user:gh-establish public awesome-tool` - Create public repo named "awesome-tool"

Requirements:
- Must be run from within a git repository
- GitHub CLI (`gh`) must be installed and authenticated
- Current directory must have at least one commit

I'll execute the following steps:

1. Verify we're in a git repository
2. Check GitHub CLI authentication status
3. Parse arguments for visibility and repo name
4. Create the GitHub repository
5. Add remote origin and push code

$ARGUMENTS