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
  #Docker run has access to the local file system, so this path is the input directory locally
  - valueFrom: /home/aelamb/repos/Tumor-Deconvolution-Challenge-Workflow/example_files
    prefix: -i
  #- valueFrom: /home/ubuntu
  #  prefix: -i
  #No need to pass in output because you should be getting that information in the script
  #- valueFrom: $((runtime.tmpdir).split('/').slice(0,-1).join("/"))/$((runtime.outdir).split("/").slice(-4).join("/"))
  #  prefix: -o

requirements:
  - class: InitialWorkDirRequirement
    listing:
     # - entryname: listOfFiles.csv
     #   entry: |
     #     "foo"
      - entryname: .docker/config.json
        entry: |
          {"auths": {"$(inputs.dockerRegistry)": {"auth": "$(inputs.dockerAuth)"}}}
      - entryname: runDocker.py
        entry: |
          import docker
          import argparse
          import os
          import logging
          logger = logging.getLogger()
          logger.setLevel(logging.INFO)

          parser = argparse.ArgumentParser()
          parser.add_argument("-s", "--submissionId", required=True, help="Submission Id")
          parser.add_argument("-p", "--dockerRepository", required=True, help="Docker Repository")
          parser.add_argument("-d", "--dockerDigest", required=True, help="Docker Digest")
          parser.add_argument("-i", "--inputDir", required=True, help="Input Directory")
          parser.add_argument("--status", required=True, help="Docker image status")

          args = parser.parse_args()

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

          #TODO: Look for if the container exists already, if so, reconnect 

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
            #These lines below will run as long as the container is running
            for line in container.logs(stream=True):
              logger.error(line.strip())
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
  - id: status
    type: string

outputs:
  predictions:
    type: File
    outputBinding:
      glob: listOfFiles.csv