# Store these secrets in your BWS project:



# Profile metadata as JSON (hides account numbers and role names)
bws secret create "aws-profiles-metadata" '{
  "nx_training_advanced": {
    "region": "eu-west-3",
    "account_id": "766272829042",
    "role_name": "nx-training-advanced",
    "session_name": "mark.kpamy",
    "output": "json"
  },
  "nx_datahub_advanced": {
    "region": "eu-west-3",
    "account_id": "261001339617",
    "role_name": "nx-datahub-advanced",
    "session_name": "mark.kpamy"
  },
  "nx_training_master": {
    "region": "eu-west-1",
    "account_id": "766272829042",
    "role_name": "nx-training-master",
    "session_name": "mark.kpamy",
    "output": "json"
  },
  "nx_profile": {
    "region": "eu-west-3",
    "account_id": "766272829042",
    "role_name": "nx-training-master",
    "session_name": "mark.kpamy"
  },
  "nx-presales-advanced": {
    "region": "ap-southeast-1",
    "account_id": "666841086193",
    "role_name": "nx-presales-advanced",
    "session_name": "nxsa-visage-apac"
  },
  "nx-presales-master": {
    "region": "ap-southeast-1",
    "account_id": "666841086193",
    "role_name": "nx-presales-master",
    "session_name": "nx-presales-master"
  },
  "nx_datahub_master": {
    "region": "eu-west-3",
    "account_id": "261001339617",
    "role_name": "nx-datahub-master",
    "session_name": "mark.kpamy",
    "output": "json"
  },
  "nx_renovation_master": {
    "region": "eu-west-3",
    "account_id": "248189924076",
    "role_name": "nx-renovation-master",
    "session_name": "mark.kpamy",
    "output": "json"
  },
  "nx_renovation_advanced": {
    "region": "eu-west-3",
    "account_id": "248189924076",
    "role_name": "nx-renovation-advanced",
    "session_name": "mark.kpamy",
    "output": "json"
  }
}'
