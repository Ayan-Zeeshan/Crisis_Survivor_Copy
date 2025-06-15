import os
import requests

RAILWAY_TOKEN = os.getenv("RAILWAY_API_TOKEN")

headers = {
    "Authorization": f"Bearer {RAILWAY_TOKEN}",
    "Content-Type": "application/json"
}

query = {
    "query": """
    query {
      viewer {
        projects {
          edges {
            node {
              id
              name
              environments {
                edges {
                  node {
                    id
                    name
                  }
                }
              }
            }
          }
        }
      }
    }
    """
}

res = requests.post("https://backboard.railway.app/graphql", headers=headers, json=query)

if res.ok:
    data = res.json()
    for proj in data["data"]["viewer"]["projects"]["edges"]:
        project = proj["node"]
        print(f"\n📁 Project: {project['name']}")
        print(f"→ projectId: {project['id']}")
        for env in project["environments"]["edges"]:
            env_node = env["node"]
            print(f"   🌍 Env: {env_node['name']} → envId: {env_node['id']}")
else:
    print("❌ Failed:", res.text)
