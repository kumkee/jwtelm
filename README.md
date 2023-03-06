# jwtelm

## Overview

`jwtelm` is an example code for user authorization that uses JWT (JSON Web Tokens) for authentication and authorization. The backend is built with FastAPI, a modern web framework for building APIs with Python. The frontend is built with Elm, a functional programming language that compiles to JavaScript.

## Features

- User login
- JWT-based authentication and authorization
- Frontend built with Elm, a functional programming language that guarantees no runtime exceptions
- Backend built with FastAPI, a modern web framework for building APIs with Python

## Getting started

To get started with `jwtelm`, clone this repository to your local machine:

```git clone https://github.com/kumkee/jwtelm.git```


### Backend

1. Navigate to the `backend` directory.
2. Create a new virtual environment with Python 3.9 and activate it.
3. Install the required packages with `pip install -r requirements.txt`.
4. Add a file named `secrect_strs.py` in the `backend` directory with your own secret keys. For example:

```
"""Secrets are kept here."""
JWT_KEY = 'my_secret_key'

NONCE_PEPPER = 'my_nonce_pepper'
```


Note that the content of `backend/secrect_strs.py` need to be changed for your own project.

5. Run the backend server with `uvicorn main:app --port 8001`.

The backend server should now be running at `http://localhost:8001`.

### Frontend

1. Navigate to the `frontend` directory.
2. Build the Elm app for production by running `make build`.
3. Serve the compiled Elm app by running `python -m http.server 8000` in the same directory.

Note that `make` is for production and `elm reactor` is for reviewing.

The frontend should now be accessible at `http://localhost:8000`.


## Demo

You can try out a live demo of `jwtelm` at https://kumkee.github.io/jwtelm/. The backend of the live demo is hosted on [Deta Space](https://deta.space/). Login credentials for the demo are
1. `johndoe` with password "secret"
2. `kumkee` with password "0123456789" 

## Contributing

If you want to contribute to `jwtelm`, you're welcome to submit a pull request. Please make sure to follow the [code of conduct](CODE_OF_CONDUCT.md) and the [contribution guidelines](CONTRIBUTING.md).

## License

`jwtelm` is licensed under the MIT license. See [LICENSE](LICENSE) for more information.

## Conclusion

Thanks for checking out jwtelm! We hope you find it useful. If you have any questions or suggestions, please feel free to create an issue or pull request.

Demo live page: https://kumkee.github.io/jwtelm/

Live demo backend is hosted in https://deta.space

Please remember to modify `backend/secrect_strs.py` for your own project.

---

README generated with the assistance of [ChatGPT](https://github.com/Chandrahas-Tripathi/ChatGPT), a language model developed by OpenAI.

