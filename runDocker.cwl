#!/usr/bin/env cwl-runner
#
# Run Docker Submission
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: docker
arguments: 
  - valueFrom: run
  - valueFrom: -i
  - valueFrom: --volume=/tmp:/input:ro
  - valueFrom: --volume=/tmp/$((runtime.outdir).split('/').slice(-1)[0]):/output:rw
  - valueFrom: --memory
  - valueFrom: 200g
  - valueFrom: --memory-swap
  - valueFrom: 0m
  - valueFrom: --net=none
  - valueFrom: --name=$(inputs.submissionId)
  - valueFrom:  $(inputs.dockerRepository)@$(inputs.dockerDigest)

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entryname: .docker/config.json
        entry: |
          {"auths": {"$(inputs.dockerRegistry)": {"auth": "$(inputs.dockerAuth)"}}}
  - class: InlineJavascriptRequirement

inputs:
  - id: submissionId
    type: int
  - id: dockerRepository
    type: string
  - id: dockerDigest
    type: string
  - id: dockerRegistry
    type: string
  - id: dockerAuth
    type: string

outputs:
  predictions:
    type: File
    outputBinding:
      glob: listOfFiles.csv