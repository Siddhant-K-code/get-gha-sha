# Get Commit SHA of GitHub Actions

## Overview

This script fetches the commit SHA for a specified tag of a GitHub repository. If no tag is specified, it fetches the latest release's commit SHA. It utilizes the GitHub API to retrieve this information and ensures that you are referencing the exact commit SHA for your workflows, enhancing security and stability. Read here about why using SHA is better than using tags: [Why you should use commit SHAs in your GitHub Actions workflows](https://x.com/Siddhant_K_code/status/1796919592327028746).

## Usage

### Basic Usage

```bash
./get_commit_sha.sh <owner>/<repo> [<tag-name>]
```

- `<owner>/<repo>`: The owner and repository name (e.g., `octocat/Hello-World`).
- `[<tag-name>]` (optional): The specific tag name. If not provided, the latest release tag is used.

### Examples

- Fetch the latest release commit SHA for a repository:

  ```bash
  ./get_github_actions_sha.sh actions/checkout
  ```

- Fetch the commit SHA for a specific tag:
  ```bash
  ./get_github_actions_sha.sh actions/checkout v4.1.6
  ```

## Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/Siddhant-K-code/get-gha-sha.git
   cd get-gha-sha
   ```

2. **Make the Script Executable**

   ```bash
   chmod +x get_github_actions_sha.sh
   ```

3. **Install Dependencies**

   Ensure you have `curl` and `jq` installed on your system. You can install `jq` using your package manager:

   ```bash
   sudo apt-get install jq  # For Debian-based systems
   sudo yum install jq      # For RedHat-based systems
   brew install jq          # For macOS
   ```

## Example Output

```bash
actions/checkout@a5ac7e51b41094c92402da3b24376905380afc29 # v4.1.6
```
