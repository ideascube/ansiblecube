port = 5000

class Config(object):
    SECRET_KEY = 'Find a nice secret key to protect the app.' # Use e.g. http://randomkeygen.com/
    MONGODB_DB = 'bsfcampus'
    CORS_ORIGINS = ['http://localhost', 'http://localhost:63342']
    UPLOAD_FILES_PATH = "/path/to/static/"
    UPLOAD_FILES_URL = "http://url_to_static/"
    ## Local servers only:
    CENTRAL_SERVER_HOST = 'http://localhost:5000'
    CENTRAL_SERVER_KEY = ''
    CENTRAL_SERVER_SECRET = ''
    ## Central servers
    MAIL_SERVER = 'localhost'
    EMAIL_FROM = ("Name", "email@email.com")
    APP_TITLE = "App Title"