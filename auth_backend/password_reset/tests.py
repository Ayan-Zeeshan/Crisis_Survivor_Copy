# # from django.test import TestCase


# # import firebase_admin
# # from firebase_admin import credentials, firestore
# # import json

# # cred = credentials.Certificate(r"C:\Users\ayanz\Desktop\Flutter\crisis_survivor\firebase\crisis-survivor-firebase-adminsdk-fbsvc-87aa3ee0c5.json") 
# # firebase_admin.initialize_app(cred)

# # db = firestore.client()

# # def export_collection_to_json(collection_name, output_file):
# #     docs = db.collection(collection_name).stream()
# #     data = {doc.id: doc.to_dict() for doc in docs}
# #     with open(output_file, 'w') as f:
# #         json.dump(data, f, indent=2)
# #     print(f"✅ Exported '{collection_name}' to {output_file}")

# # export_collection_to_json("users", "users.json")
# # export_collection_to_json("config", "config.json")
# import firebase_admin
# from firebase_admin import credentials, firestore
# import json
# from google.cloud.firestore_v1 import DocumentSnapshot
# import datetime

# cred = credentials.Certificate("path/to/serviceAccount.json")
# firebase_admin.initialize_app(cred)

# db = firestore.client()

# def serialize_value(value):
#     if isinstance(value, datetime.datetime):
#         return value.isoformat()
#     elif isinstance(value, dict):
#         return {k: serialize_value(v) for k, v in value.items()}
#     elif isinstance(value, list):
#         return [serialize_value(v) for v in value]
#     else:
#         return value

# def export_collection_to_json(collection_name, output_file):
#     docs = db.collection(collection_name).stream()
#     data = {
#         doc.id: {
#             key: serialize_value(value)
#             for key, value in doc.to_dict().items()
#             if value is not None  # ✅ Skip null values
#         }
#         for doc in docs
#     }

#     with open(output_file, 'w') as f:
#         json.dump(data, f, indent=2)

#     print(f"✅ Exported '{collection_name}' to {output_file}")

# export_collection_to_json("users", "users.json")
# export_collection_to_json("config", "config.json")
import firebase_admin
from firebase_admin import credentials, firestore
import json
from datetime import datetime

cred = credentials.Certificate(r"C:\Users\ayanz\Desktop\Flutter\crisis_survivor\firebase\crisis-survivor-firebase-adminsdk-fbsvc-87aa3ee0c5.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def convert_value(val):
    if hasattr(val, 'isoformat'):  # timestamp
        return val.isoformat()
    elif isinstance(val, dict):
        return {k: convert_value(v) for k, v in val.items()}
    elif isinstance(val, list):
        return [convert_value(v) for v in val]
    else:
        return val

def export_collection_to_json(collection_name, output_file):
    docs = db.collection(collection_name).stream()
    data = {
        doc.id: {k: convert_value(v) for k, v in doc.to_dict().items()}
        for doc in docs
    }
    with open(output_file, 'w') as f:
        json.dump(data, f, indent=2)
    print(f"✅ Exported '{collection_name}' to {output_file}")

export_collection_to_json("users", "users.json")
export_collection_to_json("config", "config.json")
