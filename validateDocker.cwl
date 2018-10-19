#!/usr/bin/env cwl-runner
#
# Example validate submission file
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: python

inputs:
  - id: dockerRepository
    type: string
  - id: dockerDigest
    type: string
  - id: synapseConfig
    type: File

arguments:
  - valueFrom: validate.py
  - valueFrom: $(inputs.dockerRepository)
    prefix: -p
  - valueFrom: $(inputs.dockerDigest)
    prefix: -d
  - valueFrom: $(inputs.synapseConfig.path)
    prefix: -c
  - valueFrom: results.json
    prefix: -r

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: validate.py
        entry: |
          #!/usr/bin/env python
          import synapseclient
          import argparse
          import os
          import json
          import base64
          import requests
          parser = argparse.ArgumentParser()
          parser.add_argument("-p", "--dockerRepository", required=True, help="Submission File")
          parser.add_argument("-d", "--dockerDigest", required=True, help="Submission File")
          parser.add_argument("-r", "--results", required=True, help="validation results")
          parser.add_argument("-c", "--synapseConfig", required=True, help="credentials file")
          args = parser.parse_args()

          def getBearerTokenURL(dockerRequestURL, user, password):
            initialReq = requests.get(dockerRequestURL)
            auth_headers = initialReq.headers['Www-Authenticate'].replace('"','').split(",")
            for head in auth_headers:
              if head.startswith("Bearer realm="):
                bearerRealm = head.split('Bearer realm=')[1]
              elif head.startswith('service='):
                service = head.split('service=')[1]
              elif head.startswith('scope='):
                scope = head.split('scope=')[1]
            return("{0}?service={1}&scope={2}".format(bearerRealm,service,scope))

          def getAuthToken(dockerRequestURL, user, password):
            bearerTokenURL = getBearerTokenURL(dockerRequestURL, user, password)
            authString = user + ":" + password 
            auth = base64.b64encode(authString.encode()).decode()
            bearerTokenRequest = requests.get(bearerTokenURL,
              headers={'Authorization': 'Basic %s' % auth})
            return(bearerTokenRequest.json()['token'])

          #Must read in credentials (username and password)
          config = synapseclient.Synapse().getConfigFile(configPath=args.synapseConfig)
          authen = dict(config.items("authentication"))
          if authen.get("username") is None and authen.get("password") is None:
            raise Exception('Config file must have username and password')
          dockerRepo = args.dockerRepository.replace("docker.synapse.org/","")
          dockerDigest = args.dockerDigest
          index_endpoint = 'https://docker.synapse.org'

          #Check if docker is able to be pulled
          dockerRequestURL = '{0}/v2/{1}/manifests/{2}'.format(index_endpoint, dockerRepo, dockerDigest)
          token = getAuthToken(dockerRequestURL, authen['username'], authen['password'])

          resp = requests.get(dockerRequestURL, headers={'Authorization': 'Bearer %s' % token})
          invalidReasons = []
          status = "VALIDATED"
          if resp.status_code != 200:
            invalidReasons.append("Docker image + sha digest must exist.  You submitted %s@%s" % (args.dockerRepository,args.dockerDigest))
            status = "INVALID"

          #Must check docker image size
          #Synapse docker registry
          dockerSize = sum([layer['size'] for layer in resp.json()['layers']])
          if dockerSize/1000000000.0 >= 1000:
            invalidReasons.append("Docker container must be less than a teribyte")
            status = "INVALID"

          result = {'dockerImageErrors':"\n".join(invalidReasons),'dockerImageStatus':status}
          with open(args.results, 'w') as o:
            o.write(json.dumps(result))

outputs:

  - id: results
    type: File
    outputBinding:
      glob: results.json   

  - id: status
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['dockerImageStatus'])

  - id: invalidReasons
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['dockerImageErrors'])
