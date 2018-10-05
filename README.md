# ChallengeWorkflowTemplates

These are the two boiler plate challenge workflows that can be linked with the [Synapse workflow hook](https://github.com/Sage-Bionetworks/SynapseWorkflowHook).  There are two different challenge infrastructures:

1. Scoring Harness - Participants submit prediction files and these files are validated and scored.
2. Docker Agent - Participants submit a docker container, which then generates a prediction file.


## Scoring Harness
* Workflow: scoringHarness_workflow.cwl
* Tools: annotateSubmission.cwl, downloadSubmissionFile.cwl, score.cwl, scoreEmail.cwl, validate.cwl, validationEmail.cwl

### Making edits to the scoring harness.

* Validation: validate.cwl

This file can be changed to validate whatever format participants submit their predictions.  It must have `status` and `invalidReasons` as outputs where `status` is the `predictionFileStatus` and `invalidReasons` is a `\n` joined set of strings that define whatever is wrong with the prediction file. 

* Scoring: score.cwl

This script scores the prediction file against the goldstandard. It must have `results` output which is a json file with the key `predictionFileStatus`.

* Messaging: validationEmail.cwl and scoreEmail.cwl

Both of these are general templates for submission emails.  You may edit the body of the email to change the subject title and message sent.

If you would not like to email participants, simply comment these steps out.  These workflow steps are required for challenges because participants should only be receiving pertinent information back from the scoring harness.  If the scoring code breaks, it is the responsibility of the administrator to receive notifications and fix the code.


## Docker Agent
Please make edits runDocker.cwl for any parameters you would like to add to your docker run command and also the input / output directory you would like to mount onto the docker container.
* Workflow: dockerAgent_workflow.cwl
* Validate Docker: validateDocker.cwl
* Running Docker: runDocker.cwl
