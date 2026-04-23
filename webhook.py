from flask import Flask, request, jsonify, redirect, session, send_file
from ldap3 import Server, Connection
import subprocess
import os

app = Flask(__name__)
app.secret_key = 'supersecretkey123'

AD_SERVER = '10.0.193.160'
AD_DOMAIN = 'idm.local'

@app.route('/login', methods=['GET'])
def login_page():
    return send_file('/tmp/login.html')

@app.route('/login', methods=['POST'])
def login():
    username = request.form.get('username')
    password = request.form.get('password')
    print(f"Попытка входа: {username}")
    
    try:
        server = Server(AD_SERVER)
        conn = Connection(server, user=f'{username}@{AD_DOMAIN}', password=password)
        conn.bind()
        print(f"Результат: {conn.result}")
        if conn.bind():
            session['user'] = username
            return redirect('/')
        else:
            return redirect('/login?error=1')
    except:
        return redirect('/login?error=1')

@app.route('/logout')
def logout():
    session.pop('user', None)
    return redirect('/login')

@app.route('/')
def index():
    if 'user' not in session:
        return redirect('/login')
    return send_file('/tmp/index.html')

@app.route('/time.js')
def timejs():
    return send_file('/tmp/time.js')

@app.route('/webhook', methods=['POST'])
def webhook():
    data = request.json
    weather = data.get('weather', 'нет данных')
    
    weather_escaped = weather.replace('/', '\\/').replace('+', '\\+')
    commands = f"sed -i 's/id=\"weather-temp\">[^<]*/id=\"weather-temp\">{weather_escaped}/' /usr/share/nginx/html/index.html"
    
    result = subprocess.run(
        ['ssh', '-p', '422', '-o', 'StrictHostKeyChecking=no', 'alnur@localhost', commands],
        capture_output=True, text=True
    )

    result2 = subprocess.run(
    ['ssh', '-p', '422', '-o', 'StrictHostKeyChecking=no', 'alnur@localhost', 'cat /usr/share/nginx/html/index.html'],
    capture_output=True, text=True
    )
    with open('/tmp/index.html', 'w') as f:
        f.write(result2.stdout)

    print(f"Обновился")
 
    if result.returncode == 0:
        return jsonify({'status': 'ok', 'message': f'Погода обновлена: {weather}'}), 200
    else:
        return jsonify({'status': 'error', 'message': result.stderr}), 500
   
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
