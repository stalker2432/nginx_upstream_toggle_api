from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

# Path to your bash script
SCRIPT_PATH = "/home/stash/toggle_upstream_server.sh"

@app.route('/enable', methods=['POST'])
def enable_upstream():
    data = request.get_json()
    return modify_upstream(data, "enable")

@app.route('/disable', methods=['POST'])
def disable_upstream():
    data = request.get_json()
    return modify_upstream(data, "disable")

def modify_upstream(data, mode):
    # Validate request data
    vhost_config = data.get("vhost_config")
    upstream_name = data.get("upstream_name")
    server = data.get("server")

    if not vhost_config or not upstream_name or not server:
        return jsonify({"error": "Missing required parameters"}), 400

    # Execute the bash script
    try:
        result = subprocess.run(
            [SCRIPT_PATH, vhost_config, upstream_name, server, mode],
            capture_output=True,
            text=True
        )

        if result.returncode == 0:
            return jsonify({"message": f"Successfully {mode}d {server} in upstream {upstream_name}"}), 200
        else:
            return jsonify({"error": result.stderr}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=6000)
