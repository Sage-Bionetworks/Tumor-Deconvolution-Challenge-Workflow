#!/usr/bin/env cwl-runner
#
# Run Docker Submission
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: python
arguments: 
  - valueFrom: runDocker.py
  - valueFrom: $(inputs.submissionId)
    prefix: -s
  - valueFrom: $(inputs.dockerRepository)
    prefix: -p
  - valueFrom: $(inputs.dockerDigest)
    prefix: -d
  - valueFrom: $(inputs.status)
    prefix: --status
  - valueFrom: $(inputs.parentId)
    prefix: --parentId
  - valueFrom: $(inputs.synapseConfig.path)
    prefix: -c
  - valueFrom: /home/ubuntu/r1/
    prefix: -i

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entryname: .docker/config.json
        entry: |
          {"auths": {"$(inputs.dockerRegistry)": {"auth": "$(inputs.dockerAuth)"}}}
      - entryname: runDocker.py
        entry: |
          import docker
          import argparse
          import os
          import logging
          import synapseclient
          import time
          logger = logging.getLogger()
          logger.setLevel(logging.INFO)

          parser = argparse.ArgumentParser()
          parser.add_argument("-s", "--submissionId", required=True, help="Submission Id")
          parser.add_argument("-p", "--dockerRepository", required=True, help="Docker Repository")
          parser.add_argument("-d", "--dockerDigest", required=True, help="Docker Digest")
          parser.add_argument("-i", "--inputDir", required=True, help="Input Directory")
          parser.add_argument("-c", "--synapseConfig", required=True, help="credentials file")
          parser.add_argument("--parentId", required=True, help="Parent Id of submitter directory")
          parser.add_argument("--status", required=True, help="Docker image status")

          args = parser.parse_args()
          syn = synapseclient.Synapse(configPath=args.synapseConfig)
          syn.login()
          if args.status == "INVALID":
            raise Exception("Docker image is invalid")
          client = docker.from_env()
          #Add docker.config file
          dockerImage = args.dockerRepository + "@" + args.dockerDigest

          #These are the volumes that you want to mount onto your docker container
          #OUTPUT_DIR = os.path.join(args.outputDir,args.submissionId)
          OUTPUT_DIR = os.getcwd()
          INPUT_DIR = args.inputDir
          #These are the locations on the docker that you want your mounted volumes to be + permissions in docker (ro, rw)
          #It has to be in this format '/output:rw'
          MOUNTED_VOLUMES = {OUTPUT_DIR:'/output:rw',
                           INPUT_DIR:'/input:ro'}
          #All mounted volumes here in a list
          ALL_VOLUMES = [OUTPUT_DIR,INPUT_DIR]
          #Mount volumes
          volumes = {}
          for vol in ALL_VOLUMES:
            volumes[vol] = {'bind': MOUNTED_VOLUMES[vol].split(":")[0], 'mode': MOUNTED_VOLUMES[vol].split(":")[1]}

          #Look for if the container exists already, if so, reconnect 
          container=None
          for cont in client.containers.list(all=True):
            if args.submissionId in cont.name:
              #Must remove container if the container wasn't killed properly
              if cont.status == "exited":
                cont.remove()
              else:
                container = cont
          # If the container doesn't exist, make sure to run the docker image
          if container is None:
            #Run as detached, logs will stream below
            container = client.containers.run(dockerImage,detach=True, volumes = volumes, name=args.submissionId, network_disabled=True, stderr=True)

          # If the container doesn't exist, there are no logs to write out and no container to remove
          if container is not None:

            logFileName = args.submissionId + "_log.txt"
            #Create the logfile
            openLog = open(logFileName,'w').close()

            #These lines below will run as long as the container is running
            # for line in container.logs(stream=True):
            #   logger.error(line.strip())

            #Check if container is still running
            while container in client.containers.list():
              logFileText = container.logs()
              with open(logFileName,'w') as logFile:
                logFile.write(logFileText)
              statinfo = os.stat(logFileName)
              if statinfo.st_size > 0 and statinfo.st_size/1000.0 <= 50:
                ent = synapseclient.File(logFileName, parent = args.parentId)
                try:
                  logs = syn.store(ent)
                except synapseclient.exceptions.SynapseHTTPError as e:
                  pass
                time.sleep(60)
            #Must run again to make sure all the logs are captured
            logFileText = container.logs()
            with open(logFileName,'w') as logFile:
              logFile.write(logFileText)
            statinfo = os.stat(logFileName)
            #Only store log file if > 0 bytes
            if statinfo.st_size > 0 and statinfo.st_size/1000.0 <= 50:
              ent = synapseclient.File(logFileName, parent = args.parentId)
              try:
                logs = syn.store(ent)
              except synapseclient.exceptions.SynapseHTTPError as e:
                pass

            #Remove container and image after being done
            container.remove()
            try:
              client.images.remove(dockerImage)
            except:
              print("Unable to remove image")


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
  - id: parentId
    type: string
  - id: status
    type: string
  - id: synapseConfig
    type: File

outputs:
  predictions:
    type: File
    outputBinding:
      glob: predictions.csv
