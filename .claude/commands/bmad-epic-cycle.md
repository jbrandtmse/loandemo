---
description: 'Execute the BMAD Method development cycle using Agent Teams for all stories in an Epic or range of Epics'
---

# BMAD Epic Development Cycle

You are the **Team Lead** orchestrating the BMAD Method development cycle using the **spawn-on-demand** agent pattern. You will process stories sequentially through a pipeline of create, develop, review, commit, QA, and commit.

## Configuration

<config>
  <epics_file>_bmad-output/planning-artifacts/epics.md</epics_file>
  <sprint_status>_bmad-output/implementation-artifacts/sprint-status.yaml</sprint_status>
  <story_dir>_bmad-output/implementation-artifacts</story_dir>
  <workflow_xml>_bmad/core/tasks/workflow.xml</workflow_xml>
  <create_story_workflow>_bmad/bmm/workflows/4-implementation/create-story/workflow.yaml</create_story_workflow>
  <dev_story_workflow>_bmad/bmm/workflows/4-implementation/dev-story/workflow.yaml</dev_story_workflow>
  <code_review_workflow>_bmad/bmm/workflows/4-implementation/code-review/workflow.yaml</code_review_workflow>
  <qa_automate_workflow>_bmad/bmm/workflows/testarch/automate/workflow.yaml</qa_automate_workflow>
  <bmm_config>_bmad/bmm/config.yaml</bmm_config>
</config>

## Critical Rules

<rules CRITICAL="TRUE">

### Anti-Patterns (NEVER USE)
- **Do NOT use TaskCreate, TaskList, or TaskUpdate** - Agents poll TaskList on every wake-up and self-schedule regardless of constraints
- **Do NOT keep agents alive between tasks** - Idle agents self-schedule. Always shut down after each task
- **Do NOT rely on blockedBy** - The task system does NOT enforce blockedBy
- **Do NOT spawn a story-creator agent** - Lead must create stories directly as a pipeline gate

### Spawn-on-Demand Pattern (ALWAYS USE)
For each pipeline step requiring an agent:
1. **Spawn** a fresh agent using the Task tool with team_name
2. **Dispatch** the task via SendMessage immediately after spawn
3. **Wait** for the agent's completion message
4. **Shut down** the agent via SendMessage(type: "shutdown_request")
5. **Re-spawn** a fresh agent for the next task

### Agent Prompt Template
Every agent spawn prompt MUST include this block:
```
**CRITICAL - Single-Task Agent:**
- You will receive exactly ONE task via SendMessage from the lead.
- Execute the workflow for that task.
- When done, send a completion message to the lead.
- After sending the completion message, STOP completely.
- Do NOT call TaskList, do NOT look for more work.
- Approve any shutdown request immediately.
- Do NOT use TaskList, TaskCreate, or TaskUpdate.

Wait for the lead to send you your task. Do NOT start any work until the lead messages you.
```

### Code Review Auto-Resolution
Automatically resolve all HIGH and MEDIUM severity issues found during code review using your best judgment and BMAD guidance. When the code-reviewer agent presents findings, instruct it to fix them automatically (option 1).

### When to Pause
Only pause to ask the user a question if:
- The acceptance criteria or requirements are ambiguous
- There are multiple reasonable design options and the user's preference matters
- Proceeding would risk breaking important constraints (security, compliance, performance, interoperability)

</rules>

## Execution Steps

<steps CRITICAL="TRUE">

### Step 1: Initialize

1. Read the epics file to get the complete story list
2. Read sprint-status.yaml to understand current progress
3. Read the BMM config.yaml for project settings
4. Determine which stories to process:
   - If user specified an epic number or range (e.g., "epic 1", "epics 1-3"), filter to those
   - If user specified specific stories (e.g., "story 1.2", "stories 1.1-1.3"), filter to those
   - Otherwise, process ALL stories with "backlog" status in sprint-status.yaml
5. Create a team using TeamCreate with team_name "epic-cycle"
6. Present the story pipeline to the user and begin processing

### Step 2: For Each Story - Execute Pipeline

Process each story sequentially through this pipeline:

#### Step 2a: Lead Creates Story (Pipeline Gate)

**CRITICAL: The lead executes this directly - NOT via an agent.**

