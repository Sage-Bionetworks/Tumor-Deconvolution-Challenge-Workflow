#!/usr/bin/env cwl-runner
#
# annotate an existing submission with a string value
# (variations can be written to pass long or float values)
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: python

inputs:
  - id: submissionId
    type: int
  - id: annotationValues
    type: File
  - id: private
    type: string
  - id: synapseConfig
    type: File

arguments:
  - valueFrom: annotationSubmission.py
  - valueFrom: $(inputs.submissionId)
    prefix: -s
  - valueFrom: $(inputs.annotationValues)
    prefix: -v
  - valueFrom: $(inputs.private)
    prefix: -p
  - valueFrom: $(inputs.synapseConfig.path)
    prefix: -c

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: annotationSubmission.py
        entry: |
          #!/usr/bin/env python
          import synapseclient
          import argparse
          import json
          if __name__ == '__main__':
            parser = argparse.ArgumentParser()
            parser.add_argument("-s", "--submissionId", required=True, help="Submission ID")
            parser.add_argument("-v", "--annotationValues", required=True, help="Name of annotation to add")
            parser.add_argument("-p", "--private", required=False, help="Annotation is private to queue administrator(s)")
            parser.add_argument("-c", "--synapseConfig", required=True, help="credentials file")
            args = parser.parse_args()

            def update_single_submission_status(status, add_annotations, force=False):
              """
              This will update a single submission's status
              :param:    Submission status: syn.getSubmissionStatus()
              :param:    Annotations that you want to add in dict or submission status annotations format.
                         If dict, all submissions will be added as private submissions
              """
              existingAnnotations = status.get("annotations", dict())
              privateAnnotations = {each['key']:each['value'] for annots in existingAnnotations for each in existingAnnotations[annots] if annots not in ['scopeId','objectId'] and each['isPrivate'] == True}
              publicAnnotations = {each['key']:each['value'] for annots in existingAnnotations for each in existingAnnotations[annots] if annots not in ['scopeId','objectId'] and each['isPrivate'] == False}

              if not synapseclient.annotations.is_submission_status_annotations(add_annotations):
                  privateAddedAnnotations = add_annotations
                  publicAddedAnnotations = dict()
              else:
                  privateAddedAnnotations = {each['key']:each['value'] for annots in add_annotations for each in add_annotations[annots] if annots not in ['scopeId','objectId'] and each['isPrivate'] == True}
                  publicAddedAnnotations = {each['key']:each['value'] for annots in add_annotations for each in add_annotations[annots] if annots not in ['scopeId','objectId'] and each['isPrivate'] == False} 
              #If you add a private annotation that appears in the public annotation, it switches 
              if sum([key in publicAddedAnnotations for key in privateAnnotations]) == 0:
                  pass
              elif sum([key in publicAddedAnnotations for key in privateAnnotations]) >0 and force:
                  privateAnnotations = {key:privateAnnotations[key] for key in privateAnnotations if key not in publicAddedAnnotations}
              else:
                  raise ValueError("You are trying to add public annotations that are already part of the existing private annotations: %s.  Either change the annotation key or specify force=True" % ", ".join([key for key in privateAnnotations if key in publicAddedAnnotations]))
              if sum([key in privateAddedAnnotations for key in publicAnnotations]) == 0:
                  pass
              elif sum([key in privateAddedAnnotations for key in publicAnnotations])>0 and force:
                  publicAnnotations= {key:publicAnnotations[key] for key in publicAnnotations if key not in privateAddedAnnotations}
              else:
                  raise ValueError("You are trying to add private annotations that are already part of the existing public annotations: %s.  Either change the annotation key or specify force=True" % ", ".join([key for key in publicAnnotations if key in privateAddedAnnotations]))

              privateAnnotations.update(privateAddedAnnotations)
              publicAnnotations.update(publicAddedAnnotations)

              priv = synapseclient.annotations.to_submission_status_annotations(privateAnnotations, is_private=True)
              pub = synapseclient.annotations.to_submission_status_annotations(publicAnnotations, is_private=False)

              for annotType in ['stringAnnos', 'longAnnos', 'doubleAnnos']:
                  if priv.get(annotType) is not None and pub.get(annotType) is not None:
                      if pub.get(annotType) is not None:
                          priv[annotType].extend(pub[annotType])
                      else:
                          priv[annotType] = pub[annotType]
                  elif priv.get(annotType) is None and pub.get(annotType) is not None:
                      priv[annotType] = pub[annotType]

              status.annotations = priv
              return(status)

            syn = synapseclient.Synapse(configPath=args.synapseConfig)
            syn.login()
            status = syn.getSubmissionStatus(args.submissionId)
            with open(args.annotationValues) as json_data:
              annots = json.load(json_data)
            status.status = annots['status']
            del annots['status']
            status = update_single_submission_status(status, annots, force=args.private)
            status = syn.store(status)
     
outputs: []

