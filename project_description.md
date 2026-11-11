# Terraform Event-Driven Cloud File Processing Platform

## 1. Project Overview

**Project name:** Terraform Event-Driven Cloud File Processing Platform\
**Project type:** Infrastructure as Code (IaC) portfolio project\
**Primary tools:** Terraform, Floci, Docker Desktop, AWS CLI\
**Development environment:** Windows 11, Antigravity IDE, Git Bash
terminal\
**Deployment target:** Floci local AWS emulator only\
**Real AWS deployment:** Explicitly out of scope

### Purpose

Build a locally provisioned, event-driven file-processing platform using
Terraform and Floci. The project will demonstrate Infrastructure as Code
practices, modular Terraform design, AWS-compatible service integration,
permissions, observability, and end-to-end testing without provisioning
paid AWS resources.

The platform accepts a file in an S3-compatible bucket, sends an event
to a queue, invokes a processing function, stores processing metadata in
a database, and records execution logs. Failed messages should be routed
to a dead-letter queue where the emulator and supported integrations
allow it.

This is a learning and portfolio project. It must be described
accurately as **locally provisioned AWS-compatible infrastructure using
Floci**, not as infrastructure deployed to or validated on production
AWS.

------------------------------------------------------------------------

## 2. Important Project Rules for the AI Coding Agent

The coding agent must follow these rules throughout the project.

1.  **Do not generate the entire project at once.** Work in small,
    reviewable phases and wait for approval before moving to the next
    phase.
2.  **Inspect before editing.** Read the existing repository structure
    and files before creating, replacing, or deleting anything.
3.  **Do not overwrite working files blindly.** Explain proposed changes
    and preserve existing user work.
4.  **Verify Floci compatibility first.** Before implementing a service
    or integration, check the current Floci documentation and the actual
    version running locally. Do not assume that AWS service support
    means every API operation or event integration is supported.
5.  **Do not invent provider behavior.** Use documented Terraform AWS
    provider arguments and documented Floci endpoint/configuration
    requirements. If uncertain, identify the uncertainty and investigate
    it before coding.
6.  **Keep local-only execution explicit.** All provider configuration,
    credentials, endpoints, scripts, and instructions must target the
    local Floci instance. Never silently fall back to real AWS
    endpoints.
7.  **No real AWS resources.** Do not run Terraform against real AWS,
    create AWS accounts, configure real AWS credentials, or suggest
    applying against production. Real AWS deployment is outside this
    project's scope.
8.  **No secrets in source control.** Do not commit credentials, access
    keys, tokens, Terraform state, state backups, local data, or
    generated secrets.
9.  **Use least privilege where supported.** IAM policies should grant
    only the actions required by the demo. Do not use broad
    administrator permissions merely to make tests pass.
10. **Test each phase.** Run formatting, validation, plans, and targeted
    functional tests as appropriate. Report actual command output and
    failures; do not claim success without evidence.
11. **Do not hide emulator limitations.** If a feature is unsupported,
    partially supported, or behaves differently from AWS, document it.
    Do not fake a successful integration.
12. **Keep explanations beginner-friendly.** Explain what each Terraform
    resource does, why it exists, dependencies, commands, expected
    output, and cleanup.
13. **Avoid unnecessary complexity.** Do not add Kubernetes, ECS, VPC
    networking, API Gateway, CI/CD, or unrelated services unless the
    project scope is explicitly changed.
14. **Do not use destructive commands without warning and approval.**
    This includes `terraform destroy`, deleting state, removing Docker
    volumes, or deleting project files.

### Required workflow for every phase

For each phase, the agent must:

1.  State the phase objective.
2.  Inspect relevant files and current environment.
3.  Identify assumptions and compatibility questions.
4.  Propose the files/resources to be created or changed.
5.  Implement only the approved phase.
6.  Run relevant checks and tests.
7.  Show changed files and summarize the implementation.
8.  Report passed, failed, skipped, and unverified checks separately.
9.  Wait for the user to approve the next phase.

------------------------------------------------------------------------

## 3. Target Architecture

### Intended processing flow

1.  A test user uploads a file to an S3 bucket.
2.  An S3 object-created event is delivered to an SQS processing queue.
3.  A Lambda function consumes the queued event.
4.  The function reads the event and performs a simple, deterministic
    metadata-processing operation.