1. Load the FULL workflow engine: Read _bmad/core/tasks/workflow.xml
2. Load the create-story workflow config: Read _bmad/bmm/workflows/4-implementation/create-story/workflow.yaml
3. Follow the workflow.xml instructions to execute the create-story workflow for this story
4. The workflow will auto-discover the next backlog story from sprint-status.yaml
5. Enter YOLO mode to complete story creation without pausing for user confirmation at each step
6. After story file is created, verify sprint-status.yaml shows "ready-for-dev" for this story

#### Step 2b: Spawn Developer Agent

1. Spawn a fresh agent using the Task tool:
   - subagent_type: "general-purpose"
   - team_name: "epic-cycle"
   - name: "developer"
   - mode: "bypassPermissions"
   - Prompt must include:
     - The single-task agent block (from rules above)
     - Instructions to load workflow.xml and dev-story workflow.yaml
     - The story file path to develop
     - Instructions to enter YOLO mode and execute autonomously
     - The project's CLAUDE.md conventions (ObjectScript naming, %Status pattern, etc.)

2. Send the developer agent its task via SendMessage:
   - type: "message"
   - recipient: "developer"
   - content: The story file path and instruction to execute the dev-story workflow for that story, using YOLO mode for autonomous execution

3. Wait for the developer's completion message

4. Shut down the developer via SendMessage(type: "shutdown_request", recipient: "developer")

#### Step 2c: Spawn Code Reviewer Agent

1. Spawn a fresh agent using the Task tool:
   - subagent_type: "general-purpose"
   - team_name: "epic-cycle"
   - name: "code-reviewer"
   - mode: "bypassPermissions"
   - Prompt must include:
     - The single-task agent block (from rules above)
     - Instructions to load workflow.xml and code-review workflow.yaml
     - The story file path to review
     - Instructions to auto-fix all HIGH and MEDIUM issues (choose option 1 when prompted)
     - Instructions to enter YOLO mode

2. Send the code-reviewer its task via SendMessage:
   - type: "message"
   - recipient: "code-reviewer"
   - content: The story file path and instruction to execute the code-review workflow, auto-fixing all HIGH/MEDIUM issues

3. Wait for the code-reviewer's completion message

4. Shut down the code-reviewer via SendMessage(type: "shutdown_request", recipient: "code-reviewer")

#### Step 2d: Lead Commits and Pushes (Feature)

1. Stage all changed files relevant to this story (use git add with specific file paths from the story's File List section)
2. Commit with message: "feat(story-X.Y): <story title> - implementation and review"
3. Push to remote

#### Step 2e: Spawn QA Agent

1. Spawn a fresh agent using the Task tool:
   - subagent_type: "general-purpose"
   - team_name: "epic-cycle"
   - name: "qa-agent"
   - mode: "bypassPermissions"
   - Prompt must include:
     - The single-task agent block (from rules above)
     - Instructions to load workflow.xml and qa-automate workflow.yaml
     - The story file path for test context
     - Instructions to generate and validate tests for the story
     - Instructions to enter YOLO mode

2. Send the qa-agent its task via SendMessage:
   - type: "message"
   - recipient: "qa-agent"
   - content: The story file path and instruction to execute the qa-automate workflow

3. Wait for the qa-agent's completion message

4. Shut down the qa-agent via SendMessage(type: "shutdown_request", recipient: "qa-agent")

#### Step 2f: Lead Commits and Pushes (Tests)

1. Stage all test files and related changes
2. Commit with message: "test(story-X.Y): <story title> - automated test coverage"
3. Push to remote

#### Step 2g: Log Completion

Write a brief completion log entry to `_bmad-output/implementation-artifacts/epic-cycle-log.md` (append) with:
- Story ID/name
- Files touched (from story File List)
- Key design decisions
- Issues auto-resolved vs. those requiring user input
- Timestamp

### Step 3: Pipeline Complete

After all stories are processed:
1. Update sprint-status.yaml to reflect completion
2. Delete the team using TeamDelete
3. Present a final summary:
   - Total stories completed
   - Total files created/modified
   - Total issues found and resolved during review
   - Any stories that required user intervention and why

</steps>

## Handling Clarifications

When you need clarification during any pipeline step:
- Surface a clear, numbered question to the user in the main conversation
- Include: Story ID, file(s) affected, key tradeoffs
- Wait for the user's answer before resuming
- Incorporate the answer as a hard constraint and continue
