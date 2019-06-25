#!/usr/bin/env cwl-runner
#
# Example sends validation emails to participants
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: 
- python
- send_message.py

inputs:

- id: synapse_config
  type: File
  inputBinding:
    prefix: -c

- id: userid
  type: string
  inputBinding:
    prefix: -u

- id: subject
  type: string
  inputBinding:
    prefix: -s

- id: body
  type: string
  inputBinding:
    prefix: -b

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: send_message.py
        entry: |
          #!/usr/bin/env python
          import synapseclient
          import argparse
          parser = argparse.ArgumentParser()
          parser.add_argument("-c", "--synapse_config", required=True)
          parser.add_argument("-u", "--userid", required=True)
          parser.add_argument("-s", "--subject", required=True)
          parser.add_argument("-b", "--body", required=True)


          args = parser.parse_args()
          syn = synapseclient.Synapse(configPath=args.synapse_config)
          syn.login()

          syn.sendMessage(
            userIds=[args.userid],
            messageSubject=args.subject,
            messageBody=args.body,
            contentType="text")
          
outputs: []