5.  The function writes a processing record to DynamoDB.
6.  The function emits logs to CloudWatch Logs.
7.  Messages that repeatedly fail processing are routed to an SQS
    dead-letter queue, if the required Floci behavior is supported.

### Logical architecture

``` text
                    Test client / AWS CLI
                             |
                             | Upload file
                             v
                     S3-compatible bucket
                             |
                             | Object-created event
                             v
                       SQS main queue
                             |
                             | Event source mapping
                             v
                       Lambda function
                         /         \
                        /           \
                       v             v
                 DynamoDB table   CloudWatch Logs

             SQS main queue --failed messages--> SQS DLQ
```

**Important:** This is the intended architecture, not a claim that every
integration is already proven to work in Floci. Confirm the exact event
delivery mechanism and supported APIs before implementing it. If direct
S3-to-SQS notification or Lambda event-source mapping is not supported
by the selected Floci version, stop and present a clearly documented
alternative. Do not silently replace the architecture.

### Initial processing behavior

The Lambda function should be intentionally simple:

-   Accept an SQS event payload.
-   Extract the bucket name and object key from the message, according
    to the actual event format.
-   Validate required fields.
-   Generate or derive a deterministic processing status.
-   Write a record to DynamoDB.
-   Log the processing result.
-   Return an error for invalid input so retry and dead-letter behavior
    can be tested.

Do not download or transform arbitrary file contents in the initial
version. The first objective is to prove the infrastructure event flow
and metadata recording.

------------------------------------------------------------------------

## 4. Planned Technology and Services

  -----------------------------------------------------------------------
  Component                           Intended purpose
  ----------------------------------- -----------------------------------
  Terraform                           Define and manage infrastructure as
                                      code

  Terraform AWS provider              Create AWS-compatible resources
                                      through Floci endpoints

  Floci                               Local AWS API emulator

  Docker Desktop                      Run Floci and Docker-backed
                                      workloads

  AWS CLI                             Interact with Floci endpoints for
                                      testing

  Amazon S3 API                       Store test uploads

  Amazon SQS API                      Queue processing messages

  AWS Lambda API                      Run the processing function

  DynamoDB API                        Store processing metadata

  CloudWatch Logs API                 Inspect function execution logs

  IAM API                             Define execution permissions
  -----------------------------------------------------------------------

### Compatibility gate

Before writing resources, create a compatibility matrix for the exact
Floci version in use.

For each planned service and integration, record:

-   Whether the service is supported by the current Floci version.
-   Whether the required API operations are supported.
-   Whether Terraform AWS provider resource creation is supported.
-   Whether service-to-service event delivery is supported.
-   Any required Docker socket, networking, runtime, or environment
    configuration.
-   A minimal test that proves the behavior.

Do not infer full support from a service name appearing in a feature
list. Verify the specific operations used by this project.

If a required component is not supported, pause and explain the
limitation. Ask the user before changing the architecture.

------------------------------------------------------------------------

## 5. Terraform Repository Structure

Use a modular structure, but create it progressively. Do not generate
empty modules or all files before the first working milestone.

``` text
Terraform-Project/
|
|-- compose.yaml
|-- .gitignore
|-- README.md
|-- PROJECT_DESCRIPTION.md
|
|-- terraform/
|   |-- versions.tf
|   |-- providers.tf
|   |-- main.tf
|   |-- variables.tf
|   |-- outputs.tf
|   |-- terraform.tfvars.example
|   |
|   |-- modules/
|       |-- s3/
|       |-- sqs/
|       |-- lambda/
|       |-- dynamodb/
|       |-- iam/
|       |-- cloudwatch/
|
|-- application/
|   |-- lambda_function.py
|   |-- requirements.txt
|
|-- tests/
    |-- README.md
```

The actual structure may be adjusted if Floci compatibility or Terraform
dependency design requires it. Explain any structural change before
making it.

### Terraform design expectations

-   Pin a tested Terraform AWS provider version using
    `required_providers`.
-   Pin a minimum Terraform CLI version based on the features actually
    used.
-   Use provider aliases or explicit endpoint configuration only if
    needed and supported by the provider version.
-   Configure all required AWS service endpoints to Floci as documented.
-   Use dummy local credentials only if required by the provider or
    emulator. Never use real credentials.
-   Configure a local region consistently, such as `us-east-1`, unless
    Floci documentation requires another value.
-   Use variables for configurable names and settings.
-   Use outputs for useful resource identifiers.
-   Use resource references to express dependencies rather than
    unnecessary hard-coded ordering.
