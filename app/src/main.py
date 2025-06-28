import requests


def handler(*args, **kwargs):
    res = requests.get('https://api.github.com')
    return res.status_code
