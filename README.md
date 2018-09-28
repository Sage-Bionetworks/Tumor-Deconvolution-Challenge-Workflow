# ChallengeWorkflowTemplates

These are the two boiler plate challenge workflows that can be linked with the [Synapse workflow hook](https://github.com/Sage-Bionetworks/SynapseWorkflowHook).  There are two different challenge infrastructures:

1. Scoring Harness - Participants submit prediction files and these files are validated and scored.
2. Docker Agent - Participants submit a docker container, which then generates a prediction file.


## Scoring Harness
Please make edits to validate.cwl and score.cwl as you would like your submission to be validated and scored.
* Workflow: scoringHarness_workflow.cwl
* Validation: validate.cwl
* Scoring: score.cwl


## Docker Agent
Please make edits runDocker.cwl for any parameters you would like to add to your docker run command and also the input / output directory you would like to mount onto the docker container.
* Workflow: dockerAgent_workflow.cwl
* Validate Docker: validateDocker.cwl
* Running Docker: runDocker.cwl