-   Use `for_each` or modules only where they improve clarity.
-   Keep module interfaces small and documented.
-   Do not configure an S3 remote Terraform backend for this local-only
    project. Start with local Terraform state and protect it from source
    control.
-   Do not claim local state is production-grade remote state
    management.

------------------------------------------------------------------------

## 6. Implementation Phases

### Phase 0 - Environment and compatibility discovery

-   Confirm Floci container is running.
-   Confirm Floci API endpoint responds.
-   Confirm Floci UI status and Docker runtime connectivity.
-   Check Terraform CLI installation and version.
-   Check AWS CLI installation and version.
-   Read current Floci documentation for required services and
    integrations.
-   Build the compatibility matrix.
-   Do not create cloud resources yet.

**Exit criteria:** Local tools work, Floci is reachable, and
compatibility risks are understood.

### Phase 1 - Terraform provider connectivity

-   Create the minimum Terraform root configuration.
-   Pin the AWS provider version.
-   Configure the provider to use Floci endpoints.
-   Use dummy local credentials if required.
-   Run `terraform init`.
-   Run `terraform fmt -check`.
-   Run `terraform validate`.
-   Prove provider/API connectivity with a harmless, supported operation
    or a minimal resource plan.

**Exit criteria:** Terraform initializes and validates, and all provider
requests are demonstrably directed to Floci rather than real AWS.

### Phase 2 - Storage and messaging

-   Create the S3 bucket.
-   Enable versioning and encryption only if supported and useful for
    the demonstration.
-   Create the SQS main queue.
-   Create the SQS dead-letter queue.
-   Configure the redrive policy.
-   Apply and verify resources using Terraform and AWS CLI against
    Floci.

**Exit criteria:** Bucket and queues exist locally and their relevant
operations work.

### Phase 3 - Database and IAM

-   Create the DynamoDB metadata table.
-   Define a Lambda execution role.
-   Add narrowly scoped permissions for logs, queue consumption, and
    DynamoDB writes.
-   Add only the permissions required by the chosen event mechanism.
-   Verify role and policy behavior to the extent supported by Floci.

**Exit criteria:** Database and permissions are created and verified.

### Phase 4 - Lambda function

-   Implement the small Python handler.
-   Package the function in the format required by Floci.
-   Create the Lambda function through Terraform.
-   Configure runtime, handler, role, and environment variables.
-   Test invocation with a known event.
-   Verify the DynamoDB record and logs.

**Exit criteria:** Lambda can process a controlled test event and write
a record.

### Phase 5 - Event-driven integration

-   Configure S3 event notification to SQS if supported.
-   Configure Lambda event-source mapping from SQS if supported.
-   Upload a test object.
-   Verify the event reaches SQS and invokes Lambda.
-   Verify the metadata record and logs.
-   Test retries and dead-letter behavior.
-   If any integration is unsupported, stop and report it rather than
    claiming end-to-end success.

**Exit criteria:** The complete event-driven path works, or a clearly
documented emulator limitation and user-approved alternative exists.

### Phase 6 - Documentation and portfolio readiness

-   Write the project README.
-   Include architecture diagram and resource inventory.
-   Document prerequisites and setup commands for Windows 11/Git Bash.
-   Document Terraform commands and test procedure.
-   Include sanitized screenshots and actual test evidence.
-   Document Floci limitations and differences from real AWS.
-   Include cleanup instructions.
-   Ensure no secrets, state files, or local runtime data are committed.

**Exit criteria:** A new reader can understand, reproduce, test, and
clean up the local project.

------------------------------------------------------------------------

## 7. Local Development Environment

The user is working with:

-   Windows 11.
-   Antigravity IDE.
-   Git Bash terminal.
-   Docker Desktop with Linux containers / WSL2.
-   A project directory currently named `Terraform-Project`.
-   Floci exposed locally on port `4566`.

Use Bash-compatible commands in terminal instructions. Do not provide
PowerShell-only commands unless clearly labeled as optional PowerShell
alternatives.

The Floci Docker socket may be mounted to allow Docker-backed runtime
operations. Treat Docker socket access as highly privileged. Do not
expose the Floci port or Docker socket to public networks.

The current Compose file must be inspected before changing it. Do not
replace it without reviewing its current content.

------------------------------------------------------------------------

## 8. Validation and Acceptance Criteria

The project is complete only when the checks below have been performed
and their actual results recorded.

### Tooling

