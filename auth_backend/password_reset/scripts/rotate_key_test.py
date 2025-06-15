def run():
    import os
    import datetime
    import traceback
    from dotenv import load_dotenv
    from password_reset.firebase import db
    from password_reset.utils.encryption_test import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt

    print("🚀 Starting key rotation script...", flush=True)

    load_dotenv()

    def fix_pem_format(pem_str):
        return pem_str.replace('\\n', '\n').encode() if pem_str else None

    now = datetime.datetime.utcnow()
    config_ref = db.collection("config").document("encryption_metadata")

    def auto_update_env_on_railway(new_private_key, new_public_key):
        import requests
        import os

        RAILWAY_TOKEN = os.environ.get("RAILWAY_API_TOKEN")
        ENV_ID = os.environ.get("RAILWAY_ENVIRONMENT_ID")

        if not all([RAILWAY_TOKEN, ENV_ID]):
            raise Exception("RAILWAY_API_TOKEN or RAILWAY_ENVIRONMENT_ID is missing.")

        headers = {
            "Authorization": f"Bearer {RAILWAY_TOKEN}",
            "Content-Type": "application/json"
        }

        url = "https://backboard.railway.app/graphql"

        def mutation(name, value):
            return {
                "query": """
                mutation UpsertVariable($input: UpsertVariableInput!) {
                    upsertVariable(input: $input) {
                        id
                        name
                        value
                    }
                }
                """,
                "variables": {
                    "input": {
                        "environmentId": ENV_ID,
                        "name": name,
                        "value": value.replace('\n', '\\n')
                    }
                }
            }

        for var_name, var_val in {
            "ENCRYPTION_PRIVATE_KEY": new_private_key,
            "ENCRYPTION_PUBLIC_KEY": new_public_key
        }.items():
            res = requests.post(url, headers=headers, json=mutation(var_name, var_val))
            if res.status_code == 200:
                print(f"✅ Updated {var_name} on Railway.", flush=True)
            else:
                print(f"❌ Failed to update {var_name}: {res.text}", flush=True)
    def list_env_vars_on_railway():
        import os
        import requests

        RAILWAY_TOKEN = os.environ.get("RAILWAY_API_TOKEN")
        ENV_ID = os.environ.get("RAILWAY_ENVIRONMENT_ID")

        if not all([RAILWAY_TOKEN, ENV_ID]):
            raise Exception("Missing RAILWAY_API_TOKEN or RAILWAY_ENVIRONMENT_ID")

        headers = {
            "Authorization": f"Bearer {RAILWAY_TOKEN}",
            "Content-Type": "application/json"
        }

        query = {
            "query": """
            query GetVariables($environmentId: String!) {
            variables(environmentId: $environmentId) {
                edges {
                node {
                    id
                    name
                    value
                }
                }
            }
            }
            """,
            "variables": {
                "environmentId": ENV_ID
            }
        }

        response = requests.post("https://backboard.railway.app/graphql", headers=headers, json=query)
        
        if response.status_code == 200:
            data = response.json()
            vars = data.get("data", {}).get("variables", {}).get("edges", [])
            print("🔍 Current environment variables:",flush=True)
            for var in vars:
                name = var["node"]["name"]
                val = var["node"]["value"]
                print(f" - {name} = {val[:10]}...",flush=True)  # show only first 10 chars for safety
        else:
            print(f"❌ Failed to fetch env vars: {response.text}",flush=True)

    # try:
    list_env_vars_on_railway()
        # auto_update_env_on_railway(new_private_key, new_public_key)
    # except Exception as e:
    #     print("❌ Failed to auto-update Railway ENV vars:", flush=True)
    #     print(traceback.format_exc(), flush=True)
