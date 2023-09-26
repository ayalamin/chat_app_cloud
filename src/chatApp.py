from flask import Flask,redirect, request, render_template, session
from flask_session import Session
import os
import base64
import datetime

server = Flask(__name__)
server.config["SESSION_PERMANENT"] = False
server.config["SESSION_TYPE"] = "filesystem"
Session(server)

rooms_dir = os.getenv("ROOMS_PATH") 
users_path = os.getenv("USERS_PATH")

def decode_password(encoded_password):
    try:
        base64_bytes = encoded_password.encode('ascii')
        message_bytes = base64.b64decode(base64_bytes)
        return message_bytes.decode('ascii')
    except:
        return "Error"
    

def encode_password(decoded_password):
    message_bytes = decoded_password.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)
    return base64_bytes.decode('ascii')

USERS = {}
with open(users_path, "r") as users_file:
    for line in users_file: 
        parts = line.strip().split(",", 1)
        if len(parts) == 2:
            username, encoded_password = parts
            password = decode_password(encoded_password)
            USERS[username] = password

@server.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]
        if username not in USERS:
            encoded_password = encode_password(password)
            USERS[username] = password
            with open(users_path, "a") as users_file:
                users_file.write(f"{username},{encoded_password}\n")
        else:
            return "username already exists!!"
        return redirect("login")
    return render_template("register.html")

@server.route('/login' , methods=['GET', 'POST'])
def login():
  if request.method == 'POST':
      name = request.form['username']
      password = request.form['password']
      if USERS.get(name):
           if USERS.get(name) == password:
                session["username"] = name
                return redirect('lobby')
           else:
                return redirect('register')
  return render_template('login.html')
 
@server.route('/lobby', methods =["GET", "POST"])
def room():
   if request.method == 'POST':
        new_room = request.form["new_room"] 
        if new_room:
             room_path = os.path.join(rooms_dir, f"{new_room}.txt")
             if os.path.isfile(room_path):
                 return "Error in rhe room name!"
             else:
                 with open(room_path, 'w') as f:
                     f.write("welcome")  
   rooms_files = os.listdir('rooms/')
   rooms = []
   for room in rooms_files:  
        r = room.split('.')[0]
        rooms.append(r)      
   return render_template('lobby.html', room_names=rooms)
 
@server.route("/chat/<room>", methods=["GET", "POST"])
def chat(room):
    return render_template("chat.html", roomPage=room)


@server.route("/logout")
def logout():
    return redirect("login")


@server.route("/api/chat/<room>", methods=["GET", "POST"])
def chat_room(room):
   chat_content = ""
   if request.method == "POST":
        message = request.form["msg"]
        if message:
            room_path = os.path.join(rooms_dir, f"{room}")
            with open(room_path, "a") as room_file:
                timestamp = datetime.datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
                room_file.write(f"{timestamp} {session.get('username')}: {message}\n")
   with open(os.path.join(rooms_dir, f"{room}"), "r") as room_file:
      room_file.seek(0)
      chat_content = room_file.read()
   return chat_content


@server.route("/clear/<room>", methods=["GET", "POST"])
def clear(room):
    room_path = os.path.join(rooms_dir, f"{room}")
    open(room_path, "w").close()
    return render_template("chat.html")


if __name__ == "__main__":
   server.run(host='0.0.0.0', debug = True)

