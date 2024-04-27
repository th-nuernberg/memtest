import connexion

# Erstellen Sie eine Connexion-Anwendung
app = connexion.FlaskApp(__name__, specification_dir='../memtest-app/memtest-server-client/')

# Lesen Sie die OpenAPI-Spezifikation und konfigurieren Sie die Pfade
app.add_api('openapi.yaml')

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)
