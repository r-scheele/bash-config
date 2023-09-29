# Command docs


- **CRC Functions**:
    - `crcStop`: Stops the CodeReady Containers (CRC) instance.
    - `crcDelete`: Deletes the CRC instance.
    - `crcCleanUp`: Cleans up the CRC setup.
    - `crcConfigSetCpus`: Configures the number of CPUs for CRC.
    - `crcConfigSetMemory`: Configures the memory for CRC.
    - `crcSetup`: Sets up the CRC environment.
    - `crcStart`: Starts CRC with the given configurations.
    - `crcRun`: Master function for initializing and running CRC.
  
- **Tenant and Operator Management**:
    - `upgradetenant`: Upgrades a tenant in a namespace using Helm.
    - `upgradeoperator`: Upgrades the MinIO operator in a namespace using Helm.
    - `install452`: Installs the 4.5.2 version of the MinIO Operator and Tenant.
    - `installoperator`: Routes to the appropriate function for installing the MinIO operator based on user input.
    - `installoperatorhelp`: Provides guidance for the `installoperator` function.
    - `installOperatorFromGitHub`: Installs the operator directly from a GitHub tag.
    - `createOperatorYAML` and `createTenantYAML`: Generate YAML configurations for the MinIO operator and tenant.
    - `installoperatorhelm`: Installs the MinIO operator via Helm.
    - `installtenant`: Manages the MinIO tenant installation using various methods based on user input.
  
- **Exposure and Ingress Functions**:
    - `installoperatornp`: Installs the MinIO operator and exposes it via NodePort.
    - `exposeOperatorViaNodePort`: Exposes the MinIO operator through a Kubernetes NodePort.
    - `installoperatoringress`: Installs the MinIO operator and exposes it using Kubernetes ingress with the NGINX Ingress controller.
    - `installtenantnginx`: Installs the MinIO tenant and sets up its exposure via NGINX.
    - `installtenantnp`: Installs the MinIO tenant and plans for its exposure via NodePort (although actual NodePort exposure is marked as a TODO).
    - `installtenanthelm`: Installs the MinIO tenant using Helm.
  
- **Miscellaneous**:
    - `installubuntu`: Spins up an Ubuntu pod in a given Kubernetes namespace.
    - `printMessage`: echoes (prints) whatever is passed to it. 
- **Git Operations**:
    - `update <REPO>`: Takes in a short repository name, updates to the proper branch, and performs a set of git operations to fetch, rebase, and push changes.
    - `convert_short_name_to_proper_name <REPO>`: Converts short repo names to their respective official repository names, branch, and account details.
    - `gc <REPO>`: Clones a given repository using a shorthand or its original name to the home directory from a specific github account.
    - `createPR <REPO> <NEW_BRANCH_FOR_PR>`: Provides an interactive guide for creating a PR for a specified repository and branch.
    - `ghpr <PR_NUMBER>`: Sets the current directory's repository as default and checks out the specified GitHub pull request by its number.
    - `commit`: add all changes to the staging area (git add .), commit those changes with the message 'a' (git commit -m 'a'), and then push those changes to the remote repository (git push).
    - `gcommit` function allows you to commit changes with a custom message like `gcommit "Your custom message here"`
- **Rebase Operations**:
    - `squashdocs`: Interactive rebase for the MinIO docs repository on its main branch.
    - `squashrh`: Interactive rebase for the MinIO release-hub repository on its main branch.
    - `squashrm`: Interactive rebase for the MinIO release-manager repository on its master branch.
    - `squashdp`: Interactive rebase for the MinIO directpv repository on its master branch.
    - `squashpy`: Interactive rebase for the MinIO Python SDK repository on its master branch.
    - `squashoperator`: Interactive rebase for the MinIO operator repository on its master branch.
    - `squashconsole`: Interactive rebase for the MinIO console repository on its master branch.
    - `squashenterprise`: Interactive rebase for the MinIO enterprise repository on its master branch.

- **MinIO Operations**:
    - `clearMinIO`: Clears data and system files from specific MinIO data volumes.
    - `upgradeMinIO`: Replaces the old MinIO binary with the latest version for the Darwin-ARM64 architecture.
    - `upgradeMC`: Replaces the old MinIO client (`mc`) binary with the latest version for the Darwin-AMD64 architecture.
    - `getminio`: Downloads and installs the MinIO server binary for Darwin-ARM64 architecture.

- **Kubernetes Context Switching**:
    - `intelcontext`: Switches the Kubernetes context to `kubernetes-admin@kubernetes`.
    - `kindcontext`: Switches the Kubernetes context to `kind-kind`.
    - `dpcontext`: Switches the Kubernetes context to `directpv-admin@directpv`.