-   [ ] Floci container is running.
-   [ ] Floci API responds locally.
-   [ ] Floci can access the Docker runtime where required.
-   [ ] Terraform CLI is installed.
-   [ ] AWS CLI is installed.
-   [ ] Terraform AWS provider initializes successfully.

### Terraform

-   [ ] `terraform fmt -check` passes.
-   [ ] `terraform validate` passes.
-   [ ] `terraform plan` has been reviewed.
-   [ ] `terraform apply` creates the intended local resources.
-   [ ] Terraform outputs are correct.
-   [ ] Terraform state is local and excluded from Git.

### Application workflow

-   [ ] Test object can be uploaded.
-   [ ] Object event reaches the intended queue.
-   [ ] Lambda receives and processes the message.
-   [ ] DynamoDB contains the expected record.
-   [ ] CloudWatch Logs contain the expected execution details.
-   [ ] Failure and retry behavior is tested.
-   [ ] DLQ behavior is tested where supported.

### Cleanup and repository hygiene

-   [ ] `terraform destroy` is tested only after warning and user
    approval.
-   [ ] Local resources are verified as removed.
-   [ ] `.gitignore` excludes Terraform state, local variables,
    credentials, generated packages, and local Floci data.
-   [ ] No credentials or sensitive information are committed.
-   [ ] Documentation distinguishes verified behavior from unverified
    behavior.

A check must be marked **not supported**, **not tested**, or **blocked**
when appropriate. Never mark it as passed based on assumption.

------------------------------------------------------------------------

## 9. Git and Security Requirements

At minimum, `.gitignore` should exclude:

``` gitignore
# Terraform working files
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
crash.log
crash.*.log
.terraform.lock.hcl.tmp

# Local variable files and secrets
terraform.tfvars
*.auto.tfvars
.env
.env.*

# Local Floci runtime data
data/

# Python artifacts
__pycache__/
*.py[cod]
.venv/
venv/

# Generated Lambda packages
*.zip

# IDE and operating system files
.idea/
.vscode/
.DS_Store
Thumbs.db
```

Review this list before use. The Terraform dependency lock file
(`.terraform.lock.hcl`) should normally be committed to make provider
selections reproducible. Do not ignore it.

Never commit actual credentials, even if they are dummy credentials in
local development. Use clearly documented local-only environment
variables or provider configuration.

------------------------------------------------------------------------

## 10. Documentation and Reporting Standards

For each implementation phase, provide:

-   Objective.
-   Files created or modified.
-   Terraform resources introduced.
-   Explanation of each resource.
-   Commands executed.
-   Actual test results.
-   Floci-specific limitations.
-   Remaining work.
-   Exact next step requiring user approval.

The README must not claim:

-   Deployment to AWS.
-   Production readiness.
-   Real AWS cost optimization.
-   AWS high availability or disaster recovery.
-   Complete AWS service parity.

Unless those claims are independently verified in the appropriate
environment.

Appropriate portfolio wording after successful completion:

> Built a modular Terraform-managed, event-driven cloud file-processing
> platform in a local Floci AWS-emulated environment. Integrated
> S3-compatible storage, SQS messaging, Lambda processing, DynamoDB
> metadata persistence, IAM permissions, and CloudWatch-compatible
> logging, with documented compatibility tests and emulator limitations.

Only list integrations that were actually implemented and tested.

------------------------------------------------------------------------

## 11. Immediate Next Task

**Do not start generating the full project.**

The next task is Phase 0: inspect the existing repository and verify the
local toolchain and Floci compatibility.

The agent should begin by:

1.  Listing the current project files without deleting or modifying
    anything.
2.  Reading the existing `compose.yaml`.
3.  Checking Floci container status and recent logs.
4.  Checking the Floci API endpoint.
5.  Checking whether Terraform and AWS CLI are installed.
6.  Researching the current Floci documentation for S3, SQS, Lambda,
    DynamoDB, IAM, CloudWatch Logs, and the required event integrations.
7.  Producing a compatibility matrix and a proposed Phase 1 plan.

Stop after reporting Phase 0 findings. Do not create Terraform resources
until the user approves the next phase.

------------------------------------------------------------------------

## 12. Guiding Principle

**Correctness before code volume.**

The objective is not to generate many Terraform files. The objective is
to build a small, understandable, reproducible infrastructure project,
verify each layer, understand its limitations, and produce evidence that
can withstand technical interview questions.
